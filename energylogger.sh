#!/usr/bin/env sh
set -eu
SIGMARK_PATH="${SIGMARK_PATH:-/usr/local/bin/sigmark.sh}"
REMOTE_ADDRESS="${REMOTE_ADDRESS:-127.0.0.1:8000}"
MARKER_CHANNEL="${MARKER_CHANNEL:-CH1}"
OUT_DIR="${OUT_DIR:-/data}"
LOADS="${LOADS:-0 5 10 15 20 30 40 50 60 70 80 90 100}"
REPEATS="${REPEATS:-35}"
SAMPLE_PERIODS="${SAMPLE_PERIODS:-2 1 0.5 0.2 0.1 0.05 0.04 0.03}"
WORK_DURATION="${WORK_DURATION:-80s}"
COOLDOWN="${COOLDOWN:-20}"
PRE_IDLE="${PRE_IDLE:-0}"
mkdir -p "$OUT_DIR"
send_marker_raw(){ sh "$SIGMARK_PATH" "$REMOTE_ADDRESS" "$MARKER_CHANNEL" "$1" || { echo "WARN: failed marker: $1" >&2; return 0; }; }
send_start(){ send_marker_raw "start,sigmark,$1"; }
send_stop(){ send_marker_raw "stop,sigmark,$1"; }
run_workload(){ load="$1"; if command -v stress-ng >/dev/null 2>&1; then stress-ng --cpu 1 -l "$load" -t "$WORK_DURATION"; else echo "stress-ng missing, sleeping"; sleep "${WORK_DURATION%s}"; fi; }
for load in $LOADS; do
  j=1
  while [ "$j" -le "$REPEATS" ]; do
    SAMPLEPERIOD=0
    send_start "$j,$load,$SAMPLEPERIOD"
    run_workload "$load"
    send_stop "$j,$load,$SAMPLEPERIOD"
    echo "Done baseline repeat=$j load=$load"
    sleep "$COOLDOWN"
    for SAMPLEPERIOD in $SAMPLE_PERIODS; do
      TS=$(date +"%Y%m%d_%H%M%S")
      OUTFILE="$OUT_DIR/pmic_log_${j}_${load}_${SAMPLEPERIOD}s_${TS}.csv"
      send_start "$j,$load,$SAMPLEPERIOD"
      run_with_logging "$SAMPLEPERIOD" "$PRE_IDLE" 2 "$OUTFILE" sh -c "if command -v stress-ng >/dev/null 2>&1; then stress-ng --cpu 1 -l '$load' -t '$WORK_DURATION'; else sleep '${WORK_DURATION%s}'; fi"
      send_stop "$j,$load,$SAMPLEPERIOD"
      echo "Done. EnergyLogger Data in $OUTFILE"
      sleep "$COOLDOWN"
    done
    j=$((j+1))
  done
done
