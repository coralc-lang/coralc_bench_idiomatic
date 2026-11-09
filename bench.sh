#!/bin/bash

LOOPS=100

# 1. Gather all unique test base names
echo "Scanning for test suites..."
TESTS=$(find . -maxdepth 1 -name "*.crl" | sed 's|.*/||;s|\.crl$||' | sort)

# Ensure we have matching files before proceeding
VALID_TESTS=""
for TEST in $TESTS; do
    if [ -f "${TEST}.rs" ] && [ -f "${TEST}.crl" ]; then
        VALID_TESTS="$VALID_TESTS $TEST"
    fi
done

if [ -z "$VALID_TESTS" ]; then
    echo "No matching source pairs (.rs and .crl) found."
    exit 1
fi


echo " STEP 1: Compiling All Source Files (No Optimization)"


for TEST in $VALID_TESTS; do
    echo "Building unoptimized binaries for: $TEST"
    # Compiling with NO optimizations explicitly
    rustc "${TEST}.rs" -o "${TEST}rs" 2>/dev/null
    coralc "${TEST}.crl" -o "${TEST}crl" 2>/dev/null
    
    if [ ! -f "${TEST}rs" ] || [ ! -f "${TEST}crl" ]; then
        echo "  [ERROR] Compilation failed for $TEST. Removing partial builds."
        rm -f "${TEST}rs" "${TEST}crl"
        VALID_TESTS=$(echo "$VALID_TESTS" | sed "s/\b$TEST\b//")
    fi
done

echo ""

echo " STEP 2: Cooling Down System for 5 Seconds..."

sleep 5
echo "System ready. Clocking benchmarks now."
echo ""


echo " STEP 3: Running Interleaved Benchmarks (Coral First)"


for TEST in $VALID_TESTS; do
    [ -z "$TEST" ] && continue

    echo "Executing Test Suite: $TEST"
    echo "--------------------------------------------------"

    EXEC1="./${TEST}rs"
    EXEC2="./${TEST}crl"

    # Warm-up to prime CPU caches
    for ((w=1; w<=5; w++)); do
        $EXEC2 > /dev/null 2>&1
        $EXEC1 > /dev/null 2>&1
    done

    TOTAL1=0
    TOTAL2=0

    # Interleaved run configuration - Coral fires first every iteration
    for ((i=1; i<=LOOPS; i++)); do
        # Run Coral First
        START2=$(date +%s%N)
        $EXEC2 > /dev/null 2>&1
        END2=$(date +%s%N)
        TOTAL2=$((TOTAL2 + (END2 - START2)))

        # Run Rust Second
        START1=$(date +%s%N)
        $EXEC1 > /dev/null 2>&1
        END1=$(date +%s%N)
        TOTAL1=$((TOTAL1 + (END1 - START1)))
    done

    AVG1=$(awk "BEGIN {print ($TOTAL1 / $LOOPS) / 1000000000}")
    AVG2=$(awk "BEGIN {print ($TOTAL2 / $LOOPS) / 1000000000}")

    echo "Averages over $LOOPS runs (Unoptimized):"
    echo "  Rust  ($EXEC1): $AVG1 seconds"
    echo "  Coral ($EXEC2): $AVG2 seconds"

    if (( $(awk 'BEGIN {print ("'$AVG1'" < "'$AVG2'")}') )); then
        PCT=$(awk "BEGIN {print (($AVG2 - $AVG1) / $AVG2) * 100}")
        printf "  WINNER: Rust (${TEST}rs) is faster by %.2f%%\n" "$PCT"
    else
        PCT=$(awk "BEGIN {print (($AVG1 - $AVG2) / $AVG1) * 100}")
        printf "  WINNER: Coral (${TEST}crl) is faster by %.2f%%\n" "$PCT"
    fi
    
    echo ""
    rm -f "${TEST}rs" "${TEST}crl"
done
