# ADR-0004: Testes ponta a ponta com XCUITest via XcodeGen

- **Status**: aceito (complementa o ADR-0001, não o substitui)
- **Data**: 2026-11-09
- **Decisores**: mantenedor (@portillodev1)

## Contexto
Precisamos de testes de integração e ponta a ponta do app real: clicar no ícone da barra de
menus, ler o painel, ligar funcionalidades e conferir o efeito. O SwiftPM não roda testes de UI;
o XCUITest exige um projeto Xcode com um alvo `bundle.ui-testing`. Playwright foi cogitado, mas
só controla navegadores e apps Electron — não enxerga apps nativos nem a barra de menus.

## Decisão
- Build, lint e testes unitários continuam 100% SwiftPM (ADR-0001).
- Um `project.yml` versionado descreve um projeto Xcode **só para os testes de UI**: alvo
  `WinToolsApp` (mesmo código de `Sources/WinTools`, gera `WinTools.app`) + `WinToolsUITests`.
- `scripts/e2e.sh` gera o `WinToolsE2E.xcodeproj` (gitignored) com **XcodeGen** e roda
  `xcodebuild test`. XcodeGen entra como dependência de desenvolvimento via `Brewfile`.
- O app aceita `--ui-testing`: usa uma suíte de `UserDefaults` descartável, zerada a cada execução.
- Os seletores são `accessibilityIdentifier` estáveis (`AccessibilityID` no app).

## Alternativas consideradas
- Playwright — não controla apps nativos do macOS.
- E2E caseiro via API de Acessibilidade — sem dependência, mas reinventa o que o XCUITest dá
  (esperas, screenshots no `.xcresult`, integração com o Xcode).
- `.xcodeproj` versionado — diff ilegível (motivo do ADR-0001).

## Consequências
- **Positivas**: ferramenta oficial; falhas trazem screenshots no `.xcresult`; dá para rodar
  e depurar pelo Xcode (`xed WinToolsE2E.xcodeproj`).
- **Negativas / trade-offs**: dependência de Homebrew; o teste controla mouse/teclado reais
  (não roda em paralelo com uso da máquina); exige autorizar a automação de UI do macOS; fica
  fora do `verify.sh` (gate separado G6).
- **Follow-ups**: tornar o job `e2e` do CI bloqueante após a primeira execução verde.
