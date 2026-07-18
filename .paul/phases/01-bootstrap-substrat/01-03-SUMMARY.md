---
phase: 01-bootstrap-substrat
plan: 03
type: Summary
about: "homemate"
---

# Summary 01-03 — Lock mkdir + pgid + sleeps interruptibles

**Fait (2026-07-18)** :
- fm-wake-lib.sh : `FM_LOCK_DIR_MODE` (=MSYS, overridable) ; branches dir sur les 3 primitives symlink-only (`fm_lock_try_create` = mkdir atomique + pid dedans + garde steal ; `fm_lock_points_to_owner` ; `fm_lock_link_owner`). Le reste de la machine d'états était déjà dir-aware (release/remove_path/recheck) — zéro changement. POSIX byte-identique.
- fm-watch.sh L483 : pgid via `fm_ps_field` (kill de groupe re-alimenté — il marche sous `set -m`, ticket 05).
- fm-supervise-daemon.sh L697 : watchdog `kill -0 "-$pid" || kill -0 "$pid"` (sinon watchdog sauté et `wait` bloquant sous MSYS).
- Sleeps ≥1 s des boucles à trap → `sleep X & wait $! || true` (daemon ×4, watch ×4, teardown ×2, spawn ×1). Les 0.1-0.3 s restent nus (fork MSYS ~5 ms, latence déjà ≤ durée — choix documenté).

**Vérifié** : contention 3 racers via la vraie `fm_wake_append` — zéro hang (vs hang infini prouvé avant port), lignes exactes, 5 champs intacts, zéro lock résiduel ; steal d'un lock stale (pid mort + vieux) → acquisition + release propres ; `bash -n` ×5.

**Écarts amont (annexe PRD)** : (2) acquisition non-atomique → **résorbé sous Windows** (mkdir atomique) ; (4) récursion lock sur état inécrivable → mkdir échoue proprement (pas de récursion en mode dir). (1) parse `stale:` et (3) fuite singleton watcher restent à vérifier (phases 3-4).

**Résiduel documenté** : un lockdir laissé comme FICHIER régulier (état corrompu exotique) ferait spinner `acquire_wait` — non traité (machine d'états intacte, frontière du plan). Perf : ~0,4 s/append sous contention (fork MSYS) — OK pour la fréquence de supervision.
