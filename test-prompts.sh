#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Running OpenCode prompt test suite..."
echo ""

# Check server is running
echo "Checking AFM server..."
if ! curl -s http://localhost:8080/v1/models 2>/dev/null | grep -q "afm"; then
    echo "FAILED: AFM server not running on http://localhost:8080"
    echo "Start the server with: ./start-afm-server.sh"
    exit 1
fi
echo "Server OK"
echo ""

TEST_RESULTS=()
FAILED=0

test_prompt() {
    local PROMPT="$1"
    local EXPECTED_CMD="$2"
    local CATEGORY="$3"

    echo "Testing [$CATEGORY]: $PROMPT"

    OUTPUT=$(timeout 30 opencode run --model localcode-afm/afm "$PROMPT" 2>&1 || true)

    if echo "$OUTPUT" | grep -q "permission requested"; then
        if [ -n "$EXPECTED_CMD" ]; then
            if echo "$OUTPUT" | grep -q "$EXPECTED_CMD"; then
                echo "  ✓ Shows approval UI with correct command"
                TEST_RESULTS+=("PASS: [$CATEGORY] $PROMPT")
            else
                echo "  ✗ Shows UI but wrong command"
                echo "  Expected: $EXPECTED_CMD"
                TEST_RESULTS+=("FAIL: [$CATEGORY] $PROMPT - wrong command")
                ((FAILED++))
            fi
        else
            echo "  ✓ Shows approval UI"
            TEST_RESULTS+=("PASS: [$CATEGORY] $PROMPT")
        fi
    else
        echo "  ✗ No approval UI found"
        TEST_RESULTS+=("FAIL: [$CATEGORY] $PROMPT - no approval UI")
        ((FAILED++))
    fi
    echo ""
}

echo "=== File Operations ==="
test_prompt "list all files in current directory" "find" "file_list"
test_prompt "list python files" "find" "file_filter"
test_prompt "show me the largest files" "find" "file_size"

echo "=== Search Commands ==="
test_prompt "grep for hello in this directory" "grep" "search_grep"
test_prompt "find files named test" "find" "search_find"

echo "=== System Commands ==="
test_prompt "show git status" "git" "system_git"
test_prompt "check if port 8080 is in use" "lsof" "system_port"

echo "=== Count/Stats ==="
test_prompt "count all files in this directory" "find" "count_files"
test_prompt "show line counts for code files" "wc" "count_lines"

echo "=== Simple Commands ==="
test_prompt "echo hello world" "echo" "simple_echo"

echo ""
echo "========================================"
echo "Test Results Summary"
echo "========================================"

for result in "${TEST_RESULTS[@]}"; do
    echo "$result"
done

echo ""
echo "Total: $((${#TEST_RESULTS[@]} - FAILED))/${#TEST_RESULTS[@]} passed"

if [ $FAILED -gt 0 ]; then
    echo ""
    echo "FAILED: $FAILED test(s)"
    exit 1
fi

echo ""
echo "All tests passed!"