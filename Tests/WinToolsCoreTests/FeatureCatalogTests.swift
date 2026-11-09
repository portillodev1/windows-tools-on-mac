import Foundation
import Testing
import WinToolsCore

struct FeatureCatalogTests {
    @Test func catalog_idsAreUnique() {
        let ids = FeatureCatalog.all.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func catalog_containsInitialRoadmapFeatures() {
        let ids = Set(FeatureCatalog.all.map(\.id))
        #expect(ids == ["clipboard-history", "terminal-windows", "finder-windows"])
    }

    @Test func userDefaultsStore_roundTripsEnabledFeatures() throws {
        let suite = "wintools.tests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = UserDefaultsFeatureStateStore(defaults: defaults)

        store.setEnabledFeatures(["clipboard-history", "finder-windows"])

        #expect(store.enabledFeatures() == ["clipboard-history", "finder-windows"])
    }
}
