---
description: "Superviser la flotte d'agents Claude Code nativement sous Windows, sans détour WSL2 ni duplication de config"
type: Project
about: "homemate"
---

# HomeMate

## What This Is

Portage minimal-invasif de FirstMate (supervision multi-agents Claude Code, POSIX) vers Windows natif : dépôt `Ikha14/homemate` (copie liée de `kunchenguid/firstmate`), backend herdr.exe, bacs à sable treehouse, scripts sous Git Bash. Chaque construction POSIX cassée (verrous symlink, `ps -o/-p`, socket Unix, symlinks committés) est remplacée par un équivalent Windows déjà prouvé empiriquement (tickets 03-08 du vault).

**Document d'entrée canonique (contrat du build)** : `C:\Users\llian\OneDrive - Auto-entreprise\# Obsidian_Second_Memory\projects\outils\homemate\PRD.md` (statut `prete`). Tableau des windowsismes : `audit-windowsismes-bin.md` (même dossier). Ce PROJECT.md est un digest — la spec fait foi.

## Core Value

Ilian pilote sa flotte d'agents (spawn isolé, surveillance zéro-token, mode absent, secondmates) nativement sous Windows, avec sa source unique `~/.claude` — sans détour Linux.

## Current State

| Attribute | Value |
|-----------|-------|
| Type | Application (portage outillage) |
| Version | 0.0.0 (HEAD `bc1a21b`, arbre propre) |
| Status | Initializing |
| Last Updated | 2026-07-18 |

## Requirements

### Core Features

- `/homemate` : onglet herdr « supervision » (2 cases : watcher + daemon /afk), création idempotente, à la demande — rien ne tourne sans cet ordre (US 1, 7)
- Spawn d'agent (`fm-spawn`) sur dépôt git Windows, bac à sable treehouse leased, garde d'isolement (US 2-4)
- Surveillance zéro-token : canal rapide named pipe Windows (< 1 s) + filet périodique ~15 s fail-closed (US 5-6)
- Mode absent (`/afk`) : pilote automatique + alarme Telegram (outil telegram/ existant) quand agent coincé (US 8-9)
- Teardown propre : arbre de processus tué, bac rendu, zéro orphelin (US 10)
- Bootstrap : copies régénérées `CLAUDE.md`/`.claude/skills` (symlinks proscrits), `.gitattributes` `*.sh text eol=lf` (US 13)
- Rapatriement amont (`git fetch upstream` + avance rapide) et clonage second PC (US 14-15)
- Secondmates (US 16)

### Validated (Shipped)
None yet.

### Active (In Progress)
None yet.

### Planned (Next)

- Phase 1 suggérée par la spec : bootstrap Windows (copies régénérées, `.gitattributes`, wrapper `fm_ps_field`, lock `mkdir`, `sleep N & wait $!`)
- Découpage complet des phases : `/paul:plan`

### Out of Scope

- X mode, harness non-Claude (Grok, Pi, Codex, OpenCode), backends zellij/orca/cmux/tmux — fichiers laissés, jamais appelés ni portés
- Supervision de dépôts OneDrive (vault, site) — phase 2, nouvelle carte
- Renommage interne « HomeMate » — jamais
- Réécriture PowerShell / tâche planifiée du watcher — écartées au grilling
- Portable ARM64 — ticket futur (cible v1 = tour x64)

## Constraints

### Technical Constraints

- Portage **minimal-invasif** : noms `fm-*` et architecture d'origine conservés ; diff minimal avec l'amont
- `core.symlinks=true` proscrit (avorte le checkout sans privilège symlink) ; `core.autocrlf=false` + `core.longpaths=true` ; 100 % LF
- Git Bash de Git for Windows uniquement (jamais WindowsApps/WSL) ; `jq` sur le PATH sinon garde silencieusement désactivée ; `python` (pas `python3`)
- herdr.exe protocole 16 ; `foreground_cwd` inexistant → lire `cwd`, entrée bac à sable par `cd` top-level
- treehouse : `get --lease` (stdout seul, backslash, espaces littéraux), `return --force`, `root = "./"`, lease gardé toute la vie de l'agent, HEAD détaché possible, normaliser `\`/`/` avant comparaison de chemins
- Remplacements prouvés : lock `mkdir` atomique (jamais symlink), wrapper `fm_ps_field` (jamais `ps -o/-p`), `sleep N & wait $!`, sentinelle avant kill d'un `.exe` natif, pgid via colonne PGID + `set -m` ; appends `>>` atomiques conservés

### Business Constraints

- Solo (Ilian), tour x64 `DESKTOP-TLNLJD7` d'abord
- Gate par lot : `/code-review` sur le diff de chaque lot (revue en bloc amont abandonnée pour coût)
- Garde coût multi-agents (CLAUDE.md racine) : > 10 agents → estimation tokens + go explicite ; sub-agents Opus 4.8 / Sonnet 5.0, jamais Fable

## Key Decisions

| Decision | Rationale | Date | Status |
|----------|-----------|------|--------|
| Backend unique herdr.exe natif | Prouvé ticket 03, couche CRUD/spawn/capture OK telle quelle | 2026-07-18 | Active |
| Watcher dans case herdr dédiée (pas de process détaché ni tâche planifiée) | Grilling architecture ticket 06 | 2026-07-18 | Active |
| Symlinks committés → copies régénérées au bootstrap, jamais committées | Ticket 07 ; AGENTS.md reste source unique | 2026-07-18 | Active |
| Lock symlink → lock `mkdir` partout | Gel MSYS prouvé ticket 05 ; sans chevauchement sous contention | 2026-07-18 | Active |
| Canal rapide → client named pipe `\\.\pipe\` (handshake pid:nonce) | Socket Unix absent ; fichier socket herdr contient `<pid>:<nonce>` | 2026-07-18 | Active |
| Alarme mode absent : Telegram uniquement | Outil telegram/ existant ; pas de notif Windows | 2026-07-18 | Active |
| Build piloté par PAUL dans le clone, spec dans le vault | Frontière code/vault (passation PRD) | 2026-07-18 | Active |

## Success Metrics

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Pilote bout en bout dépôt jetable (spawn→lease→supervision→afk→Telegram simulé→teardown zéro orphelin) | Passe complet | - | Not started |
| Pilote rejoué sur vrai projet Node `# Indé/` (critère GO) | Passe complet | - | Not started |
| Tests substrat (harness.sh, signals2.sh, mkdir_lock.sh copiés comme tests) | Verts sous Git Bash | - | Not started |
| Suite `tests/` amont (modules portés) | Verte sous Git Bash quand prérequis présents ; casse non-Windows = régression | - | Not started |
| Écarts amont annexe PRD (4 trouvailles concurrence) | Confirmés/infirmés pendant le build | - | Not started |

## Tech Stack / Tools

| Layer | Technology | Notes |
|-------|------------|-------|
| Scripts | Bash (Git Bash de Git for Windows) | Portage in-place, LF |
| Backend multiplexeur | herdr.exe v0.7.4, protocole 16 | Natif Windows |
| Bacs à sable | treehouse v2.0.0 | `get --lease` / `return --force` |
| Canal événements | Named pipe Windows via `python` | Remplace socket Unix |
| Alerte absent | telegram/ (racine OneDrive) | Brouillons/messages Telegram |
| GitHub | gh 2.96.0, compte `Ikha14` | fork + upstream firstmate |
| JSON | jq 1.8.2 | Requis par hooks |

## Links

| Resource | URL |
|----------|-----|
| Repository | https://github.com/Ikha14/homemate |
| Upstream | https://github.com/kunchenguid/firstmate |
| Spec (PRD) | `# Obsidian_Second_Memory/projects/outils/homemate/PRD.md` |
| Audit windowsismes | `# Obsidian_Second_Memory/projects/outils/homemate/audit-windowsismes-bin.md` |
| Tickets empiriques | `# Obsidian_Second_Memory/projects/outils/homemate/issues/01..09-*.md` |

---
*PROJECT.md — Updated when requirements or context change*
*Last updated: 2026-07-18*
