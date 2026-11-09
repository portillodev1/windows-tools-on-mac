/// Catálogo das funcionalidades conhecidas. Ver ROADMAP.md para o status de cada uma.
public enum FeatureCatalog {
    public static let clipboardHistory = FeatureDescriptor(
        id: "clipboard-history",
        title: "Histórico da área de transferência",
        summary: "Lista os últimos itens copiados e cola o escolhido.",
        windowsEquivalent: "Win + V",
        permissions: [.accessibility],
        availability: .planned
    )

    public static let terminalWindows = FeatureDescriptor(
        id: "terminal-windows",
        title: "Janelas no Terminal",
        summary: "Gerenciamento de janelas do Terminal no estilo do Windows Terminal.",
        windowsEquivalent: "Windows Terminal",
        affectedApps: ["com.apple.Terminal"],
        availability: .planned
    )

    public static let finderWindows = FeatureDescriptor(
        id: "finder-windows",
        title: "Janelas no Finder",
        summary: "Gerenciamento de janelas do Finder no estilo do Explorador de Arquivos.",
        windowsEquivalent: "Explorador de Arquivos",
        affectedApps: ["com.apple.finder"],
        availability: .planned
    )

    public static let all: [FeatureDescriptor] = [clipboardHistory, terminalWindows, finderWindows]
}
