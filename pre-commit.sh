#!/bin/bash
set -e

echo "Running pre-commit checks..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Build Swift AFM helper
echo "Building Swift AFM helper..."
cd LocalCode/Sources/afmhelper
if ! swiftc -o afmhelper main.swift -framework FoundationModels -target arm64-apple-macosx26.0 2>&1; then
    echo "FAILED: Swift build failed"
    exit 1
fi
echo "Swift build: OK"
cd "$SCRIPT_DIR"

# Kill any existing server
pkill -f "bun.*8080" 2>/dev/null || true
sleep 1

# Start AFM server for testing in background
./start-afm-server.sh &
AFM_PID=$!
sleep 3

# Cleanup function
cleanup() {
    kill $AFM_PID 2>/dev/null || true
    pkill -f "bun.*8080" 2>/dev/null || true
}
trap cleanup EXIT

# Test server health
echo ""
echo "Testing /v1/models endpoint..."
MODELS_RESPONSE=$(curl -s http://localhost:8080/v1/models 2>/dev/null)
if ! echo "$MODELS_RESPONSE" | grep -q "afm"; then
    echo "FAILED: /v1/models endpoint not returning AFM model"
    echo "Response: $MODELS_RESPONSE"
    exit 1
fi
echo "Models endpoint: OK"

# Test non-streaming tool call
echo "Testing non-streaming tool call..."
TOOL_CALL_RESPONSE=$(curl -s -X POST http://localhost:8080/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{"model":"afm","messages":[{"role":"user","content":"test"}],"stream":false}' 2>/dev/null)

if ! echo "$TOOL_CALL_RESPONSE" | grep -q "tool_calls"; then
    echo "FAILED: Non-streaming response missing tool_calls"
    echo "Response: $TOOL_CALL_RESPONSE"
    exit 1
fi

if ! echo "$TOOL_CALL_RESPONSE" | grep -q "description"; then
    echo "FAILED: Tool call missing description field"
    echo "Response: $TOOL_CALL_RESPONSE"
    exit 1
fi
echo "Non-streaming tool call: OK"

# Test streaming tool call
echo "Testing streaming tool call..."
STREAM_RESPONSE=$(curl -s -X POST http://localhost:8080/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{"model":"afm","messages":[{"role":"user","content":"test"}],"stream":true}' 2>/dev/null)

if ! echo "$STREAM_RESPONSE" | grep -q "chat.completion.chunk"; then
    echo "FAILED: Streaming response missing chunk format"
    echo "Response: $STREAM_RESPONSE"
    exit 1
fi
echo "Streaming tool call: OK"

# Test OpenCode integration
echo ""
echo "Testing OpenCode integration..."
OPENCODE_OUTPUT=$(timeout 30 opencode run --model localcode-afm/afm "echo hello" 2>&1 || true)

if ! echo "$OPENCODE_OUTPUT" | grep -q "permission requested"; then
    echo "FAILED: OpenCode not showing approval UI"
    echo "Output: $OPENCODE_OUTPUT"
    exit 1
fi
echo "OpenCode integration: OK"

# Run prompt test suite
echo ""
echo "Running prompt test suite..."
if [ -f "$SCRIPT_DIR/test-prompts.sh" ]; then
    chmod +x "$SCRIPT_DIR/test-prompts.sh"
    if ! "$SCRIPT_DIR/test-prompts.sh" > /tmp/prompt-tests.log 2>&1; then
        echo "FAILED: Prompt test suite failed"
        cat /tmp/prompt-tests.log
        exit 1
    fi
    echo "Prompt test suite: OK"
else
    echo "SKIPPED: test-prompts.sh not found"
fi

echo ""
echo "All checks passed!"
echo ""
echo "To run LocalCode with AFM:"
echo "1. Start AFM server: ./start-afm-server.sh"
echo "2. Run OpenCode: opencode"
echo "3. Select 'LocalCode AFM' provider"