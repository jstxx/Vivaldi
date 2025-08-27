//
//  VivaldiPersistence.swift
//
//
//  Created by Justin SL on 8/14/25.
//

import Foundation
import VivaldiModels
import CoreLocation

public final class VivaldiPersistence {
    public static var currentCity: String {
        return UserDefaults.standard.currentLocation?.city ?? ""
    }
    public static var completedOnboarding: Bool  {
        get {
            return UserDefaults.standard.completedOnboarding ?? false
        }
        set {
            UserDefaults.standard.completedOnboarding = newValue
        }
    }
    
    public static var temperatureUnit: String? {
        get {
            UserDefaults.standard.temperatureUnit
        }
        set {
            UserDefaults.standard.temperatureUnit = newValue
        }
    }
    
    public static var currentLocation: LocationData? {
        get {
            return UserDefaults.standard.currentLocation
        }
        set {
            UserDefaults.standard.currentLocation = newValue
        }
    }
    
    public static var currentCoordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: UserDefaults.standard.currentLocation?.latitude ?? 0.0,
                                      longitude: UserDefaults.standard.currentLocation?.longitude ?? 0.0)
    }
    
    public static var savedCities: [City] {
        get {
            return UserDefaults.standard.savedCities
        }
        set {
            UserDefaults.standard.savedCities = newValue
        }
    }
    
    public static func addCity(_ city: City) {
        var cities = savedCities
        // Avoid duplicates
        if !cities.contains(where: { $0.name == city.name && $0.countryCode == city.countryCode }) {
            cities.append(city)
            savedCities = cities
        }
    }
    
    public static func removeCity(_ city: City) {
        var cities = savedCities
        cities.removeAll { $0.id == city.id }
        savedCities = cities
    }
    
    public static func isCitySaved(_ city: City) -> Bool {
        return savedCities.contains { $0.id == city.id }
    }
}

// Simple on-device storage
public extension UserDefaults {
    
    public enum Keys {
        static let currentLocation = "vivaldi_current_location"
        static let completedOnboarding = "vivaldi_completed_onboarding"
        static let savedCities = "vivaldi_saved_cities"
        static let temperatureUnit = "vivaldi_temperature_unit"
    }
    
    public var savedCities: [City] {
        get {
            guard let data = data(forKey: Keys.savedCities) else {
                return []
            }
            return (try? JSONDecoder().decode([City].self, from: data)) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                set(data, forKey: Keys.savedCities)
            }
        }
    }
    
    public var completedOnboarding: Bool {
        get {
            return self.bool(forKey: UserDefaults.Keys.completedOnboarding)
        }
        set {
            self.set(newValue, forKey: UserDefaults.Keys.completedOnboarding)
        }
    }
    
    public func clearCurrentLocation() {
        self.removeObject(forKey: UserDefaults.Keys.currentLocation)
    }
    
    /// load the last known location.
    public var currentLocation: LocationData? {
        get {
            guard let data = data(forKey: Keys.currentLocation) else {
                return nil
            }
            return try? JSONDecoder().decode(LocationData.self, from: data)
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                set(data, forKey: Keys.currentLocation)
            }
        }
    }
    
    public var temperatureUnit: String? {
        get {
            string(forKey: Keys.temperatureUnit)
        }
        set {
            set(newValue, forKey: Keys.temperatureUnit)
        }
    }
}
