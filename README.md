# Vivaldi - iOS REST API App Scaffold

A **ready to go iOS application scaffold** built with SwiftUI that demonstrates modern architectural patterns for building apps that consume REST APIs. This project serves as an **educational template** and **starting point** for developers wanting to create iOS apps with clean architecture, proper abstraction layers, and production-ready patterns.

## What This Scaffold Demonstrates

This codebase is a **living example** of how to structure an iOS app that calls REST endpoints, featuring:

- **Clean Architecture** with clear separation of concerns
- **Protocol-oriented programming** for testable, extensible code
- **Swift Package Manager (SPM)** for modular development
- **Interactor Pattern** with SwiftUI's reactive observation framework
- **Background processing** for automatic data refresh
- **Comprehensive error handling** and user experience patterns
- **Design system** implementation with reusable UI components
- **Data persistence** patterns with UserDefaults
- **Dependency injection** through protocol abstractions

The weather functionality serves as a **practical example** of these patterns - showing how to integrate with a real REST API (OpenWeatherMap) while maintaining clean, maintainable code.

## Features

- 🌤️ **Current Weather**: Real-time weather conditions for your current location
- 📍 **Multiple Cities**: Add and manage weather for multiple cities
- 📅 **5-Day Forecast**: Detailed weather predictions
- 🎨 **Beautiful UI**: Modern design with smooth animations
- 🔄 **Background Refresh**: Automatic weather updates every 15 minutes
- 🌡️ **Temperature Units**: Switch between Celsius and Fahrenheit
- 💾 **Persistent Storage**: Your cities and preferences are saved locally
- 🏗️ **Modular Architecture**: Clean separation of concerns with SPM packages

## Architecture

This app follows a modular architecture with the following packages:

- **`Vivaldi`**: Main application with SwiftUI views and app lifecycle
- **`VivaldiAPIClient`**: OpenWeather API integration with error handling
- **`VivaldiModels`**: Data models and protocols for weather data
- **`VivaldiPersistence`**: Local storage using UserDefaults
- **`VivaldiDesignSystem`**: Reusable UI components and styling

### Architecture Pattern: Reactive Interactor

This scaffold implements the **Interactor Pattern** adapted for SwiftUI's reactive paradigm:

**Interactors** (`FeedInteractor`, `LocationInteractor`) are the core of the architecture:
- **State Management**: Hold all observable state (`@Observable`)
- **Business Logic**: Handle API calls, data processing, and coordination
- **Data Persistence**: Manage UserDefaults storage
- **Error Handling**: Process and transform errors for user consumption
- **Reactive Updates**: Views automatically update when interactor state changes

**Views** are reactive and focused:
- Observe interactor state using `@Bindable` and direct property access
- Handle user interactions by calling interactor methods
- Remain stateless and focused on presentation

This pattern provides:
- **Clear separation** between business logic and presentation
- **Testability** through protocol abstractions
- **Reactivity** through SwiftUI's observation framework
- **Modularity** enabling easy feature development

### Other Design Patterns

- **Dependency Injection**: Protocol-based abstractions for testability and flexibility
- **Protocol-Oriented Programming**: Extensible protocols like `WeatherProviding` and `IconProviding`

## Setup

### Prerequisites

- **Xcode 15.0+** (tested with Xcode 16.3)
- **iOS 17.0+** deployment target
- **OpenWeather API Key** (free tier available)

### Getting an OpenWeather API Key

1. Visit [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for a free account
3. Generate an API key in your dashboard
4. Copy the API key (it looks like: `bd315430fcc83daxxxxxxxxxxxxxxx`)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/vivaldi-weather.git
   cd vivaldi-weather
   ```

2. **Open the project**
   ```bash
   open Vivaldi.xcworkspace
   ```

3. **Configure API Key**
   - Open `Vivaldi/Info.plist`
   - Replace `YOUR_OPENWEATHER_API_KEY_HERE` with your actual OpenWeather API key

4. **Install Dependencies**
   - Xcode should automatically resolve SPM packages
   - If needed: **File** → **Packages** → **Resolve Package Versions**

5. **Run the app**
   - Select **Vivaldi** scheme in Xcode
   - Build and run on simulator or device

### Background Refresh Setup

The app uses iOS Background Tasks to refresh weather data automatically. This requires:

1. **Enable Background Processing**: The `BGTaskSchedulerPermittedIdentifiers` is already configured in `Info.plist`
2. **Background Refresh**: The app will automatically refresh weather every 15 minutes when not actively used
3. **Battery Optimization**: iOS may limit background execution based on usage patterns

## Usage

### First Launch
1. **Onboarding**: Swipe through the welcome screens
2. **Location Permission**: Grant location access for current weather (optional)
3. **Default Cities**: The app starts with 6 default cities

### Main Features

- **Current Location Weather**: Automatically shows weather for your location (if permitted)
- **City Management**: Add/remove cities using the "+" button
- **Weather Details**: Tap any city to see detailed current conditions and 5-day forecast
- **Temperature Toggle**: Switch between °C/°F using the settings menu
- **Pull to Refresh**: Manually refresh all weather data
- **Reset Cities**: Use the settings menu to restore default cities

### Data Persistence
- Cities and temperature preferences are saved locally
- Data persists between app launches
- Use the "Reset Cities" option to restore defaults

## API Integration

### OpenWeather API Endpoints Used

- **Current Weather**: `https://api.openweathermap.org/data/2.5/weather`
- **5-Day Forecast**: `https://api.openweathermap.org/data/2.5/forecast`

### Error Handling

The app gracefully handles common API errors:
- Invalid API key (401)
- City not found (404)
- Network connectivity issues
- Rate limiting

### Data Models

Key data structures include:
- `WeatherAPIResponse`: Complete weather data from API
- `DailyWeatherSummary`: Processed forecast data
- `City`: Location information
- `WeatherCondition`: Weather state with icon support

## Customization

### Adding New Weather Providers

The `WeatherProviding` protocol makes it easy to add new weather services:

```swift
struct CustomWeatherProvider: WeatherProviding {
    func fetchWeather(for city: City) async throws -> WeatherAPIResponse {
        // Your implementation
    }

    func fetchForecast(for city: City) async throws -> [DailyWeatherSummary] {
        // Your implementation
    }
}
```

### UI Theming

Colors and styles are centralized in `VivaldiDesignSystem`:
- Modify `DesignResources.swift` for global styling
- Add new colors to asset catalogs
- Extend `CardStyles.swift` for new UI components

## Extending This Scaffold

### For Different REST APIs

This scaffold is designed to be easily adapted for any REST API. Here's how to extend it:

1. **Create New Data Models** in `VivaldiModels`:
   ```swift
   struct YourDataResponse: Codable {
       let items: [YourItem]
       // Add your API response structure
   }
   ```

2. **Create API Protocol** in `VivaldiModels`:
   ```swift
   protocol YourDataProviding {
       func fetchYourData() async throws -> YourDataResponse
   }
   ```

3. **Implement API Client** in `VivaldiAPIClient`:
   ```swift
   struct YourAPIClient: YourDataProviding {
       func fetchYourData() async throws -> YourDataResponse {
           // Your API implementation
       }
   }
   ```

4. **Create Interactor** in `Vivaldi/App/Interactors/`:
   ```swift
   @MainActor @Observable
   final class YourDataInteractor {
       @ObservationIgnored private let dataProvider: YourDataProviding
       var yourData: YourDataResponse?
       var isLoading = false
       // Add your state and methods
   }
   ```

5. **Create Views** that observe the interactor

### Key Learning Points

- **Protocol Abstraction**: Easy to mock for testing or swap implementations
- **State Management**: All state lives in interactors, views are reactive
- **Error Handling**: Consistent error mapping across the app
- **Background Tasks**: Automatic data refresh patterns
- **Persistence**: UserDefaults patterns for local storage

## Troubleshooting

### Common Issues

**Package Resolution Errors**
```bash
# Reset package caches
File → Packages → Reset Package Caches
# Then resolve
File → Packages → Resolve Package Versions
```

**API Key Issues**
- Verify your API key is correctly set in `Info.plist`
- Check the OpenWeather dashboard for key status
- Ensure you haven't exceeded free tier limits

**Location Permissions**
- If location weather doesn't work, check Settings → Privacy → Location Services
- The app works without location permission using saved cities

**Background Refresh Not Working**
- Background tasks require the app to be launched at least once
- iOS may disable background refresh for battery optimization
- Check Settings → General → Background App Refresh

### Debugging

Enable logging by adding this to your build settings:
- Add `-D DEBUG` to "Other Swift Flags" for debug builds
- Check console logs for weather fetch operations

### Performance Tips

- The app uses efficient caching to minimize API calls
- Background refresh is scheduled every 15 minutes
- Location geocoding is throttled to prevent excessive API usage

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes with proper documentation
4. Test thoroughly on multiple devices
5. Submit a pull request

### Code Style

- Follow Swift standard naming conventions
- Use `// MARK:` comments for code organization
- Maintain the existing modular architecture
- Add documentation for public APIs

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **OpenWeatherMap** for providing weather data
- **Apple** for SwiftUI and iOS frameworks
- Weather icons provided by OpenWeatherMap

## Screenshots

*[Add screenshots of your app here]*

## Roadmap

- [ ] Widget support for home screen
- [ ] Dark mode optimizations
- [ ] Push notifications for weather alerts
- [ ] Historical weather data
- [ ] Weather maps integration
