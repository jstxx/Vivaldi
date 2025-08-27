//
//  SymbolBurstView.swift
//  Vivaldi
//
//  Created by Justin SL on 8/16/25.
//

import SwiftUI

struct SymbolBurstView: ViewModifier {
    @Binding var isActive: Bool
    
    var emojis: [String]
    var angles: [Double] = [0, 90, 180, 270]
    var radius: CGFloat = 120
    var emojiSize: CGFloat = 60
    
    @State private var didPop = false
    @State private var rotationTrigger: Double = 0.0
    
    func body(content: Content) -> some View {
        ZStack {
            content
            ForEach(emojis.indices, id: \.self) { i in
                Text(Image(systemName:emojis[i]))
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(Color.white.opacity(0.1))
                    .font(.system(size: emojiSize))
                    .scaleEffect(didPop ? 1 : 0)
                    .opacity(didPop ? 1 : 0)
                    .offset(y: didPop ? -radius : 0)
                    .rotationEffect(.degrees(angles[safe: i] ?? defaultAngle(for: i)))
                    // continuous spin
                    .rotationEffect(.degrees(rotationTrigger))
                    // pop out animation
                    .animation(
                        .spring(duration: 3.85, bounce: 0.2, blendDuration: 6)
                        .delay(0.4 * Double(i)),
                        value: didPop
                    )
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: isActive) { _, now in
            handleActiveStateChange(now)
        }
        .onAppear {
            handleActiveStateChange(isActive)
        }
    }
    
    private func handleActiveStateChange(_ active: Bool) {
        if active {
            didPop = false
            withAnimation(.easeOut(duration: 3.85)) {
                didPop = true
            }
            // sarts a long-duration animation
            DispatchQueue.main.async {
                self.rotationTrigger = 0
                withAnimation(.linear(duration: 120.0).repeatForever(autoreverses: false)) {
                    self.rotationTrigger = 360.0
                }
            }
            
        } else {
            // reset when the view disappears
            didPop = false
            rotationTrigger = 0.0
        }
    }
    
    private func defaultAngle(for index: Int) -> Double {
        guard emojis.count > 0 else { return 0 }
        return Double(index) / Double(emojis.count) * 360.0
    }
}

extension View {
    func symbolBurst(
        isActive: Binding<Bool>,
        symbols: [String],
        angles: [Double] = [0, 90, 180, 270],
        radius: CGFloat = 120,
        emojiSize: CGFloat = 60
    ) -> some View {
        modifier(SymbolBurstView(
            isActive: isActive,
            emojis: symbols,
            angles: angles,
            radius: radius,
            emojiSize: emojiSize
        ))
    }
}
