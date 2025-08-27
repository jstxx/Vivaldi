import SwiftUI
import BackgroundTasks
import VivaldiPersistence
import VivaldiAPIClient
import VivaldiModels

@main
struct VivaldiApp: App {
    @State private var locationInteractor = LocationInteractor()
    @State private var feedInteractor = FeedInteractor()

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environment(locationInteractor)
                .environment(feedInteractor)
        }
    }

    init() {
        registerBackgroundTasks()
        scheduleWeatherRefresh()
    }

    /// Register background tasks for weather refresh
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.vivaldi.weatherRefresh", using: nil) { task in
            self.handleWeatherRefreshTask(task: task as! BGAppRefreshTask)
        }
    }

    /// Schedule the next weather refresh
    private func scheduleWeatherRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.vivaldi.weatherRefresh")
        // Refresh every 15 minutes when app is not active
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
            print("Scheduled background weather refresh")
        } catch {
            print("Could not schedule weather refresh: \(error)")
        }
    }

    /// Handle the background weather refresh task
    private func handleWeatherRefreshTask(task: BGAppRefreshTask) {
        // Schedule the next refresh
        scheduleWeatherRefresh()

        // Create a new feed interactor for background refresh
        let backgroundFeedInteractor = FeedInteractor()
        let backgroundLocationInteractor = LocationInteractor()

        task.expirationHandler = {
            // Cancel the task if it's taking too long
            task.setTaskCompleted(success: false)
        }

        Task {
            do {
                // Refresh weather for all cities
                await backgroundFeedInteractor.refreshWeatherFeed()

                // Refresh current location weather if location is available
                if let currentLocation = VivaldiPersistence.currentLocation {
                    backgroundLocationInteractor.startLocationUpdates()
                    // Wait a bit for location to be determined
                    try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                    await backgroundLocationInteractor.fetchCurrentLocationForecast()
                }

                task.setTaskCompleted(success: true)
                print("Background weather refresh completed successfully")
            } catch {
                task.setTaskCompleted(success: false)
                print("Background weather refresh failed: \(error)")
            }
        }
    }
}
