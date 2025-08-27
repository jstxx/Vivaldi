//
//  WelcomeVIew.swift
//  Vivaldi
//
//  Created by Justin SL on 8/14/25.
//

import SwiftUI
import VivaldiDesignSystem

// The screen users first see when launching the app for the first time
struct WelcomeView: View {
    @Environment(LocationInteractor.self) private var locationInteractor
    @AppStorage("vivaldi_completed_onboarding") private var completedOnboarding = false
    
    @State var selectedPage = 0
    var body: some View {
        if completedOnboarding {
            HomeView(locationInteractor: locationInteractor)
        }
        else {
            TabView(selection: $selectedPage) {
                ForEach(0..<OnboardingItem.pages.count, id: \.self) { idx in
                    OnboardingPage(item: OnboardingItem.pages[idx], pageIndex: idx, currentSelection: $selectedPage, locationInteractor: locationInteractor)
                }
            }
            .background(Colors.pageBackground.gradient)
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }
}

#Preview {
    @Previewable @State var locationInteractor = LocationInteractor()
    WelcomeView().environment(locationInteractor)
}
