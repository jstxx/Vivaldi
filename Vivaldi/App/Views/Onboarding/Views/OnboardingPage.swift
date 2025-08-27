//
//  OnboardingPage.swift
//  Vivaldi
//
//  Created by Justin SL on 8/14/25.
//

import SwiftUI
import VivaldiDesignSystem
import VivaldiPersistence

struct OnboardingPage: View {
    let item: OnboardingItem
    let pageIndex: Int
    @Binding var currentSelection: Int
    private var isCurrentPageActive: Bool { currentSelection == pageIndex }
    let locationInteractor: LocationInteractor
    
    var body: some View {
        VStack(spacing: 20) {
            if let header = item.header {
                Text(header)
                    .font(Typography.logo)
                    .bold()
                    .foregroundStyle(Colors.pageBackground)
            }
            Spacer()
            ZStack {
                Rectangle()
                    .fill(
                        Colors.purpleGradient
                    )
                    .frame(width: 180, height: 180)
                    .cornerRadius(24)
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 180, height: 180)
                    .cornerRadius(24)
                    .mask(
                        Rectangle()
                            .overlay(
                                Image(systemName: item.symbol)
                                    .font(.system(size: 120))
                                    .blendMode(.destinationOut)
                            )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .symbolBurst(
                isActive: Binding(
                    get: { self.isCurrentPageActive },
                    set: { _ in }
                ),
                symbols: item.symbols,
                angles: [],
                radius: 148,
                emojiSize: 60
            )
            Spacer()
            Text(item.title)
                .multilineTextAlignment(.center)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
            
            HStack(alignment: .center, spacing: 4) {
                Image(systemName: "laurel.leading")
                    .font(.system(size: 42))
                    .foregroundStyle(Color.white)
                    .alignmentGuide(VerticalAlignment.center) { d in
                        d[VerticalAlignment.center]
                    }
                Spacer()
                Text(item.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundStyle(Color.white.gradient)
                    .alignmentGuide(VerticalAlignment.center) { d in
                        d[VerticalAlignment.center]
                    }
                Spacer()
                Image(systemName: "laurel.trailing")
                    .font(.system(size: 42))
                    .foregroundStyle(Color.white)
            }
            ctaView
                .padding(.vertical, 40)
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private var ctaView: some View {
        switch item.type {
        case .info:
            EmptyView()
        case .locationPermission:
            LocationPermissionCTA(interactor: locationInteractor)
        case .finished:
            FinishedOnboardingCTA()
        }
    }
}

struct FinishedOnboardingCTA: View {
    
    var body: some View {
        Button("Browse Weather", action: {
            VivaldiPersistence.completedOnboarding = true
        })
        .buttonStyle(PrimaryButtonStyle())
    }
}

struct LocationPermissionCTA: View {
    @Bindable var interactor: LocationInteractor
    
    var body: some View {
        switch interactor.status {
        case .notDetermined:
            Button("Allow Location") {
                interactor.requestPermission()
            }
            .buttonStyle(PrimaryButtonStyle())
            
        case .authorizedWhenInUse, .authorizedAlways:
            VStack(spacing: 16) {
                LocationStatusView(text: "Ready to Go!")
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(                                Colors.blueGradient.opacity(0.2), lineWidth: 1)
                    }
            }
            .shadow(color: .white.opacity(0.15), radius: 20, x: 0, y: 8)
            
        case .denied, .restricted:
            LocationStatusView(text: "We don't know where you are, so we can't show you the weather there. Swipe on to see weather from other places", symbol: "xmark.circle.fill", color: .red)
            
        @unknown default:
            EmptyView()
        }
    }
}

struct LocationStatusView: View {
    let text: String
    var symbol: String = "checkmark.circle.fill"
    var color: Color = Colors.textSecondary
    
    var body: some View {
        HStack {
            Image(systemName: symbol)
                .padding(.leading, 4)
                .font(Typography.mediumIcon)
            
            Text(text)
                .font(Typography.confirmationDisplay)
                .padding(4)
        }
        .foregroundStyle(color)
        .transition(.opacity.animation(.easeInOut))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Colors.blueGradient)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview("Page 1") {
    OnboardingPage(item: OnboardingItem.pages[0],
                   pageIndex: 0,
                   currentSelection: .constant(0),
                   locationInteractor: LocationInteractor())
    .preferredColorScheme(.dark)
}

#Preview("Page 2") {
    OnboardingPage(item: OnboardingItem.pages[1],
                   pageIndex: 1,
                   currentSelection: .constant(0),
                   locationInteractor: LocationInteractor())
    .preferredColorScheme(.dark)
}

#Preview("Page 3") {
    OnboardingPage(item: OnboardingItem.pages[2],
                   pageIndex: 2,
                   currentSelection: .constant(0),
                   locationInteractor: LocationInteractor())
    .preferredColorScheme(.dark)
}
