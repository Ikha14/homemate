#!/usr/bin/env bash
# Portable process-introspection helpers. The MSYS procps `ps` ignores `-o`
# and `-p`, so every `ps -o <field>= -p <pid>` call site routes through
# fm_ps_field instead: real ps on POSIX, /proc + tasklist on Git Bash/MSYS.
# Native Windows processes (herdr.exe, a native harness) have no MSYS procfs
# entry and are invisible to the MSYS process tree; fm_ps_field then falls
# back to tasklist for comm and fails cleanly for args/ppid/pgid, and parent
# walks stop at the MSYS boundary (top-level ppid reads as 1).
# Sourced, not executed.

if [ -n "${FM_PS_LIB_SOURCED:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
FM_PS_LIB_SOURCED=1

case "$(uname -s)" in
  MSYS*|MINGW*) FM_PS_MSYS=1 ;;
  *) FM_PS_MSYS=0 ;;
esac

# fm_ps_stat_field <pid> <n>: field n of /proc/<pid>/stat counted AFTER the
# "(comm)" token — comm may contain spaces, so split on the closing paren.
# n=1 state, n=2 ppid, n=3 pgid, n=20 starttime.
fm_ps_stat_field() {
  local pid=$1 n=$2 rest
  rest=$(sed 's/^[^)]*) //' "/proc/$pid/stat" 2>/dev/null) || return 1
  [ -n "$rest" ] || return 1
  printf '%s\n' "$rest" | awk -v n="$n" '{print $n}'
}

# fm_ps_field <pid> <comm|args|ppid|pgid>: one field for one pid, or rc!=0.
fm_ps_field() {
  local pid=$1 field=$2 out exe
  case "$pid" in
    ''|*[!0-9]*) return 1 ;;
  esac
  if [ "$FM_PS_MSYS" -ne 1 ]; then
    case "$field" in
      comm) out=$(ps -o comm= -p "$pid" 2>/dev/null) ;;
      args) out=$(ps -o args= -p "$pid" 2>/dev/null) ;;
      ppid) out=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ') ;;
      pgid) out=$(ps -o pgid= -p "$pid" 2>/dev/null | tr -d ' ') ;;
      *) return 1 ;;
    esac
    [ -n "$out" ] || return 1
    printf '%s\n' "$out"
    return 0
  fi
  if [ -e "/proc/$pid/stat" ]; then
    case "$field" in
      comm)
        exe=$(cat "/proc/$pid/exename" 2>/dev/null)
        if [ -n "$exe" ]; then
          out=$(basename "$exe")
          out=${out%.exe}
        else
          out=$(sed 's/^[^(]*(//; s/).*$//' "/proc/$pid/stat" 2>/dev/null)
        fi
        ;;
      args)
        out=$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null)
        out=${out% }
        ;;
      ppid) out=$(fm_ps_stat_field "$pid" 2) ;;
      pgid) out=$(fm_ps_stat_field "$pid" 3) ;;
      *) return 1 ;;
    esac
    [ -n "$out" ] || return 1
    printf '%s\n' "$out"
    return 0
  fi
  # Native Windows process: only comm is recoverable, via tasklist.
  if [ "$field" = comm ] && command -v tasklist >/dev/null 2>&1; then
    out=$(tasklist /FI "PID eq $pid" /FO CSV /NH 2>/dev/null | head -n 1)
    case "$out" in
      \"*\",*)
        out=${out#\"}
        out=${out%%\"*}
        out=${out%.exe}
        printf '%s\n' "$out"
        return 0
        ;;
    esac
  fi
  return 1
}

# fm_ps_identity <pid>: stable anti-recycling identity for a live pid.
# POSIX: locale-pinned lstart + command (upstream behaviour). MSYS: procfs
# starttime (clock ticks since boot, unique per incarnation) + cmdline; a
# native pid with no procfs entry fails, and callers degrade to
# `kill -0` + heartbeat age (documented residual risk, ticket 05).
fm_ps_identity() {
  local pid=$1 out start args
  case "$pid" in
    ''|*[!0-9]*) return 1 ;;
  esac
  if [ "$FM_PS_MSYS" -ne 1 ]; then
    out=$(LC_ALL=C ps -p "$pid" -o lstart= -o command= 2>/dev/null) || return 1
    [ -n "$out" ] || return 1
    printf '%s\n' "$out" | sed 's/^[[:space:]]*//'
    return 0
  fi
  start=$(fm_ps_stat_field "$pid" 20) || return 1
  [ -n "$start" ] || return 1
  args=$(fm_ps_field "$pid" args 2>/dev/null || true)
  printf '%s %s\n' "$start" "$args"
}
