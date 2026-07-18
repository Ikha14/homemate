---
phase: 01-bootstrap-substrat
plan: 02
type: Summary
about: "homemate"
---

# Summary 01-02 — fm_ps_field + migration ps

**Fait (2026-07-18)** :
- `bin/fm-ps-lib.sh` créé : `fm_ps_field <pid> <comm|args|ppid|pgid>` (POSIX passthrough / MSYS procfs : `exename`, `cmdline`, `stat` parsé après la parenthèse du comm ; natif → tasklist comm-only, échec propre sinon) + `fm_ps_identity` (POSIX lstart / MSYS starttime+cmdline). Garde anti double-source.
- 6 fichiers migrés : fm-lock (5 sites), fm-harness (3), fm-backend (2), fm-afk-start (1), fm-sessionstart-nudge (1), fm-wake-lib (`fm_pid_identity` délègue). Sourcing via le pattern dir de chaque fichier ; les remontées ppid passent en `|| true` (parité avec l'ancien pipeline `| tr` qui masquait le rc).
- Vérifié : `bash -n` ×7, zéro `ps -o/-p` résiduel dans le scope noyau (fm-watch/daemon = 01-03), `CLAUDECODE=1 fm-harness.sh` → `claude`, identité stable + pid mort rc1.

**Notes build** :
- Sous Windows, l'ancêtre natif (Claude Code node) est invisible du procfs MSYS : la remontée s'arrête à ppid=1, la détection harness repose sur les marqueurs d'env (couche 1 amont, déjà en place).
- `fm_ps_identity` sur pid natif échoue → dégradation `kill -0` + âge heartbeat (risque résiduel spec).
