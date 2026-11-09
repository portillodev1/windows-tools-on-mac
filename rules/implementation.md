# rules/implementation.md — carregada em: código Swift / refactor

Regras testáveis. O estilo é do `swift-format` (`.swift-format`); não invente convenções aqui.

## Camadas
- Regra de negócio vive em `Sources/WinToolsCore`. `Sources/WinTools` só tem UI e composição
  (criar `FeatureManager` com as implementações reais). Se a UI decide algo, mova para o Core.
- Efeito colateral de sistema (NSWorkspace, `defaults`, pasteboard, event taps, AppleScript)
  fica atrás de um **protocolo** no Core, com implementação real + fake de teste.
  Exemplo existente: `AppRestarting` → `WorkspaceAppRestarter` / `RecordingRestarter`.
- Adaptador real de sistema (o que não dá para testar sem efeito real) mora em
  `Sources/WinToolsCore/System/` e fica fora do gate de cobertura — mantenha-o fino.
- O Core não importa SwiftUI. AppKit só nas implementações reais de protocolos.

## Swift 6
- Strict concurrency ligado (tools 6.0). `scripts/build.sh` usa `-warnings-as-errors`:
  zero warnings é parte do gate.
- Estado observado pela UI é `@MainActor @Observable`. Nada de `DispatchQueue.main.async`
  novo — use `async/await` e `@MainActor`.
- `@unchecked Sendable` só com comentário justificando o porquê (ver `UserDefaultsFeatureStateStore`).
- Proibido (lint): `!` force unwrap, `try!`, IUO. Erros esperados são `enum ...Error` explícitos.
- APIs acima de macOS 14 exigem `if #available` + fallback; nunca suba o alvo sem ADR.

## Plataforma
- Só arm64; não adicione caminhos x86_64/Rosetta.
- Sem API privada, sem injeção em processos da Apple, sem exigir SIP desligado (ADR-0002).
- Nova permissão (Acessibilidade, Input Monitoring, Automação) → declare em
  `FeatureDescriptor.permissions`, adicione a usage string no `Support/Info.plist` e pergunte antes.

## Entrega
- Uma unidade de comportamento por tarefa; sem TODO/código morto no que entrega.
- `scripts/verify.sh` deve sair 0. Dependência nova ou decisão estrutural → ADR em `docs/adr/`.
- Texto visível ao usuário em pt-BR; identificadores e nomes de código em inglês.
