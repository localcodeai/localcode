# LocalCode

Turn natural language into CLI commands using Apple's on-device AI.

## What is this?

LocalCode is a proof-of-concept that demonstrates building CLI tools with Apple's Foundation Models framework. Tell it what you want in plain English, it suggests the right command, you approve, and it runs.

**All AI processing happens locally on your Mac.** No cloud, no data leaving your machine.

## Requirements

- Apple Silicon Mac (M1/M2/M3/M4)
- macOS 26+
- Xcode 26+ (for building the Swift helper)
- Go (for building the TUI)

## Quick Start

```bash
git clone https://github.com/localcodeai/localcode.git
cd localcode/LocalCode

# Build the Swift AFM helper
cd Sources/afmhelper
swiftc -o afmhelper main.swift -framework FoundationModels -target arm64-apple-macosx26.0

# Build the Go TUI
cd ../..
go build -o localcode .

# Run
./localcode
```

## How It Works

```
You: "list all python files"
LocalCode: find . -name "*.py"
▶ Execute this command? [Enter] Run | [N] Cancel
```

The model translates your request into a command. You approve before it runs.

## Example Commands to Try

**File Operations:**
- "list all python files"
- "find all files named hello"
- "show me the largest files in this directory"
- "count all files in this directory"

**System & Network:**
- "check if port 8080 is in use"
- "show git status"

**Search:**
- "grep for hello in this directory"

All commands show a confirmation dialog before running. You can edit the command before executing, or cancel.

## Project Structure

```
LocalCode/
├── main.go              # Go TUI (Bubble Tea)
├── pre-commit.sh        # Pre-commit hook
└── Sources/
    └── afmhelper/       # Swift → Apple FoundationModels
        └── main.swift
```

- **TUI Layer**: Go + Bubble Tea
- **AI Layer**: Apple FoundationModels framework (Swift)
- **Command Flow**: Model suggests → You approve → Command executes

## Development

A pre-commit hook ensures the project builds:

```bash
cp pre-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
git config core.hooksPath .git/hooks
```

## Why does this exist?

Apple's Foundation Models framework is new and under-documented. This project proves it's viable for CLI tools and provides a reference implementation for others building on AFM.

## Contributing

POCs have rough edges. Contributions welcome:

1. Fork and create a feature branch
2. Make your changes
3. Open a PR

## License

MIT