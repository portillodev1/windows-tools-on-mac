# scripts/ — comandos repetíveis executáveis

Todo comando que se repete (testar, lintar, buildar, empacotar) vira um script aqui. O agente
**roda o script**, não monta o comando: economiza tokens, padroniza flags e dá saída 0/1 estável
para os eval gates. Todos rodam a partir de qualquer pasta (fazem `cd` para a raiz).

| Script | Faz | Flags |
|---|---|---|
| `build.sh` | `swift build` arm64, warnings viram erro | `--release` |
| `test.sh` | `swift test` (Swift Testing) | `--filter <padrão>` |
| `lint.sh` | `swift format lint --strict` em `Package.swift Sources Tests` | `--fix` |
| `coverage.sh` | Testes com cobertura; exige ≥ N% de linhas do Core (fora `System/`) | `--min <pct>` (padrão 80) |
| `check-architecture.sh` | Regras de fronteira/plataforma (ADR-0002, rules/) | — |
| `check-docs.sh` | Limites de linhas dos `.md` (AGENTS/rules/docs ≤ 100) | — |
| `bundle.sh` | Monta e assina `build/WinTools.app` | `--debug` · env `CODESIGN_IDENTITY`, `BUILD_NUMBER` |
| `run.sh` | Fecha o app aberto, monta em debug e abre | — |
| `package.sh` | `dist/WinTools-<versão>.{zip,dmg,sha256}` | env `CODESIGN_IDENTITY` |
| `bootstrap.sh` | Resumo de contexto: toolchain, git, Handoff do STATE, Status do ROADMAP | — |
| `install-hooks.sh` | Ativa `.githooks/pre-commit` (lint + arquitetura + docs) | — |
| `e2e.sh` | XCUITest: gera projeto via XcodeGen e roda os testes de UI (controla mouse/teclado) | `--filter <Classe/teste>` |
| `verify.sh` | **Gate**: build + lint + arquitetura + docs + testes/cobertura | — |

Comando novo que você repetiu duas vezes → crie um script aqui e adicione na tabela e no `AGENTS.md`.
