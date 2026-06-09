# LocalCode

Proof-of-concept CLI tools that demonstrate Apple's Foundation Models framework for local, privacy-first AI.

## Project Status

**This is a POC** - not production software. It's meant to prove AFM is viable for CLI tools and inspire further development.

## Project Overview

- **Mission**: Make Apple's on-device AI accessible via open source CLI/TUI tools
- **Current focus**: Proof-of-concept TUI chat interface using AFM
- **Stack**: Go TUI (Bubble Tea) + Swift AFM helper

## Architecture

```
LocalCode/
├── main.go           # Go TUI (Bubble Tea)
└── Sources/
    └── afmhelper/    # Swift → Apple FoundationModels
        └── main.swift
```

- **TUI Layer**: Go + Bubble Tea
- **AI Layer**: Apple FoundationModels framework (Swift)
- **CLI Exec**: Native command execution for `!` prefixed commands

## Building

```bash
# Build Swift AFM helper
cd Sources/afmhelper
swiftc -o afmhelper main.swift -framework FoundationModels -target arm64-apple-macosx26.0

# Build Go TUI
cd ../..
go build -o localcode .
```

## Requirements

- Apple Silicon Mac (M1/M2/M3/M4)
- macOS 26+
- Xcode 26+

## Apple Foundation Models Framework

- On-device, privacy-first AI (no data leaves device)
- Access via `SystemLanguageModel.default`
- Sessions (`LanguageModelSession`) maintain conversation history
- Structured output via `@Generable` macro
- Tool calling via the `Tool` protocol

## Code Style

- Go for TUI, Swift for AFM integration
- Async/await for all model interactions
- Structured output using `@Generable` and `@Guide` macros