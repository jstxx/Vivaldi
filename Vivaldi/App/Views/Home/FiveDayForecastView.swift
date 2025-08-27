//
//  ForecastView.swift
//  Vivaldi
//
//  Created by Justin SL on 8/18/25.
//

import SwiftUI
import VivaldiModels
import VivaldiDesignSystem

struct FiveDayForecastView: View {
    let forecast: [DailyWeatherSummary]?
    let temperatureUnit: TemperatureUnit

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let forecast = forecast {
                HStack(spacing: 10) {
                    ForEach(forecast.prefix(5), id: \.date) { day in
                        VStack(spacing: 0) {
                            Text(shortDayString(from: day.date))
                                .applyCaptionDimmedStyle()
                            weatherIconView(for: day)
                                .frame(width: 40, height: 40)
                            Text(displayTemperature(temperatureUnit: temperatureUnit, kelvin: day.tempMax))
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .font(.body)
                                .fontWeight(.semibold)
                                .contentTransition(.numericText(countsDown: false))

                            Text(displayTemperature(temperatureUnit: temperatureUnit, kelvin: day.tempMin))
                                .applyCaptionDimmedStyle()
                                .contentTransition(.numericText(countsDown: false))

                        }
                        .animation(.spring(), value: temperatureUnit)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(.thinMaterial)
                        .cornerRadius(10)
                    }
                }
            } else {
                EmptyView()
            }
        }
        .padding(.vertical, 8)
    }


    @ViewBuilder
    private func weatherIconView(for day: DailyWeatherSummary, size: IconSize = .standard) -> some View {
        if let url = day.iconURL(size: size) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    FiveDayForecastView(
        forecast: [
            DailyWeatherSummary(date: "2025-08-18", tempMin: 290, tempMax: 300, weather: "Clouds", description: "broken clouds", icon: "03d"),
            DailyWeatherSummary(date: "2025-08-19", tempMin: 288, tempMax: 295, weather: "Rain", description: "light rain", icon: "10d"),
            DailyWeatherSummary(date: "2025-08-20", tempMin: 285, tempMax: 291, weather: "Clear", description: "clear sky", icon: "01d"),
            DailyWeatherSummary(date: "2025-08-21", tempMin: 287, tempMax: 293, weather: "Clouds", description: "scattered clouds", icon: "02d"),
            DailyWeatherSummary(date: "2025-08-22", tempMin: 289, tempMax: 294, weather: "Clear", description: "clear sky", icon: "01d")
        ],
        temperatureUnit: .celsius
    )
}
