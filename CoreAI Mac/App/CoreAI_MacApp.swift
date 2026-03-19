import SwiftUI

@main
struct CoreAI_MacApp: App {
    @StateObject private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
        }
        .windowResizability(.contentSize)

        Settings {
            SettingsView(
                viewModel: SettingsViewModel(
                    coreAIService: dependencies.coreAIService,
                    settingsStore: dependencies.settingsStore,
                    keychainService: dependencies.keychainService,
                    connectionMonitorService: dependencies.connectionMonitorService
                )
            )
        }
    }
}
