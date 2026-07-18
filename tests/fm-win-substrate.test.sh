#!/usr/bin/env bash
# tests/fm-win-substrate.test.sh - Windows (Git Bash/MSYS) substrate proofs for
# the ported primitives: the mkdir directory lock keeps the wake queue alive
# under contention (the symlink lock froze it forever), a stale directory lock
# is stolen cleanly, and the `sleep N & wait $!` pattern reacts to TERM fast.
# Windows-only: the POSIX symlink-lock behavior is covered by the upstream
# suite; this file skips (ok) on other platforms.
set -u

# shellcheck source=tests/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

case "$(uname -s)" in
  MSYS*|MINGW*) ;;
  *)
    pass "skip: Windows-only substrate test"
    exit 0
    ;;
esac

TMP_ROOT=$(fm_test_tmproot fm-win-substrate)

test_wake_queue_contention() {
  local state=$TMP_ROOT/contention/state queue lines malformed r
  mkdir -p "$state"
  queue="$state/.wake-queue"
  for r in A B C; do
    FM_STATE_OVERRIDE=$state bash -c '
      . "'"$ROOT"'/bin/fm-wake-lib.sh"
      for i in $(seq 1 10); do
        fm_wake_append signal "racer-'"$r"'-$i" "payload '"$r"' $i" >/dev/null 2>&1
      done
    ' &
  done
  # A hung racer is exactly the pre-port failure mode: bound the whole wait
  # ourselves (a subshell `wait` would not see this shell's children).
  local deadline=$((SECONDS + 120))
  while [ -n "$(jobs -pr)" ]; do
    [ "$SECONDS" -lt "$deadline" ] || {
      kill $(jobs -pr) 2>/dev/null
      fail "wake queue contention: racer still running after 120s (hang)"
    }
    sleep 1
  done
  wait 2>/dev/null || true
  lines=$(wc -l < "$queue" 2>/dev/null || echo 0)
  [ "$lines" -eq 30 ] || fail "wake queue contention: $lines/30 lines (hang or loss)"
  malformed=$(awk -F'\t' 'NF!=5 || $3!="signal"' "$queue" | wc -l)
  [ "$malformed" -eq 0 ] || fail "wake queue contention: $malformed malformed lines"
  if [ -e "$state/.wake-queue.lock" ] || [ -L "$state/.wake-queue.lock" ]; then
    fail "wake queue contention: leftover lock"
  fi
  pass "wake queue survives 3-way contention (30/30 lines, lock released)"
}

test_stale_dir_lock_steal() {
  local lock=$TMP_ROOT/stale.lock out
  out=$(
    FM_STATE_OVERRIDE=$TMP_ROOT bash -c '
      . "'"$ROOT"'/bin/fm-wake-lib.sh"
      lock="'"$lock"'"
      mkdir "$lock" && printf "999999\n" > "$lock/pid"
      touch -d "@$(( $(date +%s) - 3600 ))" "$lock" 2>/dev/null || true
      if fm_lock_try_acquire "$lock"; then
        got=$(cat "$lock/pid" 2>/dev/null)
        [ "$got" = "${BASHPID:-$$}" ] || { echo "wrong-pid:$got"; exit 1; }
        fm_lock_release "$lock"
        [ ! -e "$lock" ] || { echo "release-left-lock"; exit 1; }
        echo stolen
      else
        echo "held:$FM_LOCK_HELD_PID"
        exit 1
      fi
    '
  ) || fail "stale dir lock not stolen ($out)"
  [ "$out" = stolen ] || fail "stale dir lock: unexpected output ($out)"
  pass "stale directory lock stolen and released cleanly"
}

test_interruptible_sleep_reacts_fast() {
  local script=$TMP_ROOT/sleeper.sh start elapsed pid
  cat > "$script" <<'EOF'
trap 'exit 0' TERM
sleep 30 & wait $! || true
exit 1
EOF
  bash "$script" &
  pid=$!
  sleep 1
  start=$(date +%s%N 2>/dev/null || date +%s)
  kill -TERM "$pid" 2>/dev/null
  wait "$pid" 2>/dev/null
  rc=$?
  elapsed=$(( ($(date +%s%N 2>/dev/null || date +%s) - start) / 1000000 ))
  [ "$rc" -eq 0 ] || fail "interruptible sleep: trap did not run (rc=$rc)"
  [ "$elapsed" -lt 2000 ] || fail "interruptible sleep: ${elapsed}ms > 2000ms"
  pass "sleep-and-wait reacts to TERM in ${elapsed}ms"
}

test_wake_queue_contention
test_stale_dir_lock_steal
test_interruptible_sleep_reacts_fast
