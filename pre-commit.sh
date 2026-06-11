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
cd ../../..

echo ""
echo "All checks passed!"
echo ""
echo "To run LocalCode with AFM:"
echo "1. Start AFM server: ./start-afm-server.sh"
echo "2. Run OpenCode: cd opencode && bun run dev"
echo "3. Select 'LocalCode AFM' provider in OpenCode settings"