import Foundation

/// Persiste quais funcionalidades o usuário ativou.
public protocol FeatureStateStore: Sendable {
    func enabledFeatures() -> Set<FeatureID>
    func setEnabledFeatures(_ ids: Set<FeatureID>)
}

/// Implementação padrão em `UserDefaults`.
public final class UserDefaultsFeatureStateStore: FeatureStateStore, @unchecked Sendable {
    // UserDefaults é thread-safe; por isso o @unchecked é seguro aqui.
    private let defaults: UserDefaults
    private let key: String

    public init(defaults: UserDefaults = .standard, key: String = "enabledFeatures") {
        self.defaults = defaults
        self.key = key
    }

    public func enabledFeatures() -> Set<FeatureID> {
        let raw = defaults.stringArray(forKey: key) ?? []
        return Set(raw.map(FeatureID.init(rawValue:)))
    }

    public func setEnabledFeatures(_ ids: Set<FeatureID>) {
        defaults.set(ids.map(\.rawValue).sorted(), forKey: key)
    }
}
