//
//  ViivaldiModels.swift
//
//
//  Created by Justin SL on 8/14/25.
//

import Foundation

/// Icon sizes available from OpenWeather API
public enum IconSize {
    case small
    case standard
    case large

    var suffix: String {
        switch self {
        case .small: return ""
        case .standard: return "@2x"
        case .large: return "@4x"
        }
    }
}

/// Protocol for entities that can provide weather icon URLs
public protocol IconProviding {
    var iconCode: String { get }
    func iconURL(size: IconSize) -> URL?
}

extension IconProviding {
    public func iconURL(size: IconSize = .standard) -> URL? {
        let baseURL = "https://openweathermap.org/img/wn/"
        let urlString = "\(baseURL)\(iconCode)\(size.suffix).png"
        return URL(string: urlString)
    }
}

public struct City: Identifiable, Codable, Equatable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var countryCode: String
    
    public init(
        id: UUID = UUID(),
        name: String,
        countryCode: String
    ) {
        self.id = id
        self.name = name
        self.countryCode = countryCode
    }
    
    public static func == (lhs: City, rhs: City) -> Bool {
        return lhs.name.lowercased() == rhs.name.lowercased() &&
        lhs.countryCode.lowercased() == rhs.countryCode.lowercased()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name.lowercased())
        hasher.combine(countryCode.lowercased())
    }
}

public struct WeatherReport: Identifiable, Codable, Equatable {
    public var id: UUID
    public var city: City
    public var weatherData: WeatherAPIResponse
    
    public init(
        id: UUID = UUID(),
        city: City,
        weatherData: WeatherAPIResponse
    ) {
        self.id = id
        self.city = city
        self.weatherData = weatherData
    }
    
    public static func == (lhs: WeatherReport, rhs: WeatherReport) -> Bool {
        lhs.id == rhs.id
    }
}

public struct WeatherAPIResponse: Codable, Sendable {
    public let coordinates: Coordinates?
    public let weatherConditions: [WeatherCondition]
    public let baseStation: String
    public let atmosphericData: AtmosphericData
    public let visibilityMeters: Int
    public let wind: WindData
    public let precipitation: PrecipitationData?
    public let cloudCoverage: CloudCoverage
    public let timestamp: Int
    public let systemInfo: SystemInfo
    public let timezoneOffset: Int
    public let locationId: Int
    public let locationName: String
    public let statusCode: Int
    
    enum CodingKeys: String, CodingKey {
        case coordinates = "coord"
        case weatherConditions = "weather"
        case baseStation = "base"
        case atmosphericData = "main"
        case visibilityMeters = "visibility"
        case wind
        case precipitation = "rain"
        case cloudCoverage = "clouds"
        case timestamp = "dt"
        case systemInfo = "sys"
        case timezoneOffset = "timezone"
        case locationId = "id"
        case locationName = "name"
        case statusCode = "cod"
    }
}

public struct Coordinates: Codable, Sendable {
    public let longitude: Double
    public let latitude: Double
    
    enum CodingKeys: String, CodingKey {
        case longitude = "lon"
        case latitude = "lat"
    }
}

public struct WeatherCondition: Codable, Sendable, Equatable, IconProviding {
    public let conditionId: Int
    public let groupName: String
    public let description: String
    public let iconCode: String

    enum CodingKeys: String, CodingKey {
        case conditionId = "id"
        case groupName = "main"
        case description
        case iconCode = "icon"
    }
}

public struct AtmosphericData: Codable, Sendable {
    public let temperature: Double
    public let feelsLikeTemperature: Double
    public let minTemperature: Double
    public let maxTemperature: Double
    public let pressureHPa: Int
    public let humidityPercent: Int
    public let seaLevelPressure: Int?
    public let groundLevelPressure: Int?
    
    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case feelsLikeTemperature = "feels_like"
        case minTemperature = "temp_min"
        case maxTemperature = "temp_max"
        case pressureHPa = "pressure"
        case humidityPercent = "humidity"
        case seaLevelPressure = "sea_level"
        case groundLevelPressure = "grnd_level"
    }
}

public struct WindData: Codable, Sendable {
    public let speedMetersPerSecond: Double
    public let directionDegrees: Int
    public let gustMetersPerSecond: Double?
    
    enum CodingKeys: String, CodingKey {
        case speedMetersPerSecond = "speed"
        case directionDegrees = "deg"
        case gustMetersPerSecond = "gust"
    }
}

public struct PrecipitationData: Codable, Sendable {
    public let lastHourMM: Double?
    
    enum CodingKeys: String, CodingKey {
        case lastHourMM = "1h"
    }
}

public struct CloudCoverage: Codable, Sendable {
    public let coveragePercent: Int
    
    enum CodingKeys: String, CodingKey {
        case coveragePercent = "all"
    }
}

public struct SystemInfo: Codable, Sendable {
    public let type: Int?
    public let systemId: Int?
    public let countryCode: String
    public let sunriseTimestamp: Int
    public let sunsetTimestamp: Int
    
    enum CodingKeys: String, CodingKey {
        case type
        case systemId = "id"
        case countryCode = "country"
        case sunriseTimestamp = "sunrise"
        case sunsetTimestamp = "sunset"
    }
}

public struct LocationData: Codable, Equatable {
    public let city: String
    public let latitude: Double
    public let longitude: Double
    
    public init(city: String, latitude: Double, longitude: Double) {
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
    }
}

public enum TemperatureUnit: String {
    case celsius
    case fahrenheit

    public var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
}

public struct DailyWeatherSummary: Codable, Sendable, IconProviding {
    public let date: String
    public let tempMin: Double
    public let tempMax: Double
    public let weather: String
    public let description: String
    public let icon: String

    public var iconCode: String { icon }

    public init(date: String, tempMin: Double, tempMax: Double, weather: String, description: String, icon: String) {
        self.date = date
        self.tempMin = tempMin
        self.tempMax = tempMax
        self.weather = weather
        self.description = description
        self.icon = icon
    }
}

public extension WeatherAPIResponse {
    public static let mock = WeatherAPIResponse(
        coordinates: Coordinates(longitude: -118.2437, latitude: 34.0522),
        weatherConditions: [
            WeatherCondition(
                conditionId: 800,
                groupName: "Clear",
                description: "clear sky",
                iconCode: "01d"
            )
        ],
        baseStation: "stations",
        atmosphericData: AtmosphericData(
            temperature: 295.15,
            feelsLikeTemperature: 297.15,
            minTemperature: 293.15,
            maxTemperature: 298.15,
            pressureHPa: 1013,
            humidityPercent: 65,
            seaLevelPressure: 1013,
            groundLevelPressure: 1009
        ),
        visibilityMeters: 10000,
        wind: WindData(
            speedMetersPerSecond: 3.5,
            directionDegrees: 230,
            gustMetersPerSecond: 5.2
        ),
        precipitation: nil,
        cloudCoverage: CloudCoverage(coveragePercent: 0),
        timestamp: 1692112800,
        systemInfo: SystemInfo(
            type: 1,
            systemId: 5856,
            countryCode: "US",
            sunriseTimestamp: 1692097200,
            sunsetTimestamp: 1692148800
        ),
        timezoneOffset: -28800,
        locationId: 5368361,
        locationName: "Los Angeles",
        statusCode: 200
    )
}
