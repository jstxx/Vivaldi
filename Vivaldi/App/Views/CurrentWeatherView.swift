//
//  CurrentWeatherView.swift
//  Vivaldi
//
//  Created by Justin SL on 8/17/25.
//

import SwiftUI
import VivaldiModels
import VivaldiDesignSystem

struct CurrentWeatherView: View {
    let city: City
    let weather: WeatherAPIResponse?
    let forecast: [DailyWeatherSummary]?
    let isLoading: Bool
    let temperatureUnit: TemperatureUnit
    
    @State private var countsDown: Bool = false
    
    var body: some View {
       
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                if isLoading == false {
                    Image(systemName: "location.fill")
                        .foregroundStyle(Colors.systemBlue)
                        .font(.largeTitle)
                }
                Text(city.name)
                    .accessibilityLabel("City: \(city.name)")
                    .cardTitle()
            }
            .frame(maxWidth:.infinity, alignment: .center)
            .padding(.top, 8)
            temperatureView
            HStack(alignment: .center, spacing: 8) {
                weatherDescriptionView
                windDescriptionView
            }
            Divider()
                .padding(.vertical, 8)
            FiveDayForecastView(forecast: forecast, temperatureUnit: temperatureUnit)
        }
    }
    
    @ViewBuilder
    private var temperatureView: some View {
        if isLoading {
            ProgressView()
                .tint(Colors.accent)
                .scaleEffect(1.5)
        } else if let temp = weather?.atmosphericData.temperature {
            let tempCelsius = temp - 273.15
            let temperatureText = displayTemperature(temperatureUnit: temperatureUnit, kelvin: temp)
            HStack(alignment: .center, spacing: 0) {
                weatherIconMainView
                Text(temperatureText)
                    .font(.system(size: 72, weight: .heavy, design: .rounded))
                    .foregroundStyle(tempCelsius > 26 ? Colors.redGradient : Colors.blueGradient)
                    .monospacedDigit()
                    .shadow(color: Colors.whiteOpacity20, radius: 10, x: 0, y: 0)
                    .contentTransition(.numericText(countsDown: countsDown))
                    .onChange(of: temp) { oldTemp, newTemp in
                        countsDown = newTemp < oldTemp
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: temperatureUnit)
                    .accessibilityLabel("Temperature: \(temperatureText)")
            }
            .frame(maxWidth:.infinity, alignment: .center)
        } else {
            Text("-°")
                .font(.system(size: 72, weight: .heavy, design: .rounded))
                .applyPlaceholderStyle()
        }
    }
    
    @ViewBuilder
    private var weatherDescriptionView: some View {
        if isLoading {
            // only show one loading view
            EmptyView()
        } else if let condition = weather?.weatherConditions.first {
            Text(condition.description.capitalized)
                .font(.title3)
                .foregroundColor(Colors.textPrimary.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.top, 4)
                .accessibilityLabel("Weather is: \(condition.description.capitalized)")
        } else {
            Text("No weather data available")
                .font(.title3)
                .foregroundColor(Colors.textPrimary.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
    }
    
    @ViewBuilder
    private var weatherIconMainView: some View {
        if isLoading {
            ProgressView()
                .tint(Colors.accent)
                .scaleEffect(2)
        } else if let condition = weather?.weatherConditions.first,
                  let iconURL = condition.iconURL(size: .large) {
            AsyncImage(url: iconURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
                    .tint(Colors.accent)
            }
            .frame(maxHeight: 120)
        } else {
            Image(systemName: "questionmark.circle.fill")
                .resizable()
                .foregroundStyle(Colors.grayForeground)
                .frame(width: 100, height: 100)
        }
    }
    
    @ViewBuilder
    private var windDescriptionView: some View {
        if isLoading {
            EmptyView()
        } else if let speed = weather?.wind.speedMetersPerSecond {
            HStack(spacing: 6) {
                Image(systemName: "wind")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(Colors.textPrimary.opacity(0.8))
                Text(String(format: "%.0f m/s", speed))
                    .font(.subheadline)
                    .foregroundColor(Colors.textPrimary.opacity(0.8))
            }
            .padding(.top, 8)
        } else {
            EmptyView()
        }
    }
}

#Preview("Loaded") {
    CurrentWeatherView(city: City(name: "Los Angeles",
                                  countryCode: "US") ,
                       weather: .mock,
                       forecast: nil,
                       isLoading: false,
                       temperatureUnit: .fahrenheit)
}

#Preview("Loading") {
    CurrentWeatherView(city: City(name: "Los Angeles",
                                  countryCode: "US") ,
                       weather: .mock, forecast: nil,
                       isLoading: true,
                       temperatureUnit: .fahrenheit)
}
