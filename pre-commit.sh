#!/bin/bash
# Pre-commit hook for LocalCode
# Run this once to enable: cp pre-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

set -e

echo "Running pre-commit checks..."

# Find Go binary
GO_PATH="$HOME/go/bin/go"
if [ ! -f "$GO_PATH" ]; then
    GO_PATH="$(which go 2>/dev/null)"
fi

if [ -z "$GO_PATH" ]; then
    echo "WARNING: Go not found, skipping Go build"
else
    # Build Go TUI
    echo "Building Go TUI..."
    cd LocalCode
    if ! "$GO_PATH" build -o localcode . 2>&1; then
        echo "FAILED: Go build failed"
        exit 1
    fi
    echo "Go build: OK"
    cd ..
fi

# Build Swift AFM helper
echo "Building Swift AFM helper..."
cd LocalCode/Sources/afmhelper
if ! swiftc -o afmhelper main.swift -framework FoundationModels -target arm64-apple-macosx26.0 2>&1; then
    echo "FAILED: Swift build failed"
    exit 1
fi
echo "Swift build: OK"

echo ""
echo "All checks passed!"