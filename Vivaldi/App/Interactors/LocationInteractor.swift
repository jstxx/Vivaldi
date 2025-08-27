//
//  LocationInteractor.swift
//  Vivaldi
//
//  Created by Justin SL on 8/14/25.
//

import CoreLocation
import Observation
import VivaldiPersistence
import VivaldiModels
import VivaldiAPIClient

// MARK: - Protocols

@MainActor protocol LocationManaging {
    var currentCity: String? { get }
    var currentLatitude: Double? { get }
    var currentLongitude: Double? { get }
    var status: CLAuthorizationStatus { get }
    
    func requestPermission()
    func startLocationUpdates()
    func stopLocationUpdates()
}

@MainActor protocol CurrentWeatherProviding {
    var currentWeatherResponse: WeatherAPIResponse? { get }
    var currentTemperatureCelsius: Int? { get }
    var currentTemperatureFahrenheit: Int? { get }
    var currentWeatherCondition: WeatherCondition? { get }
}

// MARK: - LocationInteractor

@MainActor
@Observable
final class LocationInteractor: NSObject, CLLocationManagerDelegate, LocationManaging, CurrentWeatherProviding {
    
    // MARK: - Location Properties
    
    var status: CLAuthorizationStatus
    var currentLatitude: Double?
    var currentLongitude: Double?
    var currentCity: String?
    
    // MARK: - Weather Properties
    
    var currentWeatherResponse: WeatherAPIResponse?
    var currentLocationWeatherData: (city: City, response: WeatherAPIResponse)?
    
    // MARK: - Private Properties
    
    private let manager = CLLocationManager()
    private let weatherProvider: WeatherProviding
    
    // Geocoding throttling
    private var lastGeocodeTime: Date?
    private var lastGeocodedLocation: CLLocation?
    private let minimumGeocodeInterval: TimeInterval = 300 // geocode once every 300 seconds
    private let minimumDistanceChange: CLLocationDistance = 1000 // geocode if moved 1km+
    
    // MARK: - Computed Properties
    
    var currentWeatherCondition: WeatherCondition? {
        return currentWeatherResponse?.weatherConditions.first
    }
    
    var currentTemperature: Double? {
        return currentWeatherResponse?.atmosphericData.temperature
    }
    
    var currentTemperatureCelsius: Int? {
        guard let temp = currentTemperature else { return nil }
        return Int(temp - 273.15) // Kelvin to Celsius
    }
    
    var currentTemperatureFahrenheit: Int? {
        guard let temp = currentTemperature else { return nil }
        return Int((temp - 273.15) * 9/5 + 32) // Kelvin to Fahrenheit
    }
    
    var currentHumidity: Int? {
        return currentWeatherResponse?.atmosphericData.humidityPercent
    }
    
    var currentWindSpeed: Double? {
        return currentWeatherResponse?.wind.speedMetersPerSecond
    }
    var currentLocationForecast: [DailyWeatherSummary]?

    // MARK: - Initialization
    
    init(weatherProvider: WeatherProviding = VivaldiAPIClient(apiKey: Bundle.main.object(forInfoDictionaryKey: "WeatherApiKey") as? String ?? "")) {
        self.weatherProvider = weatherProvider
        self.status = .notDetermined
        super.init()
        
        setupLocationManager()
        loadPersistedLocation()
        startLocationUpdatesIfAuthorized()
    }
    
    // MARK: - Public Methods
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        manager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        manager.stopUpdatingLocation()
    }
    
    func clearLocationData() {
        self.currentCity = nil
        self.currentLatitude = nil
        self.currentLongitude = nil
        UserDefaults.standard.currentLocation = nil
    }
    
    // MARK: - Private Setup Methods
    
    private func setupLocationManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.status = manager.authorizationStatus
    }
    
    private func loadPersistedLocation() {
        if let savedLocation = UserDefaults.standard.currentLocation {
            self.currentCity = savedLocation.city
            self.currentLatitude = savedLocation.latitude
            self.currentLongitude = savedLocation.longitude
        }
    }
    
    private func startLocationUpdatesIfAuthorized() {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    // MARK: - Location Delegate Methods
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.status = manager.authorizationStatus
            
            // start or stop location updates
            if self.status == .authorizedWhenInUse || self.status == .authorizedAlways {
                self.manager.startUpdatingLocation()
            } else {
                self.manager.stopUpdatingLocation()
                // clear stale data if permission is revoked
                self.clearLocationData()
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            self.currentLatitude = location.coordinate.latitude
            self.currentLongitude = location.coordinate.longitude
            
            // reverse geocode if necessary then fetch weather
            if self.shouldPerformReverseGeocode(for: location) || self.currentCity == nil {
                await self.reverseGeocode(location: location)
            } else {
                if self.currentLocationWeatherData == nil { // have city but no weather yet
                     await self.fetchCurrentLocationWeather()
                }
                self.manager.stopUpdatingLocation()
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location Manager failed with error: \(error.localizedDescription)")
    }
    
    // MARK: - Geocoding & Weather Methods
    
    private func shouldPerformReverseGeocode(for location: CLLocation) -> Bool {
        let now = Date()

        // time throttling
        if let lastTime = lastGeocodeTime,
           now.timeIntervalSince(lastTime) < minimumGeocodeInterval {
            print("skipping geocode: Too soon")
            return false
        }
        
        // distance throttling
        if let lastLocation = lastGeocodedLocation,
           location.distance(from: lastLocation) < minimumDistanceChange {
            print("skipping geocode: Too close")
            return false
        }
        return true
    }
    
    private func reverseGeocode(location: CLLocation) async {
        lastGeocodeTime = Date()
        lastGeocodedLocation = location
        
        let geocoder = CLGeocoder()
        do {
            if let placemark = try await geocoder.reverseGeocodeLocation(location).first {
                let newCity = placemark.locality ?? placemark.subAdministrativeArea ?? placemark.name
                
                // re-fetch weather if the city name has actually changed
                if newCity != self.currentCity {
                    self.currentCity = newCity
                    self.persistCurrentLocation()
                    await fetchCurrentLocationWeather()
                } else {
                    // city name is the same, but weather could need to be refreshed
                    if self.currentWeatherResponse == nil {
                        await fetchCurrentLocationWeather()
                    }
                }
            }
        } catch {
            print("Reverse geocoding failed with error: \(error.localizedDescription)")
            self.currentCity = nil // clear city on geocoding error
            self.currentWeatherResponse = nil // clear weather too
        }
    }
    
    private func fetchCurrentLocationWeather() async {
        guard let cityName = currentCity else { return }
        let cityObjectForAPI = City(name: cityName, countryCode: "")
        
        do {
            let weatherResponse = try await weatherProvider.fetchWeather(for: cityObjectForAPI)
            self.currentLocationWeatherData = (city: cityObjectForAPI, response: weatherResponse)
            await fetchCurrentLocationForecast()
            print("Fetched weather and forecast for current location: \(cityName).")
        } catch {
            print(" Failed to fetch weather for current location: \(error)")
            self.currentLocationWeatherData = nil
            self.currentLocationForecast = nil
        }
    }
    
    private func persistCurrentLocation() {
        guard let city = currentCity, let lat = currentLatitude, let lon = currentLongitude else {
            return
        }
        VivaldiPersistence.currentLocation = LocationData(city: city, latitude: lat, longitude: lon)
    }
    
    @MainActor
    func fetchCurrentLocationForecast() async {
        guard let cityName = currentCity else { return }
        let cityObject = City(name: cityName, countryCode: "")
        do {
            let forecastSummaries = try await weatherProvider.fetchForecast(for: cityObject)
            self.currentLocationForecast = forecastSummaries
        } catch {
            print("error with forecast at current location: \(error)")
            self.currentLocationForecast = nil
        }
    }
}
