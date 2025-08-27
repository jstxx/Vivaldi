//
//  Formatters.swift
//  Vivaldi
//
//  Created by Justin SL on 8/17/25.
//

import Foundation
import SwiftUI
import VivaldiModels

extension View {
    func displayTemperature(temperatureUnit: TemperatureUnit, kelvin: Double?) -> String {
        guard let kelvin = kelvin else { return "-" }
        let tempC = kelvin - 273.15
        switch temperatureUnit {
        case .celsius:
            return String(format: "%.0f%@", tempC, TemperatureUnit.celsius.symbol)
        case .fahrenheit:
            let tempF = tempC * 9 / 5 + 32
            return String(format: "%.0f%@", tempF, TemperatureUnit.fahrenheit.symbol)
        }
    }
    
    public func shortDayString(from date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "E"
        if let dateObj = formatter.date(from: date) {
            return weekdayFormatter.string(from: dateObj)
        }
        return ""
    }
}

public extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
