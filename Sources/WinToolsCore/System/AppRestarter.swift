import AppKit

/// Reinicia apps afetados por uma funcionalidade para que a mudança seja aplicada.
public protocol AppRestarting: Sendable {
    func restart(bundleIdentifiers: [String]) async throws
}

public enum AppRestartError: Error, Equatable {
    case applicationNotFound(String)
    case didNotTerminate(String)
}

/// Implementação real via `NSWorkspace`. Apps que não estão rodando são ignorados.
public struct WorkspaceAppRestarter: AppRestarting {
    private let terminationTimeout: Duration

    public init(terminationTimeout: Duration = .seconds(5)) {
        self.terminationTimeout = terminationTimeout
    }

    @MainActor
    public func restart(bundleIdentifiers: [String]) async throws {
        for bundleID in bundleIdentifiers {
            let running = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
            guard !running.isEmpty else { continue }

            running.forEach { $0.terminate() }
            try await waitForTermination(of: running, bundleID: bundleID)

            guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
                throw AppRestartError.applicationNotFound(bundleID)
            }
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = false
            _ = try await NSWorkspace.shared.openApplication(at: url, configuration: configuration)
        }
    }

    @MainActor
    private func waitForTermination(of apps: [NSRunningApplication], bundleID: String) async throws {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: terminationTimeout)
        while apps.contains(where: { !$0.isTerminated }) {
            guard clock.now < deadline else { throw AppRestartError.didNotTerminate(bundleID) }
            try await Task.sleep(for: .milliseconds(100))
        }
    }
}
