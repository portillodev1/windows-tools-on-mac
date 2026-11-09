/// Identificador estável de uma funcionalidade. É persistido; nunca renomeie um já publicado.
public struct FeatureID: RawRepresentable, Hashable, Codable, Sendable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

/// Se a funcionalidade já pode ser ativada pelo usuário ou só aparece como "em breve".
public enum FeatureAvailability: Equatable, Sendable {
    case available
    case planned
}

/// Permissões de sistema que a funcionalidade precisa para funcionar.
public enum SystemPermission: String, CaseIterable, Sendable {
    case accessibility
    case inputMonitoring
    case automation
}

/// Metadados exibidos no menu. Não contém comportamento.
public struct FeatureDescriptor: Identifiable, Equatable, Sendable {
    public let id: FeatureID
    public let title: String
    public let summary: String
    /// Atalho ou recurso equivalente no Windows (ex.: "Win + V").
    public let windowsEquivalent: String
    /// Bundle ids dos apps que precisam ser reiniciados ao ativar/desativar.
    public let affectedApps: [String]
    public let permissions: [SystemPermission]
    public let availability: FeatureAvailability

    public init(
        id: FeatureID,
        title: String,
        summary: String,
        windowsEquivalent: String,
        affectedApps: [String] = [],
        permissions: [SystemPermission] = [],
        availability: FeatureAvailability
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.windowsEquivalent = windowsEquivalent
        self.affectedApps = affectedApps
        self.permissions = permissions
        self.availability = availability
    }
}

/// Comportamento de uma funcionalidade. `revert()` deve deixar o sistema como estava antes de `apply()`.
public protocol Feature: Sendable {
    var descriptor: FeatureDescriptor { get }
    func apply() async throws
    func revert() async throws
}
