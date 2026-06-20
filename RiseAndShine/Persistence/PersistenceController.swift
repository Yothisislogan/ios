import Foundation
import SwiftData

/// Builds and vends the app's SwiftData `ModelContainer`.
///
/// Centralizing the schema here keeps the model list in one place and provides
/// an in-memory variant for previews and unit/UI tests.
public enum PersistenceController {

    /// All persisted model types. Add new `@Model` types here.
    public static let schema = Schema([
        Alarm.self,
        ReactionAttempt.self,
        WakeRecord.self,
        AppSettings.self,
    ])

    /// The on-disk container used by the running app.
    ///
    /// Falls back to an in-memory store if the persistent store cannot be
    /// opened, so the app still launches (degraded) rather than crashing —
    /// reliability over data permanence at startup.
    public static func makeAppContainer() -> ModelContainer {
        do {
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            assertionFailure("Falling back to in-memory store: \(error)")
            return makeInMemoryContainer()
        }
    }

    /// A throwaway in-memory container for previews and tests.
    public static func makeInMemoryContainer() -> ModelContainer {
        do {
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create in-memory ModelContainer: \(error)")
        }
    }

    /// Fetches the singleton `AppSettings`, creating and inserting it on first
    /// launch. Call from a context with access to the main store.
    @MainActor
    public static func loadSettings(in context: ModelContext) -> AppSettings {
        let descriptor = FetchDescriptor<AppSettings>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let settings = AppSettings()
        context.insert(settings)
        try? context.save()
        return settings
    }
}
