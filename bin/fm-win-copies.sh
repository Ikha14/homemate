#!/usr/bin/env bash
# Regenerate the working copies of this repo's two committed symlinks
# (CLAUDE.md -> AGENTS.md, .claude/skills -> .agents/skills) on Windows, where
# git (core.symlinks=false) checks them out as plain text files holding the
# literal target path. The regenerated copies are hidden from git with
# skip-worktree so the tree stays clean and the copies are never committed.
# AGENTS.md and .agents/skills stay the single sources of truth. Idempotent.
# Usage: fm-win-copies.sh
set -eu

usage() {
  echo "usage: fm-win-copies.sh" >&2
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
esac
[ "$#" -eq 0 ] || { usage; exit 1; }

ROOT=$(git rev-parse --show-toplevel)
cd "$ROOT"

WIN_COPY_MARKER='<!-- fm: generated copy of AGENTS.md (Windows, no symlink); edit AGENTS.md instead -->'

# CLAUDE.md: real symlink means nothing to do (symlink-capable checkout).
if [ ! -L CLAUDE.md ]; then
  regen=0
  if [ ! -e CLAUDE.md ]; then
    regen=1
  elif [ "$(cat CLAUDE.md)" = "AGENTS.md" ] || [ "$(cat CLAUDE.md)" = "./AGENTS.md" ]; then
    regen=1
  elif [ "$(head -n 1 CLAUDE.md)" = "$WIN_COPY_MARKER" ]; then
    tail -n +2 CLAUDE.md | cmp -s - AGENTS.md || regen=1
  else
    echo "conflict: CLAUDE.md is neither a degraded symlink nor a generated copy; not touching it" >&2
    exit 1
  fi
  if [ "$regen" -eq 1 ]; then
    { printf '%s\n' "$WIN_COPY_MARKER"; cat AGENTS.md; } > CLAUDE.md
    echo "copied: CLAUDE.md from AGENTS.md"
  fi
  git update-index --skip-worktree CLAUDE.md
fi

# .claude/skills: degraded checkout is a regular FILE holding the target path.
if [ ! -L .claude/skills ]; then
  if [ -f .claude/skills ]; then
    rm .claude/skills
  fi
  if [ ! -d .claude/skills ]; then
    cp -r .agents/skills .claude/skills
    echo "copied: .claude/skills from .agents/skills"
  elif ! diff -rq .agents/skills .claude/skills >/dev/null 2>&1; then
    rm -rf .claude/skills
    cp -r .agents/skills .claude/skills
    echo "copied: .claude/skills resynced from .agents/skills"
  fi
  git update-index --skip-worktree .claude/skills
fi
