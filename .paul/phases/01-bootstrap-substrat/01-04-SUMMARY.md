---
phase: 01-bootstrap-substrat
plan: 04
type: Summary
about: "homemate"
---

# Summary 01-04 — Tests + gate + commit (phase 1 CLOSE)

**Fait (2026-07-18)** :
- `tests/fm-win-substrate.test.sh` committé (contention wake queue, steal stale, trap TERM 29 ms ; skip hors MSYS).
- Suites amont : ensure-agents 9/9 · wake-queue 8/8 · watcher-lock 13/14 · substrat 3/3. 3 windowsismes HORS audit corrigés en route : chmod émulé (→ `fm_pr_file_mode_matches`, 7 sites), grep MinGW strip CRLF (→ sonde `-U`), adoption copies `ln -s` dégradées identiques.
- Différé phase 3 : `restart-healthy-peer` (arm timeout 124 — logique arm/peer, pas le lock).
- **Gate** : workflow /code-review lancé puis STOPPÉ par Ilian (incident forfait — sub-agents Fable hérités ; run `wf_4e4e445c-bba`, cache conservé, NE PAS relancer). Remplacé par **review inline** : 1 défaut corrigé (garde anti-hang du test substrat inopérante en subshell), relaxation sécurité mode→owner validée-bornée, POSIX byte-identique vérifié, pas de clobber `$!`. Verdict GO.
- **Commit local `9adb431`** (20 fichiers, +515/−53). Pas de push.

**Décision de gate pour la suite** : plus jamais de workflow multi-agents sur ce chantier — review inline systématique (règle gravée CLAUDE.md racine + STATE).
