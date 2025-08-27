//
//  WeatherCityCard.swift
//  Vivaldi
//
//  Created by Justin SL on 8/15/25.
//

import SwiftUI
import VivaldiModels
import VivaldiDesignSystem

struct WeatherCityCard: View {
    let city: City
    let weather: WeatherAPIResponse?
    let isLoading: Bool
    let isCurrentLocation: Bool
    let temperatureUnit: TemperatureUnit

    @State private var countsDown: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            weatherIconView
            VStack(alignment: .leading, spacing: 4) {
                cityNameView
                weatherDescriptionView
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                temperatureView
            }
        }
        .padding(10)
        .weatherCardStyle()
    }

    // MARK: - Weather Icon

    @ViewBuilder
    private var weatherIconView: some View {
        Group {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CardProgressViewStyle())
            } else if let condition = weather?.weatherConditions.first,
                      let iconURL = condition.iconURL(size: .large) {
                AsyncImage(url: iconURL) { image in
                    image
                        .resizable()
                        .frame(width: 80, height: 80)
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CardProgressViewStyle())
                }
                .cardIconFrame()
            } else {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundStyle(Colors.grayForeground)
                    .font(.system(size: 30))
                    .cardIconFrame()
            }
        }
    }

    // MARK: - City Name

    @ViewBuilder
    private var cityNameView: some View {
        HStack(spacing: 6) {
            Text(city.name)
                .headlineSemiboldStyle()
            if isCurrentLocation {
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundStyle(Colors.blueGradient)
            }
        }
    }

    // MARK: - Weather Description

    @ViewBuilder
    private var weatherDescriptionView: some View {
        if isLoading {
            ProgressView()
                .foregroundStyle(Colors.textPrimary.opacity(0.7))
        } else if let condition = weather?.weatherConditions.first {
            HStack(spacing: 2) {
                Text(condition.description.capitalized)
                    .applyCaptionDimmedStyle()
                    .lineLimit(1)
                windDescriptionView
            }
        } else {
            Text("No data available")
                .applyCaptionDimmedStyle()
        }
    }

    // MARK: - Wind Description
    
    @ViewBuilder
    private var windDescriptionView: some View {
        if isLoading {
            ProgressView()
                .foregroundStyle(Colors.textPrimary.opacity(0.7))
        } else if let speed = weather?.wind.speedMetersPerSecond {
            HStack(spacing: 2) {
                Image(systemName: "wind")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                Text("\(String(format: "%.0f", speed)) m/s")
                    .applyCaptionDimmedStyle()
                    .lineLimit(1)
            }
            
        } else {
            Text("No data available")
                .applyCaptionDimmedStyle()
        }
    }

    // MARK: - Temperature

    @ViewBuilder
    private var temperatureView: some View {
        if isLoading {
            RoundedRectangle(cornerRadius: 8)
                .fill(Colors.whiteOpacity20)
                .frame(width: 50, height: 30)
                .overlay {
                    ProgressView()
                        .progressViewStyle(CardProgressViewStyle())
                }
        } else if let temp = weather?.atmosphericData.temperature {
            let tempCelsius = temp - 273.15
            let temperatureText = displayTemperature(temperatureUnit: temperatureUnit, kelvin: temp)
            
            Text(temperatureText)
                .font(Typography.tempDisplay)
                .fontWeight(.bold)
                .foregroundStyle(tempCelsius > 26 ? Colors.redGradient : Colors.blueGradient)
                .monospacedDigit()
                .shadow(color: Colors.whiteOpacity20, radius: 10, x: 0, y: 0)
                .contentTransition(.numericText(countsDown: countsDown))
                .onChange(of: temp) { oldTemp, newTemp in
                    countsDown = newTemp < oldTemp
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: temperatureUnit)
        } else {
            Text("-°")
                .applyPlaceholderStyle()
        }
    }
}

#Preview {
    WeatherCityCard(city: City(name: "Los Angeles", countryCode: "US"),
                    weather: .mock,
                    isLoading: false,
                    isCurrentLocation: false, temperatureUnit: .fahrenheit)
}
