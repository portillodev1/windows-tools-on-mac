# ROADMAP

Funcionalidades do Windows a trazer para o macOS. Cada uma vira uma spec em
`.specs/<feature-id>/` (skill `tlc-spec-driven`) antes de ser implementada.

## Status

| # | Feature ID | Funcionalidade | Equivalente no Windows | Status |
|---|---|---|---|---|
| 0 | — | Base: app de barra de menus, catálogo, ativar/reiniciar, pipeline de release | — | ✅ feito (0.1.0) |
| 1 | `clipboard-history` | Histórico da área de transferência | Win + V | 📋 planejado |
| 2 | `terminal-windows` | Janelas no Terminal | Windows Terminal | ❓ escopo a definir |
| 3 | `finder-windows` | Janelas no Finder | Explorador de Arquivos | ❓ escopo a definir |

## 1. Histórico da área de transferência (`clipboard-history`)
- Ideia: guardar os últimos N itens copiados (texto, imagem, arquivos) e abrir um painel
  flutuante com um atalho global para colar o escolhido.
- APIs prováveis: `NSPasteboard.changeCount` (polling), hotkey global, painel `NSPanel`,
  Accessibility para simular o colar.
- Em aberto: atalho padrão (`⌘⇧V`? `⌃V`?), limite de itens, persistência em disco ou só
  memória, ignorar itens de gerenciadores de senha (`org.nspasteboard.ConcealedType`).
- Apps afetados: nenhum (não precisa reiniciar nada).

## 2. Janelas no Terminal (`terminal-windows`) — ❓ precisa de definição
O Terminal.app já tem abas nativas. Antes da spec, decidir qual comportamento do Windows é o
alvo, por exemplo:
- painéis divididos (split) como no Windows Terminal;
- abrir sempre em aba em vez de janela nova;
- "Abrir no Terminal" no menu de contexto de uma pasta.

## 3. Janelas no Finder (`finder-windows`) — ❓ precisa de definição
O Finder também já tem abas. Possíveis alvos:
- encaixe de janelas (snap) estilo Windows (`Win + ←/→`) — vale para qualquer app;
- comportamentos do Explorador (barra de endereço editável, recortar/colar arquivos com
  `⌘X`, mostrar extensões/arquivos ocultos com um clique).

## Fora de escopo por enquanto
- Macs Intel, macOS < 14, Mac App Store (ver ADR-0003).
- Qualquer coisa que exija desligar o SIP ou injetar código em apps da Apple (ver ADR-0002).
