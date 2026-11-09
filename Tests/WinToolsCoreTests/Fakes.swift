import Foundation
import WinToolsCore

/// Caixa thread-safe para fakes (Mutex do Synchronization exige macOS 15; o alvo é 14).
final class Locked<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var value: Value

    init(_ value: Value) {
        self.value = value
    }

    func withLock<R>(_ body: (inout Value) -> R) -> R {
        lock.lock()
        defer { lock.unlock() }
        return body(&value)
    }
}

final class InMemoryStateStore: FeatureStateStore {
    private let storage: Locked<Set<FeatureID>>

    init(_ initial: Set<FeatureID> = []) {
        storage = Locked(initial)
    }

    func enabledFeatures() -> Set<FeatureID> { storage.withLock { $0 } }
    func setEnabledFeatures(_ ids: Set<FeatureID>) { storage.withLock { $0 = ids } }
}

final class RecordingRestarter: AppRestarting {
    private let calls = Locked<[[String]]>([])
    private let error: (any Error)?

    init(failingWith error: (any Error)? = nil) {
        self.error = error
    }

    var restartCalls: [[String]] { calls.withLock { $0 } }

    func restart(bundleIdentifiers: [String]) async throws {
        calls.withLock { $0.append(bundleIdentifiers) }
        if let error { throw error }
    }
}

struct FakeFeature: Feature {
    enum Event: Equatable { case apply, revert }

    let descriptor: FeatureDescriptor
    let log = EventLog()
    var failure: (any Error)?

    func apply() async throws {
        log.append(.apply)
        if let failure { throw failure }
    }

    func revert() async throws {
        log.append(.revert)
        if let failure { throw failure }
    }

    final class EventLog: Sendable {
        private let events = Locked<[Event]>([])
        var all: [Event] { events.withLock { $0 } }
        func append(_ event: Event) { events.withLock { $0.append(event) } }
    }
}

struct TestError: Error, Equatable {}

extension FeatureDescriptor {
    static func fixture(
        id: FeatureID = "fake",
        affectedApps: [String] = ["com.example.app"],
        availability: FeatureAvailability = .available
    ) -> FeatureDescriptor {
        FeatureDescriptor(
            id: id,
            title: "Fake",
            summary: "Fake feature",
            windowsEquivalent: "Win + F",
            affectedApps: affectedApps,
            availability: availability
        )
    }
}
