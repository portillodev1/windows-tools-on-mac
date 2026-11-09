import SwiftUI
import WinToolsCore

struct MenuContentView: View {
    let manager: FeatureManager
    @State private var pending: FeatureID?
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Funcionalidades do Windows")
                .font(.headline)
                .accessibilityIdentifier(AccessibilityID.title)

            ForEach(manager.catalog) { feature in
                FeatureRow(
                    feature: feature,
                    isOn: manager.isEnabled(feature.id),
                    isBusy: pending == feature.id,
                    onToggle: { toggle(feature.id, to: $0) }
                )
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .accessibilityIdentifier(AccessibilityID.error)
            }

            Divider()
            Button("Sair do WinTools") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("q")
                .accessibilityIdentifier(AccessibilityID.quit)
        }
        .padding(14)
        .frame(width: 340)
    }

    private func toggle(_ id: FeatureID, to isOn: Bool) {
        pending = id
        errorMessage = nil
        Task {
            defer { pending = nil }
            do {
                try await manager.setEnabled(id, isOn)
            } catch {
                errorMessage = "Não foi possível aplicar: \(error)"
            }
        }
    }
}

private struct FeatureRow: View {
    let feature: FeatureDescriptor
    let isOn: Bool
    let isBusy: Bool
    let onToggle: @MainActor (Bool) -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                Text("\(feature.summary) (\(feature.windowsEquivalent))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if feature.availability == .planned {
                Text("Em breve")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier(AccessibilityID.status(feature.id))
            } else if isBusy {
                ProgressView().controlSize(.small)
            } else {
                Toggle("", isOn: Binding(get: { isOn }, set: { onToggle($0) }))
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .accessibilityLabel(feature.title)
                    .accessibilityIdentifier(AccessibilityID.toggle(feature.id))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityID.row(feature.id))
    }
}

/// Identificadores estáveis usados pelos testes de UI (Tests/WinToolsUITests). Mude os dois juntos.
enum AccessibilityID {
    static let title = "menu-title"
    static let error = "menu-error"
    static let quit = "menu-quit"
    static func row(_ id: FeatureID) -> String { "feature-\(id.rawValue)" }
    static func status(_ id: FeatureID) -> String { "feature-\(id.rawValue)-status" }
    static func toggle(_ id: FeatureID) -> String { "feature-\(id.rawValue)-toggle" }
}
