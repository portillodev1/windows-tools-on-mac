# WinTools

Funcionalidades do Windows que fazem falta no Mac, ativadas com um clique na barra de menus.

O WinTools coloca um ícone na barra superior do macOS. Ao clicar, ele lista as funcionalidades
disponíveis; você liga a que quiser, o WinTools reinicia os apps afetados e a funcionalidade
passa a valer.

| Funcionalidade | No Windows | Status |
|---|---|---|
| Histórico da área de transferência | `Win + V` | planejado |
| Janelas no Terminal | Windows Terminal | escopo a definir |
| Janelas no Finder | Explorador de Arquivos | escopo a definir |

Detalhes e próximos passos: [ROADMAP.md](ROADMAP.md).

> **Requisitos:** Mac com **Apple Silicon** (M1 ou mais novo) e **macOS 14 Sonoma** ou superior.
> Macs Intel não são suportados por enquanto.

## Instalar (usuário final)

1. Baixe o `WinTools-<versão>.dmg` na página de [Releases](https://github.com/portillodev1/windows-tools-on-mac/releases).
2. Abra o `.dmg` e arraste o **WinTools** para **Aplicativos**.
3. Abra o WinTools. Como o app ainda não é notarizado pela Apple, o macOS bloqueia o primeiro uso:
   vá em **Ajustes do Sistema → Privacidade e Segurança** e clique em **Abrir Mesmo Assim**.
   (Alternativa no terminal: `xattr -dr com.apple.quarantine /Applications/WinTools.app`.)
4. O ícone aparece na barra de menus. Não há ícone no Dock.

## Rodar localmente (desenvolvimento)

### Pré-requisitos
- Mac Apple Silicon com macOS 14+.
- **Xcode 16 ou mais novo** (Swift 6, `swift format`, Swift Testing e XCUITest), selecionado com
  `sudo xcode-select -s /Applications/Xcode.app`.
- Só para os testes de UI: [Homebrew](https://brew.sh) + `brew bundle` (instala o XcodeGen do `Brewfile`).

### Passo a passo

```bash
git clone https://github.com/portillodev1/windows-tools-on-mac.git
cd windows-tools-on-mac
scripts/install-hooks.sh   # ativa o pre-commit (lint + arquitetura + docs)
scripts/run.sh             # compila, monta build/WinTools.app e abre
```

O ícone aparece na barra de menus. Para depurar no Xcode: `xed .` e o esquema **WinTools**
(o projeto é um pacote SwiftPM; o `.xcodeproj` dos testes de UI é gerado, não versionado).

### Comandos do dia a dia

| Quero… | Rode |
|---|---|
| Compilar | `scripts/build.sh` |
| Rodar os testes | `scripts/test.sh` (ou `--filter <nome>`) |
| Corrigir formatação | `scripts/lint.sh --fix` |
| Checar tudo antes de abrir PR | `scripts/verify.sh` |
| Testes ponta a ponta (XCUITest) | `scripts/e2e.sh` |

O `verify.sh` é o mesmo gate do CI: build sem warnings, lint, regras de arquitetura, limite de
tamanho dos docs e testes com cobertura ≥ 80% do `WinToolsCore`. O `e2e.sh` abre o app de verdade e
**controla mouse e teclado** por alguns segundos; na 1ª vez o macOS pede para autorizar a automação de
UI. Lista completa: [scripts/README.md](scripts/README.md).

## Gerar uma nova versão

### Build local do instalador

```bash
scripts/package.sh
```

Gera em `dist/`: `WinTools-<versão>.zip`, `WinTools-<versão>.dmg` e o `.sha256`. A versão vem do
arquivo [`VERSION`](VERSION). A assinatura é **ad-hoc** por padrão; para assinar com um
certificado Developer ID, defina `CODESIGN_IDENTITY="Developer ID Application: Nome (TEAMID)"`.

### Publicar uma release no GitHub
1. Atualize o arquivo `VERSION` (SemVer, ex.: `0.2.0`) e o `ROADMAP.md`, abra um PR e faça merge
   com o CI verde.
2. Crie e envie a tag (precisa ser igual a `v` + `VERSION`):

```bash
git tag v$(cat VERSION) && git push origin v$(cat VERSION)
```

3. O workflow [`release.yml`](.github/workflows/release.yml) roda o gate, empacota e publica o
   `.zip`, o `.dmg` e o `.sha256` na página de Releases.

Mais detalhes (versionamento, assinatura, CI): [docs/release.md](docs/release.md).

## Contribuir
- Arquitetura e fluxo "ativar → reiniciar app": [docs/architecture.md](docs/architecture.md).
- Decisões (por que SwiftPM, por que só APIs públicas, por que só arm64): [docs/adr/](docs/adr/README.md).
- Usa um agente de código? Ele começa pelo [AGENTS.md](AGENTS.md).
- Toda funcionalidade usa só APIs públicas da Apple — nada de injetar código no Finder/Terminal
  nem pedir para desligar o SIP.

## Licença
[Apache-2.0](LICENSE).
