//
//  HomeView.swift
//  Vivaldi
//
//  Created by Justin SL on 8/14/25.
//

import SwiftUI
import VivaldiModels
import VivaldiAPIClient
import VivaldiDesignSystem
import Observation

struct HomeView: View {
    @State private var feedInteractor = FeedInteractor()
    @Bindable var locationInteractor: LocationInteractor

    @State private var showingAddCity = false
    @State private var showingSettingsPopover = false

    var body: some View {
        NavigationStack {
            List {
                LocationWeatherDisplay(
                    locationInteractor: locationInteractor,
                    temperatureUnit: feedInteractor.temperatureUnit
                )

                Section("My Cities") {
                    cityRows
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 22, bottom: 0, trailing: 16))
            }
            .listStyle(.plain)
            .background(Colors.pageBackground.gradient)
            .scrollContentBackground(.hidden)
            .navigationTitle("")
            .toolbar {
                WeatherFeedToolbarContent(
                    feedInteractor: feedInteractor,
                    showingAddCity: $showingAddCity,
                    showingSettingsPopover: $showingSettingsPopover
                )
            }
            .toolbarBackground(Colors.blueFadedOutGradient, for: .navigationBar)
            .refreshable {
                await feedInteractor.refreshWeatherFeed()
                if locationInteractor.status == .authorizedWhenInUse || locationInteractor.status == .authorizedAlways {
                    locationInteractor.startLocationUpdates()
                }
            }
            .task {
                await feedInteractor.loadWeatherFeed()
                if locationInteractor.status == .authorizedWhenInUse || locationInteractor.status == .authorizedAlways {
                    locationInteractor.startLocationUpdates()
                }
            }
            .onChange(of: locationInteractor.status) { oldStatus, newStatus in
                if (oldStatus != .authorizedWhenInUse && oldStatus != .authorizedAlways) &&
                    (newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways) {
                    locationInteractor.startLocationUpdates()
                } else if (newStatus == .denied || newStatus == .restricted) &&
                            (oldStatus == .authorizedWhenInUse || oldStatus == .authorizedAlways) {
                    locationInteractor.stopLocationUpdates()
                    locationInteractor.clearLocationData()
                }
            }
            .sheet(isPresented: $showingAddCity) {
                AddCityView(isPresented: $showingAddCity) { newCity in
                    feedInteractor.addCity(newCity)
                }
                .presentationDetents([.medium])
            }
        }
    }

    @ViewBuilder
    private var cityRows: some View {
        ForEach(feedInteractor.savedCities) { city in
            NavigationLink {
                CurrentWeatherView(
                    city: city,
                    weather: feedInteractor.cityWeather[city],
                    forecast: feedInteractor.cityForecasts[city],
                    isLoading: false,
                    temperatureUnit: feedInteractor.temperatureUnit
                )
                .padding()
                .frame(maxHeight: .infinity)
                .background(Colors.blueFadedOutGradient)
                .task {
                    if feedInteractor.cityForecasts[city] == nil {
                        await feedInteractor.loadForecast(for: city)
                    }
                }
                .navigationTitle("Current Weather")

            } label: {
                WeatherCityCard(
                    city: city,
                    weather: feedInteractor.weather(for: city),
                    isLoading: feedInteractor.isLoadingWeather && !feedInteractor.hasWeather(for: city),
                    isCurrentLocation: false, temperatureUnit: feedInteractor.temperatureUnit
                )

            }
            .listRowInsets(EdgeInsets(top: 6, leading: 18, bottom: 6, trailing: 18))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            // so we can customize the swipe to delete function
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    deleteCity(at: city)
                } label: {
                    Label("Remove", systemImage: "icloud.slash.fill")
                }
                .tint(Colors.accent)
            }

        }
        // so we can still use the native EditButton functionality
        .onDelete(perform: deleteCities)
    }
    
    private func deleteCity(at city: City) {
        feedInteractor.removeCity(city)
    }
    
    private func deleteCities(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            let city = feedInteractor.savedCities[index]
            deleteCity(at: city)
        }
    }
}

struct LocationWeatherDisplay: View {
    @Bindable var locationInteractor: LocationInteractor
    var temperatureUnit: TemperatureUnit
    
    var body: some View {
        Group {
            switch locationInteractor.status {
            case .notDetermined:
                Button("Get My Weather") {
                    locationInteractor.requestPermission()
                }
                .buttonStyle(PrimaryButtonStyle())
                .listRowInsets(EdgeInsets(top: 32, leading: 16, bottom: 8, trailing: 16))
            case .authorizedWhenInUse, .authorizedAlways:
                if let weatherData = locationInteractor.currentLocationWeatherData {
                    CurrentWeatherView(
                        city: weatherData.city,
                        weather: weatherData.response,
                        forecast:locationInteractor.currentLocationForecast,
                        isLoading: false,
                        temperatureUnit: temperatureUnit
                    )
                } else {
                    ProgressView("Gathering weather data")
                        .listRowInsets(EdgeInsets(top: 32, leading: 16, bottom: 8, trailing: 16))
                        .frame(maxWidth: .infinity, alignment:.center)
                }
            case .denied, .restricted:
                VStack(spacing: 12) {
                    LocationStatusView(text: "Please update your settings to see your current weather", symbol: "location.slash", color: .yellow)
                        .cornerRadius(12)
                    Button("Change Location Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                }
            @unknown default:
                EmptyView()
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

#Preview("Home") {
    HomeView(locationInteractor: LocationInteractor())
}
