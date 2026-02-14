#!/usr/bin/env bats
###############################################################################
# performance.bats - Zsh Startup Performance Test
###############################################################################
# Purpose: Enforce hard 100ms startup threshold
###############################################################################

load test_helper

# Fallback timing function (used when zsh-bench unavailable)
_measure_startup_fallback() {
    # Average 5 runs of zsh -ic exit
    local total=0
    local runs=5
    for i in $(seq 1 $runs); do
        local start end elapsed
        start=$(date +%s%N)
        zsh -ic 'exit' 2>/dev/null
        end=$(date +%s%N)
        elapsed=$(( (end - start) / 1000000 ))
        total=$((total + elapsed))
    done
    local avg=$((total / runs))
    echo "Fallback timing: avg ${avg}ms over $runs runs"
    [ "$avg" -lt 100 ]
}

@test "zsh startup time is under 100ms" {
    # Try zsh-bench first (most accurate)
    if [ ! -d "$HOME/zsh-bench" ]; then
        git clone --depth=1 https://github.com/romkatv/zsh-bench "$HOME/zsh-bench" 2>/dev/null || true
    fi

    if [ -x "$HOME/zsh-bench/zsh-bench" ]; then
        output=$("$HOME/zsh-bench/zsh-bench" 2>&1) || {
            # zsh-bench failed (no TTY?), fall back
            _measure_startup_fallback
            return
        }
        time_ms=$(echo "$output" | grep first_prompt_lag_ms | awk '{print $2}')
        time_int=${time_ms%.*}
        echo "zsh-bench: first_prompt_lag_ms = ${time_ms}ms"
        [ "$time_int" -lt 100 ]
    else
        _measure_startup_fallback
    fi
}
