# ADR-0002: Só APIs públicas; sem injeção em apps da Apple

- **Status**: aceito
- **Data**: 2026-11-09
- **Decisores**: mantenedor (@portillodev1)

## Contexto
A ideia é "aplicar" funcionalidades do Windows em apps existentes (Finder, Terminal) e
reiniciá-los. Ferramentas antigas (SIMBL, mach_inject) faziam isso injetando código, mas no
macOS atual Finder e Terminal são protegidos pelo System Integrity Protection; injeção exige
desligar o SIP — inaceitável para um app distribuído a usuários comuns.

## Decisão
Toda funcionalidade é implementada com APIs públicas e documentadas, rodando no processo do
WinTools (ou em extensões oficiais):
- preferências públicas dos apps (`defaults` de domínios como `com.apple.finder`) + reinício;
- Accessibility (AX), hotkeys globais e event taps, com consentimento do usuário;
- NSPasteboard, NSWorkspace, Apple Events (com permissão de Automação);
- app extensions oficiais (ex.: Finder Sync), se e quando necessário (ver ADR-0001).
"Reiniciar o app afetado" significa encerrar e reabrir via `NSWorkspace` (`AppRestarting`).

## Alternativas consideradas
- Injeção de código / swizzling em Finder e Terminal — exige SIP desligado; inseguro e frágil
  a cada atualização do macOS.
- APIs privadas — quebram sem aviso e impedem notarização futura.

## Consequências
- **Positivas**: funciona com SIP ligado, sem risco ao sistema; caminho aberto para notarizar.
- **Negativas / trade-offs**: algumas funcionalidades do Windows não terão réplica idêntica; o
  comportamento vem "de fora" do app (janelas/painéis do WinTools sobre o Finder/Terminal).
- **Follow-ups**: cada item do `ROADMAP.md` registra na spec qual API pública o viabiliza.
