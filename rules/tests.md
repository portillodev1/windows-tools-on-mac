# rules/tests.md — carregada em: escrever/ajustar testes

O agente **não se autoavalia**: quem decide "pronto" é o gate (`scripts/verify.sh`).

## Regras
- Framework: **Swift Testing** (`import Testing`, `@Test`, `#expect`, `#require`). Não use XCTest
  em código novo.
- Todo comportamento novo/alterado no `WinToolsCore` tem teste antes de concluir.
- Nome por comportamento: `<unidade>_<condição>_<resultado>` (ex.: `enable_whenApplyFails_keepsStateUnchanged`).
- Um comportamento por teste. Sem efeitos reais: nada de encerrar apps, mexer no pasteboard real,
  escrever em `UserDefaults.standard` ou rodar `defaults write`. Use os fakes de
  `Tests/WinToolsCoreTests/Fakes.swift` ou um `UserDefaults(suiteName:)` descartável.
- Toda `Feature` testa os dois sentidos: `apply()` e `revert()` restaurando o estado anterior.
- Bug corrigido entra com teste de regressão que falha sem o fix.
- Rode via `scripts/test.sh [--filter <padrão>]`. Nunca monte `swift test` na mão.

## Testes de UI / ponta a ponta (XCUITest, `Tests/WinToolsUITests/`)
- Rode via `scripts/e2e.sh`. Ele **controla o mouse/teclado reais**: o agente só roda quando o
  usuário pedir ou ao mexer em UI/funcionalidade, nunca em loop.
- Mudou algo visível no menu ou uma funcionalidade virou `.available` → teste de UI cobrindo o fluxo.
- Selecione só por `accessibilityIdentifier` (`AccessibilityID` no app); nunca por texto visível.
- O app sobe com `--ui-testing` (estado isolado). Reinício real de Finder/Terminal: só em teste
  marcado e documentado no PR.
- Classe `@MainActor final class ...: XCTestCase`, sem override de `setUp` (use um helper).

## Exemplo
```swift
@Test func enable_whenPlanned_throwsNotAvailable() async {
    let manager = makeManager(feature: FakeFeature(descriptor: .fixture(availability: .planned)))
    await #expect(throws: FeatureError.notAvailable("fake")) {
        try await manager.setEnabled("fake", true)
    }
}
```
