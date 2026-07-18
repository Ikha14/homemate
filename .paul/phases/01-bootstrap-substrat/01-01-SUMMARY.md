---
phase: 01-bootstrap-substrat
plan: 01
type: Summary
about: "homemate"
---

# Summary 01-01 — Checkout sûr + copies régénérées

**Fait (2026-07-18)** :
- `.gitattributes` posé (`*.sh text eol=lf`), zéro renormalisation (AC-1 ✓).
- `bin/fm-ensure-agents-md.sh` : mode copie sous MSYS/MINGW (marqueur 1re ligne, régénération quand AGENTS.md évolue, blob symlink dégradé reconnu, promotion adaptée, fallback `python3→python`). POSIX inchangé, messages amont exacts préservés. 6 scénarios scratchpad verts dont conflit humain préservé (AC-2 ✓).
- `bin/fm-win-copies.sh` (nouveau) : régénère CLAUDE.md et `.claude/skills` du clone + `git update-index --skip-worktree` — arbre propre, copies jamais committées, idempotent (AC-3 ✓).

**Décisions** :
- Marqueur commun `<!-- fm: generated copy of AGENTS.md (Windows, no symlink); edit AGENTS.md instead -->` = contrat entre les deux scripts.
- skip-worktree = mécanisme « jamais committé » (décision hors spec, tracée au plan).
- CLAUDE.md humain divergent → conflit préservé (jamais écrasé).

**Attention** : tests amont `fm-ensure-agents-md.test.sh` à passer au plan 01-04 (asserts symlink → adaptation attendue côté MSYS). skip-worktree : un futur pull amont touchant ces 2 chemins demandera `--no-skip-worktree` temporaire (documenté ici).

**Diff en attente de commit** (gate /code-review au 01-04) : `.gitattributes` (A), `bin/fm-ensure-agents-md.sh` (M), `bin/fm-win-copies.sh` (A).
