//
//  VivaldiModels.swift
//
//
//  Created by Justin SL on 8/14/25.
//

import Foundation
import SwiftUI

public struct Typography {
    public static var mainHeading: Font { .system(size: 34, weight: .bold) }
    public static var tempDisplay: Font { .system(size: 32, weight: .bold) }
    public static var confirmationDisplay: Font { .system(size: 20, weight: .bold) }
    
    public static var body: Font { .system(size: 17) }
    public static var pageHeading: Font { .system(size: 55, weight: .bold) }
    
    public static var mediumIcon: Font { .system(size: 30, weight: .regular) }
    
    public static var headline: Font { .headline }
    public static var headlineSemibold: Font { .system(.headline, design: .default).weight(.semibold) }
    public static var caption: Font { .caption }
    public static var captionSemibold: Font { .system(.caption, design: .default).weight(.semibold) }
    public static var title2Bold: Font { .system(.title2, design: .default).weight(.bold) }
    public static var logo: Font {.custom("AcademyEngravedLetPlain", size: 66) }
    
    private init() {}
}

public extension Text {
    public func applyMainHeadingStyle() -> some View {
        self.font(Typography.mainHeading)
            .foregroundColor(Colors.textPrimary)
    }
    public func cardTitle() -> some View {
        self.font(.largeTitle)
            .multilineTextAlignment(.center)
            .bold()
            .foregroundColor(Colors.textPrimary)
    }
    
    public func applyBodyStyle() -> some View {
        self.font(Typography.body)
            .foregroundColor(Colors.textSecondary)
    }
    
    public func headlineSemiboldStyle() -> some View {
        self.font(Typography.headlineSemibold)
            .foregroundColor(Colors.textPrimary)
    }
    
    public func applyCaptionStyle() -> some View {
        self.font(Typography.caption)
            .foregroundColor(Colors.textPrimary)
    }
    
    public func applyCaptionDimmedStyle() -> some View {
        self.font(Typography.caption)
            .foregroundColor(Colors.textPrimary.opacity(0.8)) // For weather description, wind speed
    }
    
    public func applyTemperatureDisplayStyle() -> some View {
        self.font(Typography.tempDisplay)
            .fontWeight(.bold)
            .foregroundStyle(Colors.blueGradient)
            .monospacedDigit()
            .shadow(color: Colors.whiteOpacity20, radius: 10, x: 0, y: 0)
    }
    
    public func applyHotTemperatureDisplayStyle() -> some View {
        self.font(Typography.tempDisplay)
            .fontWeight(.bold)
            .foregroundStyle(Colors.blueGradient)
            .monospacedDigit()
            .shadow(color: Colors.whiteOpacity20, radius: 10, x: 0, y: 0)
    }
    
    public func applyPlaceholderStyle() -> some View {
        self.font(Typography.title2Bold)
            .foregroundStyle(Colors.whiteOpacity50)
    }
}

public struct Colors {
    public static let accent = Color("Accent", bundle: .module)
    public static let pageBackground = Color("PageBackground", bundle: .module)
    
    public static var textPrimary: Color { .primary }
    public static var textSecondary: Color { .secondary }
    
    public static let toolbarMaterial = Material.ultraThinMaterial
    
    public static let systemBlue = Color.blue
    
    public static let blueGradient = LinearGradient(
        colors: [.blue, .cyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let blueFadedOutGradient = LinearGradient(
        colors: [.blue.opacity(0.8), .cyan.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let purpleGradient = LinearGradient(
        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let tealGradient = LinearGradient(
        colors: [.teal, .white],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let orangeGradient = LinearGradient(
        colors: [.orange, .yellow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    
    public static let redGradient = LinearGradient(
        colors: [.red, .orange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let cardShadow = Color.black.opacity(0.1)
    public static let ultraThinMaterial = Material.ultraThin
    public static let whiteOpacity20 = Color.white.opacity(0.2)
    public static let whiteOpacity50 = Color.white.opacity(0.5)
    public static let grayForeground = Color.gray
    public static let progressTintWhite = Color.white
    
    private init() {}
}

public struct SimpleField: TextFieldStyle {
    public init() {}
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Colors.whiteOpacity20, lineWidth: 1)
            }
    }
}
