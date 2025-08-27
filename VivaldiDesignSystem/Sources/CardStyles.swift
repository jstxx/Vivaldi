//
//  File.swift
//  VivaldiDesignSystem
//
//  Created by Justin SL on 8/16/25.
//

import SwiftUI

public struct CardBackgroundModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(Colors.ultraThinMaterial.opacity(0.74))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Colors.whiteOpacity20, .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Colors.cardShadow, radius: 8, x: 0, y: 4)
    }
}

public extension View {
    public func weatherCardStyle() -> some View {
        modifier(CardBackgroundModifier())
    }
}

public struct CardProgressViewStyle: ProgressViewStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .progressViewStyle(CircularProgressViewStyle(tint: Colors.progressTintWhite))
            .scaleEffect(0.8)
    }
}

public struct CardIconFrameModifier: ViewModifier {
    let width: CGFloat
    let height: CGFloat
    
    public func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
    }
}

public extension View {
    public func cardIconFrame(width: CGFloat = 50, height: CGFloat = 50) -> some View {
        modifier(CardIconFrameModifier(width: width, height: height))
    }
}

struct GlassEffectModifier: ViewModifier {
    let tintColor: Color
    let cornerRadius: CGFloat
    let isInteractive: Bool
    
    init(
        tintColor: Color = .clear,
        cornerRadius: CGFloat = 12,
        interactive: Bool = false
    ) {
        self.tintColor = tintColor
        self.cornerRadius = cornerRadius
        self.isInteractive = interactive
    }
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                ZStack {
                    // Base glass background
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    // Tint overlay if specified
                    if tintColor != .clear {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Colors.blueGradient.opacity(0.7))
                    }
                }
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .scaleEffect(isInteractive ? 0.95 : 1.0)
            .animation(.bouncy(duration: 0.3), value: isInteractive)
    }
}

public extension View {
    public func glassEffect(
        tint: Color = .clear,
        cornerRadius: CGFloat = 12,
        interactive: Bool = false
    ) -> some View {
        self.modifier(
            GlassEffectModifier(
                tintColor: tint,
                cornerRadius: cornerRadius,
                interactive: interactive
            )
        )
    }
}
