# ADR-0001: SwiftPM + script de bundle, sem `.xcodeproj`

- **Status**: aceito
- **Data**: 2026-11-09
- **Decisores**: mantenedor (@portillodev1)

## Contexto
O projeto é open-source e será tocado em boa parte por agentes de código. Um `.pbxproj` é
difícil de revisar em diff, gera conflitos e prende o build à UI do Xcode. Um app de barra de
menus simples não precisa de recursos exclusivos do projeto Xcode.

## Decisão
Vamos usar só `Package.swift` (SwiftPM, tools 6.0) com três targets (`WinToolsCore`,
`WinTools`, `WinToolsCoreTests`). O `.app` é montado por `scripts/bundle.sh` a partir do binário
do SwiftPM + `Support/Info.plist`, e assinado com `codesign`. Lint com o `swift format` que já
vem no toolchain (zero dependência nova).

## Alternativas consideradas
- Projeto Xcode versionado — diff ilegível e conflitos de merge; ruim para agentes.
- XcodeGen/Tuist — resolvem o diff, mas exigem ferramenta extra para todo contribuidor.
- SwiftLint/SwiftFormat (Homebrew) — mais regras, porém dependência externa; adiado.

## Consequências
- **Positivas**: tudo é texto; `swift build/test` funcionam no terminal e no CI; abrir a pasta
  no Xcode (`xed .`) continua funcionando para depurar.
- **Negativas / trade-offs**: app extensions (ex.: Finder Sync) não são suportadas pelo SwiftPM;
  asset catalogs e ícone exigem passos manuais no script.
- **Follow-ups**: se uma funcionalidade exigir app extension, abrir ADR para adotar XcodeGen ou
  Tuist só para esse target.
