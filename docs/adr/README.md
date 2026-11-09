# docs/adr/ — Architecture Decision Records (para HUMANOS)

Uma decisão de arquitetura/dependência por arquivo (`ADR-0001-...md`). São imutáveis: para
reverter, crie um novo ADR com status "substitui ADR-XXXX". O `AGENTS.md` só aponta para cá.
Modelo: [ADR.template.md](ADR.template.md).

| ADR | Decisão | Status |
|---|---|---|
| [ADR-0001](ADR-0001-swiftpm-sem-xcodeproj.md) | SwiftPM + script de bundle, sem `.xcodeproj` | aceito |
| [ADR-0002](ADR-0002-apenas-apis-publicas.md) | Só APIs públicas; sem injeção em apps da Apple / SIP | aceito |
| [ADR-0003](ADR-0003-plataforma-e-distribuicao.md) | macOS 14+, só arm64, ad-hoc via GitHub Releases | aceito |
| [ADR-0004](ADR-0004-xcuitest-via-xcodegen.md) | Testes ponta a ponta com XCUITest via XcodeGen | aceito |

Gatilho: sempre que os BOUNDARIES do `AGENTS.md` mandarem "registre um ADR" (dependência nova,
novo target/extension, entitlement, mudança de alvo de plataforma).
