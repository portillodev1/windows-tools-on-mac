# ADR-0003: macOS 14+, só Apple Silicon, distribuição ad-hoc no GitHub

- **Status**: aceito
- **Data**: 2026-11-09
- **Decisores**: mantenedor (@portillodev1)

## Contexto
O público inicial são MacBooks com Apple Silicon. O projeto não tem (ainda) conta paga no
Apple Developer Program, que é o que permite assinatura Developer ID e notarização.

## Decisão
- Alvo mínimo **macOS 14 Sonoma**; build **somente arm64** (`--arch arm64`,
  `LSArchitecturePriority = arm64`).
- Releases no **GitHub Releases** como `.zip` e `.dmg`, com **assinatura ad-hoc** e hardened
  runtime, geradas por `scripts/package.sh` e pelo workflow `release.yml` em tags `v*`.
- O pipeline aceita `CODESIGN_IDENTITY` para trocar por Developer ID sem mudar scripts.

## Alternativas consideradas
- Universal binary (arm64 + x86_64) — fora do escopo atual; dobra a matriz de testes.
- Developer ID + notarização desde já — custo anual; adiado até haver usuários.
- Mac App Store — sandbox inviabiliza reiniciar outros apps e boa parte das funcionalidades.

## Consequências
- **Positivas**: custo zero; build reproduzível localmente e no CI.
- **Negativas / trade-offs**: o Gatekeeper bloqueia o primeiro uso; o usuário precisa liberar em
  Ajustes do Sistema → Privacidade e Segurança (documentado no README). Permissões de
  Acessibilidade podem precisar ser concedidas de novo a cada versão (assinatura ad-hoc muda).
- **Follow-ups**: ADR para Developer ID + `notarytool` quando adotado; reavaliar Intel se houver
  demanda.
