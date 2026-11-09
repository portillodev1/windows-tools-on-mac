# STATE.md — memória entre sessões

> Fonte única de estado e handoff entre áreas (harness → spec → loop). Leia no início da sessão
> (`scripts/bootstrap.sh` mostra o Handoff e o ROADMAP). Atualize ao terminar.

## Fase atual
- **Fase 0 — Harness**: concluída (setup inicial, aguardando aprovação/commit do mantenedor).
- Próxima: **Fase 1 — Spec** da funcionalidade `clipboard-history` (skill `tlc-spec-driven`).

## Decisões (AD-NNN)
| ID | Data | Decisão | Onde detalha |
|---|---|---|---|
| AD-001 | 2026-11-09 | Nome do produto **WinTools**; bundle id `io.github.portillodev1.wintools` | `Support/Info.plist` |
| AD-002 | 2026-11-09 | macOS 14+ e somente arm64 | ADR-0003 |
| AD-003 | 2026-11-09 | Distribuição ad-hoc via GitHub Releases (zip + dmg); Developer ID depois | ADR-0003 |
| AD-004 | 2026-11-09 | SwiftPM + `scripts/bundle.sh`, sem `.xcodeproj`; lint com `swift format` do toolchain | ADR-0001 |
| AD-005 | 2026-11-09 | Só APIs públicas; sem injeção em Finder/Terminal nem SIP desligado | ADR-0002 |
| AD-006 | 2026-11-09 | Commit só com aprovação explícita do mantenedor | `AGENTS.md` |
| AD-007 | 2026-11-09 | Adaptadores de sistema em `Sources/WinToolsCore/System/`, fora do gate de cobertura | `HARNESS.md` |
| AD-008 | 2026-11-09 | UI e docs em pt-BR; código e identificadores em inglês | `rules/implementation.md` |
| AD-009 | 2026-11-09 | E2E com XCUITest via XcodeGen (Playwright descartado: não controla apps nativos) | ADR-0004 |

## Eval gates disponíveis (para spec e loop)
`scripts/verify.sh` = build (warnings = erro) · lint · check-architecture · check-docs ·
testes + cobertura ≥ 80% do Core. Detalhe em `HARNESS.md` §4.

## Perguntas em aberto
- Q-001: o que exatamente é "janelas no Terminal" e "janelas no Finder"? (Terminal e Finder já
  têm abas nativas.) Ver opções em `ROADMAP.md` §2 e §3. Decidir antes da spec.
- Q-002: atalho padrão do histórico de clipboard (`⌘⇧V`, `⌃V`, configurável?).

## Handoff
- **Última unidade**: E2E com XCUITest (ADR-0004): `project.yml` (XcodeGen), `Tests/WinToolsUITests`
  (3 testes do menu), `scripts/e2e.sh`, `Brewfile`, modo `--ui-testing`, `AccessibilityID`, job `e2e` no CI.
- **Estado dos gates**: `scripts/verify.sh` = 0 (11 testes, Core 98,5%). UI tests compilam.
- **Não verificado**: `scripts/e2e.sh` nunca passou — 1ª execução expirou esperando o usuário
  autorizar a automação de UI do macOS. Workflows do GitHub Actions (só rodam após push).
- **Próxima unidade**: usuário roda `scripts/e2e.sh` e aprova o pedido do macOS; depois responder
  Q-001/Q-002 e especificar `clipboard-history` em `.specs/clipboard-history/`.
- **Budget/bloqueios**: e2e depende de autorização interativa do usuário.
