import Testing
import WinToolsCore

@MainActor
struct FeatureManagerTests {
    private func makeManager(
        feature: FakeFeature,
        store: InMemoryStateStore = InMemoryStateStore(),
        restarter: RecordingRestarter = RecordingRestarter()
    ) -> FeatureManager {
        FeatureManager(catalog: [feature.descriptor], implementations: [feature], store: store, restarter: restarter)
    }

    @Test func enable_whenAvailable_appliesRestartsAndPersists() async throws {
        let feature = FakeFeature(descriptor: .fixture())
        let store = InMemoryStateStore()
        let restarter = RecordingRestarter()
        let manager = makeManager(feature: feature, store: store, restarter: restarter)

        try await manager.setEnabled("fake", true)

        #expect(feature.log.all == [.apply])
        #expect(restarter.restartCalls == [["com.example.app"]])
        #expect(manager.isEnabled("fake"))
        #expect(store.enabledFeatures() == ["fake"])
    }

    @Test func disable_whenEnabled_revertsAndPersists() async throws {
        let feature = FakeFeature(descriptor: .fixture())
        let store = InMemoryStateStore(["fake"])
        let manager = makeManager(feature: feature, store: store)

        try await manager.setEnabled("fake", false)

        #expect(feature.log.all == [.revert])
        #expect(!manager.isEnabled("fake"))
        #expect(store.enabledFeatures().isEmpty)
    }

    @Test func enable_whenAlreadyEnabled_doesNothing() async throws {
        let feature = FakeFeature(descriptor: .fixture())
        let restarter = RecordingRestarter()
        let manager = makeManager(feature: feature, store: InMemoryStateStore(["fake"]), restarter: restarter)

        try await manager.setEnabled("fake", true)

        #expect(feature.log.all.isEmpty)
        #expect(restarter.restartCalls.isEmpty)
    }

    @Test func enable_whenPlanned_throwsNotAvailable() async {
        let feature = FakeFeature(descriptor: .fixture(availability: .planned))
        let manager = makeManager(feature: feature)

        await #expect(throws: FeatureError.notAvailable("fake")) {
            try await manager.setEnabled("fake", true)
        }
        #expect(feature.log.all.isEmpty)
    }

    @Test func enable_whenUnknownID_throwsUnknownFeature() async {
        let manager = makeManager(feature: FakeFeature(descriptor: .fixture()))

        await #expect(throws: FeatureError.unknownFeature("nope")) {
            try await manager.setEnabled("nope", true)
        }
    }

    @Test func enable_whenApplyFails_keepsStateUnchanged() async {
        var feature = FakeFeature(descriptor: .fixture())
        feature.failure = TestError()
        let store = InMemoryStateStore()
        let restarter = RecordingRestarter()
        let manager = makeManager(feature: feature, store: store, restarter: restarter)

        await #expect(throws: TestError.self) { try await manager.setEnabled("fake", true) }

        #expect(!manager.isEnabled("fake"))
        #expect(store.enabledFeatures().isEmpty)
        #expect(restarter.restartCalls.isEmpty)
    }

    @Test func enable_whenRestartFails_keepsStateUnchanged() async {
        let feature = FakeFeature(descriptor: .fixture())
        let store = InMemoryStateStore()
        let manager = makeManager(
            feature: feature, store: store, restarter: RecordingRestarter(failingWith: TestError()))

        await #expect(throws: TestError.self) { try await manager.setEnabled("fake", true) }

        #expect(!manager.isEnabled("fake"))
        #expect(store.enabledFeatures().isEmpty)
    }

    @Test func init_ignoresPersistedIDsWithoutImplementation() {
        let feature = FakeFeature(descriptor: .fixture())
        let manager = makeManager(feature: feature, store: InMemoryStateStore(["fake", "removed-feature"]))

        #expect(manager.enabled == ["fake"])
    }
}
