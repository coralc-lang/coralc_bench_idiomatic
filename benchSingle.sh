#!/bin/bash

SRC="$1"
RUNS="${2:-500}"
OPT="${3:-O3}"

if [ -z "$SRC" ] || [ ! -f "$SRC" ]; then
    echo "Usage: $0 <file.crl> [runs] [opt-level|none]"
    echo "Example: $0 alg1.crl 500 O3"
    exit 1
fi

NAME=$(basename "$SRC" .crl)
BIN_ROOT="build/coral"
BIN="${BIN_ROOT}/${NAME}_profile"
PERF_DATA="/tmp/opencode/coral_perf_${NAME}_$$.data"
PERCENT="${PERCENT:-0.5}"

mkdir -p "$BIN_ROOT"

echo "Compiling ${SRC} (opt: ${OPT})..."
if [ "$OPT" = "none" ]; then
    coralc "$SRC" -o "$BIN" || exit 1
else
    coralc --opt "$OPT" "$SRC" -o "$BIN" || exit 1
fi

ABS_BIN=$(readlink -f "$BIN")
DSO=$(basename "$ABS_BIN")

for ((w=1; w<=5; w++)); do
    "$ABS_BIN" > /dev/null 2>&1
done

echo "Profiling ${RUNS} runs of ${DSO}..."
perf record -q -e cycles:u -o "$PERF_DATA" -- bash -c "for ((i=0; i<${RUNS}; i++)); do \"${ABS_BIN}\" >/dev/null 2>&1; done" || {
    echo "perf record failed."
    rm -f "$PERF_DATA"
    exit 1
}

report() {
    perf report --stdio -i "$PERF_DATA" "$@" 2>/dev/null | sed -n '/^# Overhead/,$p'
}

echo ""
echo "=================================================="
echo " Function profile: ${NAME} (opt ${OPT}, ${RUNS} runs)"
echo "=================================================="
echo ""
echo "--- Coral binary only (${DSO}) ---"
report --dsos="$DSO" --sort overhead,symbol --percent-limit "$PERCENT" --no-children
echo ""
echo "--- Overall, including libc / dynamic loader ---"
report --sort overhead,dso,symbol --percent-limit "$PERCENT" --no-children
echo ""

rm -f "$PERF_DATA"
