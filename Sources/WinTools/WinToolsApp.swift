import SwiftUI
import WinToolsCore

@main
struct WinToolsApp: App {
    @State private var manager = FeatureManager(
        store: LaunchEnvironment.current.makeStore(),
        restarter: WorkspaceAppRestarter()
    )

    var body: some Scene {
        MenuBarExtra("WinTools", systemImage: "square.grid.2x2") {
            MenuContentView(manager: manager)
        }
        .menuBarExtraStyle(.window)
    }
}

/// Como o app foi iniciado. Os testes de UI passam `--ui-testing` para não tocar no estado real do usuário.
enum LaunchEnvironment {
    case standard
    case uiTesting

    static let uiTestingArgument = "--ui-testing"
    static let uiTestingSuite = "io.github.portillodev1.wintools.uitests"

    static var current: LaunchEnvironment {
        ProcessInfo.processInfo.arguments.contains(uiTestingArgument) ? .uiTesting : .standard
    }

    func makeStore() -> any FeatureStateStore {
        switch self {
        case .standard:
            return UserDefaultsFeatureStateStore()
        case .uiTesting:
            // Suíte descartável, zerada a cada execução: cada teste começa do mesmo estado.
            UserDefaults().removePersistentDomain(forName: Self.uiTestingSuite)
            return UserDefaultsFeatureStateStore(defaults: UserDefaults(suiteName: Self.uiTestingSuite) ?? .standard)
        }
    }
}
