import SwiftData
import SwiftUI

@main
struct RiseAndShineApp: App {
    /// The shared SwiftData container, created once for the app's lifetime.
    private let modelContainer: ModelContainer = PersistenceController.makeAppContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
