# rules/features.md — carregada em: nova funcionalidade do Windows

Uma "funcionalidade" é um item que o usuário liga/desliga no menu. Fluxo de especificação:
skill `tlc-spec-driven` (artefatos em `.specs/<feature-id>/`).

## Contrato
- Metadados em `FeatureCatalog` (`FeatureDescriptor`); comportamento num tipo que conforma a
  `Feature` (`apply()` / `revert()`), registrado em `WinToolsApp` via `implementations:`.
- `FeatureID` é kebab-case e **estável** (é persistido). Nunca renomeie um já publicado.
- `availability: .planned` até a implementação passar no gate; só então `.available`.
- `affectedApps` lista os bundle ids a reiniciar (ex.: `com.apple.finder`). Vazio se nada precisa
  reiniciar. Quem reinicia é **só** o `FeatureManager` via `AppRestarting`.
- `revert()` restaura exatamente o estado anterior a `apply()` (inclusive preferências do usuário
  que já existiam — leia e guarde antes de sobrescrever).
- `apply()`/`revert()` são idempotentes: rodar duas vezes não quebra nada.

## Limites de plataforma (ADR-0002)
- Permitido: APIs públicas (NSPasteboard, Accessibility/AX, CGEventTap/hotkeys, NSWorkspace,
  `defaults` de domínio público, Apple Events com consentimento, app extensions oficiais).
- Proibido: injeção de código em Finder/Terminal, swizzling em processo alheio, API privada,
  pedir para desligar SIP.
- Se a funcionalidade só é viável com algo proibido → PARE e reporte; registre no `ROADMAP.md`.

## Checklist de pronto
1. Spec com objetivo verificável em `.specs/<feature-id>/spec.md`.
2. Testes de `apply`/`revert`/idempotência com fakes (`rules/tests.md`).
3. Permissões declaradas + usage strings no `Support/Info.plist`.
4. Verificação manual com `scripts/run.sh` descrita no PR.
5. `ROADMAP.md` atualizado; `scripts/verify.sh` = 0.
