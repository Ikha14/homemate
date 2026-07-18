---
description: "homemate — milestone and phase structure"
type: Roadmap
about: "homemate"
---

# Roadmap: HomeMate

## Overview

Porter FirstMate vers Windows natif en remplaçant chaque construction POSIX cassée par son équivalent prouvé (tickets 03-08, audit windowsismes), du bootstrap du dépôt jusqu'au pilote de bout en bout sur un vrai projet Node — critère GO du portage.

## Current Milestone

**v0.1 Portage Windows (pilote GO)** (v0.1.0)
Status: In progress
Phases: 0 of 5 complete

## Phases

| Phase | Name | Plans | Status | Completed |
|-------|------|-------|--------|-----------|
| 1 | Bootstrap & substrat process | 4 | Planning | - |
| 2 | Backend herdr + bacs à sable treehouse | ~2 | Not started | - |
| 3 | Supervision (canal rapide + watcher + /homemate) | ~3 | Not started | - |
| 4 | Mode absent (/afk + Telegram) | ~2 | Not started | - |
| 5 | Pilote bout en bout (GO) | ~2 | Not started | - |

## Phase Details

### Phase 1: Bootstrap & substrat process

**Goal:** Le dépôt et le socle process fonctionnent sous Git Bash : checkout sûr, copies régénérées, introspection process portable, verrous atomiques, boucles interruptibles.
**Depends on:** Nothing (first phase)
**Research:** Unlikely (tout est prouvé empiriquement — tickets 05/07/08, audit fichier:ligne)

**Scope:**
- `.gitattributes` (`*.sh text eol=lf`) — parade re-clone autocrlf
- Symlinks committés → copies régénérées (`fm-ensure-agents-md.sh` : `ln -s`/`readlink`/`[ -L ]` → stratégie copie ; fallback `python3`→`python`)
- Wrapper `fm_ps_field` portable (procfs MSYS / tasklist) + migration des 6 clusters `ps -o/-p` (fm-lock, fm-harness, fm-backend, fm-afk-start, fm-sessionstart-nudge, fm-wake-lib)
- Lock symlink → lock `mkdir` (fm-wake-lib, fm-afk-start) ; kill de groupe dégradé (fm-watch, fm-supervise-daemon) ; `sleep` nu → `sleep N & wait $!` (boucles chaudes)
- Tests substrat copiés dans `tests/` (mini-harnais tickets 03/05)

**Plans:**
- [ ] 01-01: Checkout sûr + copies régénérées (`.gitattributes`, fm-ensure-agents-md.sh)
- [ ] 01-02: Wrapper `fm_ps_field` + migration des call sites `ps`
- [ ] 01-03: Lock `mkdir` + kill de groupe dégradé + sleep interruptible
- [ ] 01-04: Tests substrat + passe tests amont phase 1 + gate /code-review du lot

### Phase 2: Backend herdr + bacs à sable treehouse

**Goal:** Spawn d'un agent sur dépôt git Windows dans un bac à sable treehouse leased, garde d'isolement, teardown propre.
**Depends on:** Phase 1 (fm_ps_field, locks, kill)
**Research:** Unlikely (tickets 03/04 : adaptateur herdr CRUD OK tel quel ; `cwd` au lieu de `foreground_cwd` ; treehouse `get --lease`/`return --force`, normalisation `\`/`/`)

**Scope:**
- Adaptateur herdr : lecture `cwd`, entrée bac à sable par `cd` top-level
- fm-spawn : lease treehouse (stdout seul), `root = "./"`, lease gardé à vie, HEAD détaché prévu
- Garde d'isolement (normalisation chemins), teardown (sentinelle avant kill `.exe`, arbre par descendants)

### Phase 3: Supervision (canal rapide + watcher + /homemate)

**Goal:** Surveillance zéro-token : canal named pipe < 1 s, filet 15 s fail-closed, watcher dans case herdr, onglet « supervision » idempotent via `/homemate`.
**Depends on:** Phase 2 (agents à surveiller)
**Research:** Unlikely (réécriture named pipe décidée ticket 03 : client `\\.\pipe\`, handshake pid:nonce, `python` pas `python3`)

**Scope:**
- `herdr-eventwait.py` réécrit named pipe ; `herdr.sh` L1238-1272 (`python3`→`python`), L1375-1379 (mkfifo→pipe), gate de capacité réel
- Watcher case herdr dédiée ; vérifier écart amont (3) fuite verrou singleton
- Commande `/homemate` : onglet supervision, création idempotente, 2 cases

### Phase 4: Mode absent (/afk + Telegram)

**Goal:** Daemon /afk dans sa case, pilote automatique, alarme Telegram quand agent coincé.
**Depends on:** Phase 3 (canal + watcher)
**Research:** Unlikely (outil telegram/ existant ; osascript resté gardé Darwin)

**Scope:**
- fm-afk-* sur socle phase 1 (lock mkdir, fm_ps_field)
- Alarme « agent coincé » → Telegram uniquement
- Vérifier écart amont (1) : parse des réveils `stale:` à suffixe parenthésé

### Phase 5: Pilote bout en bout (GO)

**Goal:** Critère GO : pilote complet sur dépôt jetable, rejoué sur vrai projet Node `# Indé/` (cloné hors OneDrive).
**Depends on:** Phases 1-4
**Research:** Unlikely (spec § Testing Decisions)

**Scope:**
- Pilote : `/homemate` → spawn → lease → blocage détecté/réveil → /afk + Telegram simulé → teardown zéro orphelin
- Rejeu sur projet Node réel ; docs second PC + rapatriement amont (US 14-15)
- Statuer sur les 4 écarts amont (annexe PRD)

---
*Roadmap created: 2026-07-18*
*Last updated: 2026-07-18*
