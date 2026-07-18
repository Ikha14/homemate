---
description: "homemate — current position and accumulated context"
type: ProjectState
about: "homemate"
---

# Project State

## Project Reference

See: .paul/PROJECT.md (updated 2026-07-18)

**Core value:** Supervision de flotte d'agents Claude Code nativement sous Windows, source unique `~/.claude`, sans détour WSL2.
**Current focus:** Project initialized — ready for planning

## Current Position

Milestone: v0.1 Portage Windows (pilote GO)
Phase: 1 of 5 (Bootstrap & substrat process) — **COMPLETE** (commit local `9adb431`)
Plan: 4/4 faits
Status: Prêt pour /paul:plan phase 2 (herdr + treehouse)
Last activity: 2026-07-18 — Review inline GO, commit `9adb431`, passation écrite

Progress:
- Milestone: [████░░░░░░] 20%
- Phase 1: [██████████] 100%

## Loop Position

Current loop state:
```
PLAN ──▶ APPLY ──▶ UNIFY
  ✓        ✓        ✓     [Phase 1 close — prochain PLAN = 02-01]
```

## Accumulated Context

### Decisions

Toutes les décisions d'implémentation sont dans PROJECT.md § Key Decisions et la spec vault (`PRD.md`, source canonique). Rien décidé hors spec depuis l'init.

### Deferred Issues

| Issue | Origin | Effort | Revisit |
|-------|--------|--------|---------|
| Écarts amont : (2) et (4) RÉSORBÉS sous Windows par le lock mkdir (01-03) ; restent (1) parse `stale:` et (3) fuite singleton watcher | Annexe PRD | S | Phases 3-4 |
| Test amont `restart-healthy-peer` (fm-watcher-lock) : arm timeout 124 au lieu de reporter le peer sain — logique arm/peer | Run tests 01-04 | M | Phase 3 (watcher) |
| Windowsisme HORS audit découvert : chmod émulé MSYS (0700→644) → gates de mode dégradées en contrôle propriétaire (`fm_pr_file_mode_matches`, 7 sites + private_file_valid) — relaxation sécurité signalée au /code-review | Tests 01-04 | fait | Verdict review |
| Portable ARM64 | Spec § Out of Scope | M | Ticket futur après GO tour x64 |

### Blockers/Concerns

**RÈGLE ABSOLUE CHANTIER (2026-07-18, incident forfait ×2)** : outil Workflow + workflows nommés INTERDITS (sub-agents hérités en Fable). Review = inline. Sub-agent individuel = uniquement `model: "opus"|"sonnet"` explicite, sinon zéro sub-agent. Run review interrompu : `wf_4e4e445c-bba` (cache conservé, NE PAS relancer).

## Session Continuity

Last session: 2026-07-18 (session `b519eac2…`)
Stopped at: Phase 1 close (commit `9adb431`), incident forfait tracé
Next action: /paul:plan phase 2 — backend herdr (`cwd`) + treehouse (`get --lease`) ; matériel empirique : tickets 03/04 + scratchpads `ticket-04/` et `ticket-07/` de la session `5c7e1500…`
Resume context: **Lire le HANDOFF v4** (scratchpad session `b519eac2…/HANDOFF-homemate-2026-07-18-v4.md`) ; spec = PRD.md vault ; review INLINE only (jamais Workflow) ; travailler DANS le clone.

---
*STATE.md — Updated after every significant action*
