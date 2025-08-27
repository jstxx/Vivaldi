//
//  OnboardingItem.swift
//  Vivaldi
//
//  Created by Justin SL on 8/14/25.
//

import Foundation
import SwiftUI
import CoreLocation

struct OnboardingItem: Identifiable {
    let id: UUID
    let type: PageType
    let header: String?
    let title: String
    let description: String
    let symbol: String
    let symbols: [String]
    
    enum PageType {
        case info
        case locationPermission
        case finished
    }
    
    init(type: PageType = .info,
         header: String? = "",
         title: String,
         description: String,
         symbol: String,
         symbols: [String]) {
        self.id = UUID()
        self.type = type
        self.header = header
        self.title = title
        self.description = description
        self.symbol = symbol
        self.symbols = symbols
    }
}

extension OnboardingItem {
    static let pages: [OnboardingItem] = [
        .init(
            header: "Vivaldi",
            title: "Weather The Seasons",
            description: "Experience current conditions from all your favorite places, all at once",
            symbol: "drop.degreesign",
            symbols: ["cloud","cloud.rain","sun.snow","sun.dust"]
        ),
        .init(
            type: .locationPermission,
            title: "Where Art Tho?",
            description: "To provide accurate local forecasts, we need your permission for your location.",
            symbol: "location.circle.fill",
            symbols: ["wind","snowflake","cloud.moon","cloud.snow"]

        ),
        .init(
            type: .finished,
            title: "Here we go!",
            description: "Rain or shine, please enjoy accurate and timely weather updates.",
            symbol: "sun.max.circle.fill",
            symbols: ["humidity","cloud.bolt","cloud.moon.bolt.fill","cloud.fog"]
        )
    ]
}
