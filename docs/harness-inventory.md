# Inventário de controles do harness

Classificação de cada controle por direção × execução × categoria × estágio. Célula ☐ = buraco
conhecido. Manifesto e gates: [../HARNESS.md](../HARNESS.md).

| Controle | Direção | Execução | Categoria | Estágio | Sinal p/ LLM | Status |
|---|---|---|---|---|---|---|
| `AGENTS.md` (índice) + `rules/*.md` | guia | inferencial | manutenibilidade | pré-geração | — | ✅ |
| ADRs (`docs/adr/`) | guia | inferencial | arquitetura | pré-geração | — | ✅ |
| `rules/features.md` (contrato `Feature`) | guia | inferencial | comportamento | pré-geração | — | ✅ |
| Spec funcional (`tlc-spec-driven`) | guia | inferencial | comportamento | pré-geração | — | ☐ por feature |
| `swift format lint --strict` | sensor | computacional | manutenibilidade | pré-commit | ✅ | ✅ |
| Compilador Swift 6 + warnings-as-errors | sensor | computacional | manutenibilidade | pipeline | ✅ | ✅ |
| Limite de linhas dos `.md` | sensor | computacional | manutenibilidade | pré-commit | ✅ | ✅ |
| Teste estrutural de fronteiras/plataforma | sensor | computacional | arquitetura | pré-commit | ✅ | ✅ |
| Verificação de assinatura (`codesign --verify`) | sensor | computacional | arquitetura | pipeline | ✅ | ✅ |
| Testes unitários (Swift Testing) | sensor | computacional | comportamento | pipeline | ✅ | ✅ |
| Cobertura ≥ 80% do Core | sensor | computacional | comportamento | pipeline | ✅ | ✅ |
| Mutation testing | sensor | computacional | comportamento | pipeline | ☐ | ☐ (sem ferramenta madura p/ Swift) |
| Teste de UI / e2e do menu (XCUITest) | sensor | computacional | comportamento | pré-PR / pipeline | ✅ | ✅ (`e2e.sh`) |
| Teste de performance (CPU/memória ociosos) | sensor | computacional | arquitetura | pipeline | ☐ | ☐ (quando houver clipboard polling) |
| Code review agent | sensor | inferencial | manutenibilidade | pré-integração | — | ✅ sob demanda |
| Dead code / drift | sensor | computacional | manutenibilidade | contínuo | ☐ | ☐ (avaliar Periphery via ADR) |

## Buracos priorizados
1. **Performance ociosa** — o histórico de clipboard fará polling do `NSPasteboard`; medir CPU
   em repouso antes de marcar `clipboard-history` como `.available`.
2. **Dead code** — Periphery é dependência nova → ADR quando o código passar de alguns milhares
   de linhas.
