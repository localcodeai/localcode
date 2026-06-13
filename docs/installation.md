# Installation

## Requirements

- Apple Silicon Mac (M1/M2/M3/M4)
- macOS 26+
- Xcode 26+
- Bun 1.3+
- Node 18+

## Makefile (Recommended)

```bash
git clone https://github.com/localcodeai/localcode.git
cd localcode
make install
```

This:
- Builds the Swift AFM helper
- Configures OpenCode provider

## Manual Setup

### 1. Clone the repo

```bash
git clone https://github.com/localcodeai/localcode.git
cd localcode
```

### 2. Build Swift helper

```bash
cd LocalCode/Sources/afmhelper
swiftc -o afmhelper main.swift -framework FoundationModels -target arm64-apple-macosx26.0
cd ../..
```

### 3. Configure OpenCode

Add to `~/.config/opencode/opencode.json`:

```json
{
  "provider": {
    "localcode-afm": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "LocalCode AFM",
      "options": {
        "baseURL": "http://localhost:8080/v1",
        "stream": false
      },
      "models": {
        "afm": { "name": "Apple Foundation Models" }
      }
    }
  }
}
```

### 4. Start the server

```bash
./start-afm-server.sh &
```

### 5. Run OpenCode

```bash
opencode
```

Select "LocalCode AFM" provider via `/models` command.

## Using Make

```bash
make install   # Build Swift helper
make start     # Start server
make stop      # Stop server
make clean     # Remove built artifacts
```