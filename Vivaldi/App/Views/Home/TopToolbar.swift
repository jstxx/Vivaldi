//
//  TopToolbar.swift
//  Vivaldi
//
//  Created by Justin SL on 8/16/25.
//

import SwiftUI
import VivaldiDesignSystem
import VivaldiModels

struct WeatherFeedToolbarContent: ToolbarContent {
    @State var feedInteractor: FeedInteractor
    @Binding var showingAddCity: Bool
    @Binding var showingSettingsPopover: Bool

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Reset") {
                feedInteractor.resetCities()
                Task {
                    await feedInteractor.loadWeatherFeed()
                }
            }
            .tint(Colors.toolbarMaterial)
            .buttonStyle(.bordered)
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            EditButton()
                .buttonStyle(.bordered)
                .tint(Colors.toolbarMaterial)

            Button("+ City") {
                showingAddCity = true
            }
            .buttonStyle(.bordered)
            .tint(Colors.toolbarMaterial)

            Button {
                showingSettingsPopover.toggle()
            } label: {
                Image(systemName: "thermometer.variable")
            }
            .tint(Colors.toolbarMaterial)
            .buttonStyle(.bordered)
            .popover(isPresented: $showingSettingsPopover) {
                temperatureSettingsPopover
            }
        }
    }

    private var temperatureSettingsPopover: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Temperature Display")
                .font(Typography.headline)
                .padding(.top, 4)
                .frame(maxWidth:.infinity, alignment: .center)
            Picker("Temperature Unit", selection: $feedInteractor.temperatureUnit) {
                Text("Celsius").tag(TemperatureUnit.celsius)
                Text("Fahrenheit").tag(TemperatureUnit.fahrenheit)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .padding(6)
        .presentationCompactAdaptation(.popover)
    }
}
