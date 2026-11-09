# Release, assinatura e CI

## Versionamento
- Versão de marketing: arquivo `VERSION` (SemVer, ex.: `0.1.0`) → `CFBundleShortVersionString`.
- Número de build: `BUILD_NUMBER` (env) ou contagem de commits → `CFBundleVersion`.
- Tag de release: `v<VERSION>` (ex.: `v0.1.0`). A tag precisa bater com o arquivo `VERSION`.

## Artefatos
`scripts/package.sh` gera em `dist/`:
- `WinTools-<versão>.zip` — o `.app` compactado com `ditto`.
- `WinTools-<versão>.dmg` — imagem com o app e um atalho para `/Applications`.
- `WinTools-<versão>.sha256` — checksums dos dois.

## Assinatura
- Padrão: **ad-hoc** (`codesign --sign -`), com hardened runtime. Grátis, mas o Gatekeeper avisa
  no primeiro uso (ver README → "Instalar").
- Developer ID (futuro): `CODESIGN_IDENTITY="Developer ID Application: Nome (TEAMID)" scripts/package.sh`.
  Notarização (`xcrun notarytool`) ainda não está no pipeline — exige ADR quando for adotada.
- Nunca versione certificados, `.p12` ou senhas. No CI, use secrets do GitHub.

## CI (GitHub Actions)

| Workflow | Gatilho | Faz |
|---|---|---|
| `.github/workflows/ci.yml` | push/PR na `main` | `scripts/verify.sh` em runner macOS arm64 |
| `.github/workflows/release.yml` | push de tag `v*` | confere tag × `VERSION`, roda `package.sh`, publica a Release |

## Passo a passo de uma release
1. Atualize `VERSION` e o `ROADMAP.md`; abra PR; CI verde; merge.
2. `git tag v$(cat VERSION) && git push origin v$(cat VERSION)`.
3. O workflow `release.yml` publica zip, dmg e sha256 na página de Releases.
