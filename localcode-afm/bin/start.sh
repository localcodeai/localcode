#!/bin/bash
set -e

SCRIPT_REAL="$(realpath "$0")"
PACKAGE_DIR="$(dirname "$(dirname "$SCRIPT_REAL")")"
AFMHELPER="$PACKAGE_DIR/src/afmhelper"
SERVER_PORT=8080

if [ ! -f "$AFMHELPER" ]; then
    echo "Building AFM helper..."
    cd "$PACKAGE_DIR/src"
    swiftc -o afmhelper main.swift -framework FoundationModels -target arm64-apple-macosx26.0 2>/dev/null || {
        echo "Error: Swift build failed. Make sure Xcode 26+ is installed."
        exit 1
    }
fi

echo "Starting LocalCode AFM Server on http://localhost:$SERVER_PORT"
echo "Press Ctrl+C to stop"

cd "$PACKAGE_DIR"
exec bun start-afm-server.sh