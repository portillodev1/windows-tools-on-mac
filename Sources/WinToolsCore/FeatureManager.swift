import Observation

public enum FeatureError: Error, Equatable {
    case unknownFeature(FeatureID)
    case notAvailable(FeatureID)
}

/// Fonte de verdade do menu: lista o catálogo, ativa/desativa e reinicia os apps afetados.
@MainActor
@Observable
public final class FeatureManager {
    public let catalog: [FeatureDescriptor]
    public private(set) var enabled: Set<FeatureID>

    private let implementations: [FeatureID: any Feature]
    private let store: any FeatureStateStore
    private let restarter: any AppRestarting

    public init(
        catalog: [FeatureDescriptor] = FeatureCatalog.all,
        implementations: [any Feature] = [],
        store: any FeatureStateStore,
        restarter: any AppRestarting
    ) {
        self.catalog = catalog
        self.implementations = Dictionary(uniqueKeysWithValues: implementations.map { ($0.descriptor.id, $0) })
        self.store = store
        self.restarter = restarter
        self.enabled = store.enabledFeatures().intersection(Set(implementations.map(\.descriptor.id)))
    }

    public func isEnabled(_ id: FeatureID) -> Bool {
        enabled.contains(id)
    }

    /// Ativa ou desativa uma funcionalidade. O estado só muda se aplicar/reverter e reiniciar derem certo.
    public func setEnabled(_ id: FeatureID, _ isOn: Bool) async throws {
        guard let descriptor = catalog.first(where: { $0.id == id }) else {
            throw FeatureError.unknownFeature(id)
        }
        guard descriptor.availability == .available, let feature = implementations[id] else {
            throw FeatureError.notAvailable(id)
        }
        guard isEnabled(id) != isOn else { return }

        if isOn {
            try await feature.apply()
        } else {
            try await feature.revert()
        }
        try await restarter.restart(bundleIdentifiers: descriptor.affectedApps)

        if isOn {
            enabled.insert(id)
        } else {
            enabled.remove(id)
        }
        store.setEnabledFeatures(enabled)
    }
}
