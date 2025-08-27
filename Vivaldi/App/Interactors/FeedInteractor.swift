//
//  FeedInteractor.swift
//  Vivaldi
//
//  Created by Justin SL on 8/14/25.
//

import Foundation
import VivaldiModels
import VivaldiAPIClient
import VivaldiPersistence
import Observation
import UIKit

@MainActor
@Observable
final class FeedInteractor {
    private let weatherProvider: WeatherProviding

    // weather data storage
    var cityWeather: [City: WeatherAPIResponse] = [:]

    // forecast data storage
    var cityForecasts: [City: [DailyWeatherSummary]] = [:]
    var isLoadingWeather = false
    var weatherError: String?
    var displayCurrentLocationCity: City?

    var savedCities: [City] = [] {
        didSet {
            VivaldiPersistence.savedCities = savedCities
        }
    }

    // default cities
    private static let defaultCities: [City] = [
        City(name: "Los Angeles", countryCode: "US"),
        City(name: "San Francisco", countryCode: "US"),
        City(name: "Austin", countryCode: "US"),
        City(name: "Lisbon", countryCode: "PT"),
        City(name: "Auckland", countryCode: "NZ"),
        City(name: "Ann Arbor", countryCode: "US")
    ]

    // current location from persistence
    var currentLocationCity: City? {
        guard let savedLocation = VivaldiPersistence.currentLocation else { return nil }
        return City(name: savedLocation.city, countryCode: "")
    }

    // All cities for the feed (current location first, then saved cities)
    var allCities: [City] {
        if let currentCity = currentLocationCity {
            return [currentCity] + savedCities
        }
        return savedCities
    }

    init(weatherProvider: WeatherProviding = VivaldiAPIClient(apiKey: Bundle.main.object(forInfoDictionaryKey: "WeatherApiKey") as? String ?? "")) {
        self.weatherProvider = weatherProvider
        
        if let savedUnitRaw = VivaldiPersistence.temperatureUnit,
           let savedUnit = TemperatureUnit(rawValue: savedUnitRaw) {
            temperatureUnit = savedUnit
        }
        loadSavedCities()
    }

    // MARK: - Public Methods

    /// Loads weather for all cities in the feed
    func loadWeatherFeed() async {
        await loadWeather(for: allCities)
    }

    /// Refreshes weather for all cities
    func refreshWeatherFeed() async {
        clearWeatherData()
        await loadWeatherFeed()
    }

    func weather(for city: City) -> WeatherAPIResponse? {
        return cityWeather[city]
    }

    func hasWeather(for city: City) -> Bool {
        return cityWeather[city] != nil
    }

    var temperatureUnit: TemperatureUnit = .fahrenheit {
        didSet {
            VivaldiPersistence.temperatureUnit = temperatureUnit.rawValue
        }
    }

    /// Adds a new city to the user's saved cities
    func addCity(_ city: City) {
        // dupe check
        if !savedCities.contains(where: { $0.name == city.name &&
            $0.countryCode == city.countryCode }) {
            savedCities.insert(city, at: 0)
            Task {
                await loadWeather(for: [city])
            }
        }
    }

    func resetCities() {
        savedCities = FeedInteractor.defaultCities
    }

    public func refreshForecast(for city: City) async {
        do {
            let summaries = try await weatherProvider.fetchForecast(for: city)
            cityForecasts[city] = summaries
        } catch {
            cityForecasts[city] = nil
        }
    }

    func removeCity(_ city: City) {
        savedCities.removeAll { $0.id == city.id }
        cityWeather.removeValue(forKey: city)
    }

    func clearCurrentLocationWeather() {
        if let currentLocCity = displayCurrentLocationCity {
            cityWeather.removeValue(forKey: currentLocCity)
            displayCurrentLocationCity = nil
        }
    }

    // MARK: - Private Methods
    
    /// Load cities from persistence on init
    private func loadSavedCities() {
        let persistedCities = VivaldiPersistence.savedCities
        
        if persistedCities.isEmpty {
            // First time user
            savedCities = FeedInteractor.defaultCities
        } else {
            savedCities = persistedCities
        }
    }

    /// Loads weather for multiple cities concurrently
    private func loadWeather(for cities: [City]) async {
        guard !cities.isEmpty else { return }

        setLoadingState(true)
        clearError()

        await withTaskGroup(of: (City, Result<WeatherAPIResponse, Error>).self) { group in
            for city in cities {
                group.addTask {
                    let result = await self.fetchWeather(for: city)
                    return (city, result)
                }
            }

            for await (city, result) in group {
                await handleWeatherResult(for: city, result: result)
            }
        }
        setLoadingState(false)
    }

    /// Fetch weather for a city
    /// - Parameter city: City
    /// - Returns: WeatherAPIResponse
    /// 
    private func fetchWeather(for city: City) async -> Result<WeatherAPIResponse, Error> {
        do {
            let weather = try await weatherProvider.fetchWeather(for: city)
            return .success(weather)
        } catch {
            return .failure(error)
        }
    }
    
    public func fetchForecast(for city: City) async -> Result<[DailyWeatherSummary], Error> {
        do {
            let weather = try await weatherProvider.fetchForecast(for: city)
            return .success(weather)
        } catch {
            return .failure(error)
        }
    }

    public func loadForecast(for city: City) async {
        let forecastResult = await fetchForecast(for: city)
        switch forecastResult {
        case .success(let summaries):
            cityForecasts[city] = summaries
        case .failure(let error):
            cityForecasts[city] = nil
            print("filed to load forecast for \(city.name): \(error)")
        }
    }

    private func handleWeatherResult(for city: City, result: Result<WeatherAPIResponse, Error>) async {
        switch result {
        case .success(let weather):
            await storeWeather(weather, for: city)
            
        case .failure(let error):
            await handleWeatherError(for: city, error: error)
        }
    }

    /// Stores successful weather data
    private func storeWeather(_ weather: WeatherAPIResponse, for city: City) async {
        cityWeather[city] = weather
    }

    private func handleWeatherError(for city: City, error: Error) async {
        if weatherError == nil {
            weatherError = "Problem loading weather"
        }
    }

    // MARK: - State Management

    private func setLoadingState(_ loading: Bool) {
        isLoadingWeather = loading
    }

    private func clearError() {
        weatherError = nil
    }

    private func clearWeatherData() {
        cityWeather.removeAll()
    }

    func goToSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
