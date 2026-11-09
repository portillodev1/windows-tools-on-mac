# AGENTS.md

> Guia raiz para agentes de código. É um **índice/roteador**, não um manual. Regra
> detalhada mora em `rules/` (carregue sob demanda). `docs/` é para **humanos** —
> referencie, não copie. Ative cada skill **pelo nome**.

## BOUNDARIES (prioridade máxima — leia sempre)

**SEMPRE FAÇA**
- **PROGRESSIVE LOADING — NÃO LEIA TUDO.** Carregue SÓ os docs/rules que o pedido exige (Quick reference).
- Doc/rule/spec curto: **30–70 linhas (ideal), ≤100 (teto)**. Passou de 100 → quebre em `.md` menores + índice.
- Rode tarefas repetíveis via `scripts/` — nunca monte `swift build/test/format` na mão.
- Antes de dizer "pronto", rode `scripts/verify.sh` e só conclua se sair 0.
- Inicie a sessão com `scripts/bootstrap.sh` (lê `STATE.md`); atualize `## Handoff` ao terminar.

**PERGUNTE QUANDO**
- For commitar ou dar push (padrão: NÃO commitar sem aprovação).
- For adicionar dependência (SwiftPM/Homebrew), novo target/extension, ou entitlement → ADR em `docs/adr/`.
- A funcionalidade exigir nova permissão de sistema (Acessibilidade, Input Monitoring, Automação).
- For apagar/renomear spec, design, doc ou mudar um `FeatureID` já publicado.

**NUNCA FAÇA**
- **LER TUDO de uma vez** — carregue só o que o pedido exige.
- Injetar código em apps da Apple, exigir SIP desligado ou usar API privada (ver ADR-0002).
- Encerrar/reiniciar apps do usuário fora de `AppRestarting`, ou sem a ação explícita do usuário.
- Commitar sem aprovação; editar `build/`, `dist/`, `.build/`; versionar segredos/certificados.
- Copiar conteúdo de skills/rules/docs para dentro deste arquivo.

## Projeto
- **WinTools**: app de barra de menus que adiciona ao macOS funcionalidades do Windows
  (histórico de clipboard, janelas no Terminal, janelas no Finder). O usuário ativa no menu;
  os apps afetados são reiniciados e a funcionalidade passa a valer.
- Alvo: macOS 14+, **somente Apple Silicon (arm64)**. Open-source (Apache-2.0).
- Stack: Swift 6 + SwiftUI (`MenuBarExtra`) · SwiftPM · Swift Testing · XCUITest via XcodeGen (`project.yml`).
- Arquitetura: `WinToolsCore` (lógica testável) ← `WinTools` (UI fina). Ver `docs/architecture.md`.

## Comandos → use os scripts
| Preciso… | Rode |
|---|---|
| Compilar (warnings = erro) | `scripts/build.sh [--release]` |
| Testar | `scripts/test.sh [--filter <padrão>]` |
| Lint/format | `scripts/lint.sh [--fix]` |
| Rodar o app local | `scripts/run.sh` |
| Gerar `.app` | `scripts/bundle.sh [--debug]` |
| Gerar release (zip+dmg) | `scripts/package.sh` |
| Contexto no início da sessão | `scripts/bootstrap.sh` |
| Testes + cobertura (≥ 80% Core) | `scripts/coverage.sh` |
| Checar fronteiras/plataforma | `scripts/check-architecture.sh` |
| Checar limites de docs | `scripts/check-docs.sh` |
| Ativar pre-commit hook | `scripts/install-hooks.sh` |
| Teste ponta a ponta (XCUITest) | `scripts/e2e.sh [--filter <Classe/teste>]` |
| **Gate final** | `scripts/verify.sh` |

## Quick reference — o que carregar por tarefa
> Carregue SÓ a linha que casa com o pedido atual.

| Tarefa | Carregue | Skill |
|---|---|---|
| Nova funcionalidade do Windows | `rules/features.md` + `ROADMAP.md` | `tlc-spec-driven` |
| Código Swift em geral / refactor | `rules/implementation.md` | — |
| Escrever/ajustar testes (unit e UI) | `rules/tests.md` | `harness-engineering` |
| Build, assinatura, release, CI | `docs/release.md` | — |
| Entender módulos/fluxo | `docs/architecture.md` | — |
| Decisão de arquitetura/dependência | `docs/adr/README.md` | — |
| Rodar autônomo até passar | `HARNESS.md` | `loop-engineering` (só se necessário) |
| Rotear a demanda | — | `agentic-delivery` |
| API atual de Apple/Swift | **context7 MCP** (cite a versão) | — |

## Harness
- Manifesto de guias + sensores: `HARNESS.md`. Eval gates (0/1): `scripts/verify.sh`.
- Memória/continuidade: `STATE.md` (decisões `AD-NNN`, `## Handoff`). Roadmap: `ROADMAP.md`.

## Política de commit e limpeza
- **Commit sob aprovação** (padrão: não commitar). Conventional Commits.
- **Limpeza após aprovação**: remova efêmeros (`tasks.md`, logs, contratos). Preserve `spec.md`,
  `design.md`, `AGENTS.md`, `rules/`, `docs/`, `HARNESS.md`, `STATE.md`, `ROADMAP.md`.
- **Loop**: não limpe a cada tarefa; só quando o loop inteiro terminar e for aprovado.

## Mapa de arquivos
| Caminho | Papel | Público | Ciclo |
|---|---|---|---|
| `AGENTS.md`, `rules/*.md` | Índice + regras testáveis | IA | permanente |
| `scripts/*` | Comandos repetíveis | IA + Humano | permanente |
| `docs/**`, `docs/adr/*`, `README.md` | Contexto e decisões | Humano | permanente |
| `HARNESS.md`, `STATE.md`, `ROADMAP.md` | Harness, memória, roadmap | IA + Humano | permanente |
| `.specs/<feature>/spec.md`, `design.md` | Especificação | IA + Humano | permanente |
| `tasks.md` / logs / contratos | Trabalho de 1 tarefa | IA | efêmero |
