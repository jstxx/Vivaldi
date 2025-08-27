//
//  VivaldiAPIClient.swift
//  VivaldiAPIClient
//
//  Created by Justin SL on 8/14/25.
//
//  This package provides a clean interface to the OpenWeather API.
//  It handles authentication, error mapping, and data transformation
//  for both current weather and forecast data.

import Foundation
import VivaldiModels

/// Protocol defining the interface for weather data providers.
/// This abstraction allows for easy testing and alternative implementations.
public protocol WeatherProviding {
    /// Fetches current weather conditions for a given city
    /// - Parameter city: The city to fetch weather for
    /// - Returns: Complete weather response from the API
    /// - Throws: WeatherAPIError if the request fails
    func fetchWeather(for city: City) async throws -> WeatherAPIResponse

    /// Fetches 5-day weather forecast for a given city
    /// - Parameter city: The city to fetch forecast for
    /// - Returns: Array of daily weather summaries
    /// - Throws: WeatherAPIError if the request fails
    func fetchForecast(for city: City) async throws -> [DailyWeatherSummary]
}

public struct VivaldiAPIClient: WeatherProviding {
    /// OpenWeather API key for authentication
    private let apiKey: String

    /// Base URL for current weather API endpoint
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"

    /// Base URL for 5-day forecast API endpoint
    private let forecastURL = "https://api.openweathermap.org/data/2.5/forecast"

    /// Initialize the API client with your OpenWeather API key
    /// - Parameter apiKey: Your OpenWeather API key obtained from https://openweathermap.org/api
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func fetchForecast(for city: City) async throws -> [DailyWeatherSummary] {
        let urlString = "\(forecastURL)?q=\(city.name)&appid=\(apiKey)"
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299: break
            case 401:
                throw WeatherAPIError(cod: .unauthorized, message: "Invalid API key")
            case 404:
                throw WeatherAPIError(cod: .cityNotFound, message: "Forecast not found")
            default:
                if let errorResponse = try? JSONDecoder().decode(WeatherAPIError.self, from: data) {
                    throw errorResponse
                } else {
                    throw WeatherAPIError(cod: .other("\(httpResponse.statusCode)"), message: "\(httpResponse.statusCode)")
                }
            }
        }
        return try parse5DayForecast(data: data)
    }
    
    /// Parses the raw forecast API response into a structured 5-day forecast
    /// Groups 3-hourly forecasts by date and calculates daily summaries
    private func parse5DayForecast(data: Data) throws -> [DailyWeatherSummary] {
        // Parse JSON response
        let decoded = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        guard let list = decoded?["list"] as? [[String: Any]] else {
            throw WeatherAPIError(cod: .other("No list in response"), message: "Malformed forecast data")
        }

        // Group forecast entries by date (YYYY-MM-DD format)
        var grouped: [String: [[String: Any]]] = [:]
        for entry in list {
            if let dtTxt = entry["dt_txt"] as? String {
                let date = String(dtTxt.prefix(10)) // Extract date part only
                grouped[date, default: []].append(entry)
            }
        }

        // Process each day's entries into a summary
        var daily: [DailyWeatherSummary] = []
        for (date, entries) in grouped.sorted(by: { $0.key < $1.key }).prefix(5) {
            // Calculate temperature range for the day
            let temps: [Double] = entries.compactMap { ($0["main"] as? [String: Any])?["temp"] as? Double }
            let minTemp = temps.min() ?? 0.0
            let maxTemp = temps.max() ?? 0.0

            // Determine most frequent weather condition
            var conditionCounter: [String: Int] = [:]
            var descriptionSample: String = ""
            var iconSample: String = ""
            for entry in entries {
                if let weatherArr = entry["weather"] as? [[String: Any]],
                    let weather = weatherArr.first {
                    let main = weather["main"] as? String ?? ""
                    let desc = weather["description"] as? String ?? ""
                    let icon = weather["icon"] as? String ?? ""

                    conditionCounter[main, default: 0] += 1
                    if descriptionSample.isEmpty { descriptionSample = desc }
                    if iconSample.isEmpty { iconSample = icon }
                }
            }
            let mainWeather = conditionCounter.max(by: { $0.value < $1.value })?.key ?? ""
            daily.append(.init(date: date, tempMin: minTemp, tempMax: maxTemp, weather: mainWeather, description: descriptionSample, icon: iconSample))
        }
        return daily
    }
    
    public func fetchWeather(for city: City) async throws -> WeatherAPIResponse {
        let cityQuery = city.countryCode.isEmpty ? city.name : "\(city.name),\(city.countryCode)"
        let urlString = "\(baseURL)?q=\(cityQuery)&appid=\(apiKey)"
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                throw WeatherAPIError(cod: .unauthorized, message: "Invalid API key")
            case 404:
                throw WeatherAPIError(cod: .cityNotFound, message: "City '\(city.name)' not found")
            default:
                if let errorResponse = try? JSONDecoder().decode(WeatherAPIError.self, from: data) {
                    throw errorResponse
                } else {
                    throw WeatherAPIError(cod: .other("\(httpResponse.statusCode)"), message: "HTTP \(httpResponse.statusCode)")
                }
            }
        }
        let decoder = JSONDecoder()
        return try decoder.decode(WeatherAPIResponse.self, from: data)
    }
}


/// Status codes returned by the OpenWeather API
/// Maps raw HTTP status codes to semantic meanings for better error handling
public enum WeatherAPIStatusCode: Equatable, Sendable {
    case ok
    case cityNotFound
    case unauthorized
    case other(String)

    /// Initialize from raw API response code string
    public init(rawValue: String) {
        switch rawValue {
        case "200": self = .ok
        case "404": self = .cityNotFound
        case "401": self = .unauthorized
        default: self = .other(rawValue)
        }
    }
}

public struct WeatherAPIError: Codable, LocalizedError {
    /// The error code mapped to a semantic status
    public let cod: WeatherAPIStatusCode

    /// Raw error message from the API
    public let message: String

    public init(cod: WeatherAPIStatusCode, message: String) {
        self.cod = cod
        self.message = message
    }

    /// User-friendly error description for display in UI
    public var errorDescription: String? {
        switch cod {
        case .cityNotFound:
            return "City not found. Please try again."
        case .unauthorized:
            return "Weather unavailable."
        case .ok:
            return nil
        case .other(let code):
            return "Weather error (\(code)). Please try again."
        }
    }

    /// Detailed error information for debugging
    public var failureReason: String? {
        return message
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawCod = try container.decode(String.self, forKey: .cod)
        cod = WeatherAPIStatusCode(rawValue: rawCod)
        message = try container.decode(String.self, forKey: .message)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch cod {
        case .ok: try container.encode("200", forKey: .cod)
        case .cityNotFound: try container.encode("404", forKey: .cod)
        case .unauthorized: try container.encode("401", forKey: .cod)
        case .other(let value): try container.encode(value, forKey: .cod)
        }
        try container.encode(message, forKey: .message)
    }
    
    enum CodingKeys: String, CodingKey {
        case cod
        case message
    }
}
