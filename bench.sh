#!/bin/bash

LOOPS=100

# 1. Gather all unique test base names
echo "Scanning for test suites..."
TESTS=$(find . -maxdepth 1 -name "*.crl" | sed 's|.*/||;s|\.crl$||' | sort)

# Ensure we have matching files before proceeding
VALID_TESTS=""
for TEST in $TESTS; do
    if [ -f "${TEST}.rs" ] && [ -f "${TEST}.crl" ] && [ -f "${TEST}.cpp" ]; then
        VALID_TESTS="$VALID_TESTS $TEST"
    fi
done

if [ -z "$VALID_TESTS" ]; then
    echo "No matching source triples (.rs, .crl, .cpp) found."
    exit 1
fi


echo " STEP 1: Compiling All Source Files (No Optimization)"


for TEST in $VALID_TESTS; do
    echo "Building unoptimized binaries for: $TEST"
    # Compiling with NO optimizations explicitly
    rustc "${TEST}.rs" -o "${TEST}rs" 2>/dev/null
    coralc "${TEST}.crl" -o "${TEST}crl" 2>/dev/null
    g++ "${TEST}.cpp" -o "${TEST}cpp" 2>/dev/null

    if [ ! -f "${TEST}rs" ] || [ ! -f "${TEST}crl" ] || [ ! -f "${TEST}cpp" ]; then
        echo "  [ERROR] Compilation failed for $TEST. Removing partial builds."
        rm -f "${TEST}rs" "${TEST}crl" "${TEST}cpp"
        VALID_TESTS=$(echo "$VALID_TESTS" | sed "s/\b$TEST\b//")
    fi
done

echo ""

echo " STEP 2: Cooling Down System for 5 Seconds..."

sleep 5
echo "System ready. Clocking benchmarks now."
echo ""


echo " STEP 3: Running Interleaved Benchmarks (Order Rotates Every Run)"


run_timed() {
    local start end
    start=$(date +%s%N)
    "$1" > /dev/null 2>&1
    end=$(date +%s%N)
    TIME_NS=$((end - start))
}

print_ranking() {
    sort -k2,2g | awk '
        {
            if (NR == 1) base = $2
            rank = (NR == 1) ? "1st" : ((NR == 2) ? "2nd" : "3rd")
            if (NR == 1) {
                printf "  %s place: %-5s %12.9f seconds\n", rank, $1, $2
            } else {
                diff = (($2 - base) / base) * 100
                printf "  %s place: %-5s %12.9f seconds (+%.2f%%)\n", rank, $1, $2, diff
            }
        }'
}

LANGS=(coral rust cpp)
declare -A LABEL=([coral]="Coral" [rust]="Rust" [cpp]="C++")
declare -A FINAL_SUM=([coral]=0 [rust]=0 [cpp]=0)
NUM_TESTS=0

for TEST in $VALID_TESTS; do
    [ -z "$TEST" ] && continue

    echo "Executing Test Suite: $TEST"
    echo "--------------------------------------------------"

    declare -A EXEC=(
        [coral]="./${TEST}crl"
        [rust]="./${TEST}rs"
        [cpp]="./${TEST}cpp"
    )
    declare -A TOTAL=([coral]=0 [rust]=0 [cpp]=0)
    declare -A AVG=([coral]=0 [rust]=0 [cpp]=0)

    # Warm-up to prime CPU caches
    for ((w=1; w<=5; w++)); do
        for L in "${LANGS[@]}"; do
            "${EXEC[$L]}" > /dev/null 2>&1
        done
    done

    # Interleaved run configuration - starting language rotates every iteration
    for ((i=0; i<LOOPS; i++)); do
        for ((k=0; k<3; k++)); do
            L=${LANGS[$(((i + k) % 3))]}
            run_timed "${EXEC[$L]}"
            TOTAL[$L]=$((TOTAL[$L] + TIME_NS))
        done
    done

    echo "Averages over $LOOPS runs (Unoptimized):"
    for L in "${LANGS[@]}"; do
        AVG[$L]=$(awk "BEGIN {printf \"%.9f\", (${TOTAL[$L]} / $LOOPS) / 1000000000}")
    done
    {
        for L in "${LANGS[@]}"; do
            printf "%s %s\n" "${LABEL[$L]}" "${AVG[$L]}"
        done
    } | print_ranking

    NUM_TESTS=$((NUM_TESTS + 1))
    for L in "${LANGS[@]}"; do
        FINAL_SUM[$L]=$(awk "BEGIN {printf \"%.9f\", ${FINAL_SUM[$L]} + ${AVG[$L]}}")
    done

    echo ""
    rm -f "${TEST}rs" "${TEST}crl" "${TEST}cpp"
done

echo "=================================================="
echo " FINAL AVERAGE ACROSS ALL SUITES (Unoptimized)"
echo "=================================================="
declare -A FINAL_AVG=([coral]=0 [rust]=0 [cpp]=0)
for L in "${LANGS[@]}"; do
    FINAL_AVG[$L]=$(awk "BEGIN {printf \"%.9f\", ${FINAL_SUM[$L]} / $NUM_TESTS}")
done
{
    for L in "${LANGS[@]}"; do
        printf "%s %s\n" "${LABEL[$L]}" "${FINAL_AVG[$L]}"
    done
} | print_ranking
echo ""
