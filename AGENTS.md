# LocalCode

Proof-of-concept CLI tools that demonstrate Apple's Foundation Models framework for local, privacy-first AI.

## Project Status

**This is a POC** - not production software. It's meant to prove AFM is viable for CLI tools and inspire further development.

## Project Overview

- **Mission**: Make Apple's on-device AI accessible via open source CLI/TUI tools
- **Current focus**: Fork OpenCode for TUI + integrate AFM for local AI
- **Stack**: TypeScript/OpenTUI (forked from OpenCode) + Swift AFM helper

## Architecture

```
LocalCode/
├── tui/                   # TypeScript TUI (OpenTUI) - CONSIDER FORKING OPENCODE
├── LocalCode/             # Go implementation (legacy)
│   ├── main.go
│   └── Sources/
│       └── afmhelper/     # Swift → Apple FoundationModels
│           └── main.swift
└── pre-commit.sh
```

- **TUI Layer**: Fork OpenCode for working TUI + OpenTUI
- **AI Layer**: Apple FoundationModels framework (Swift)
- **Command Flow**: You type → Model suggests → Command executes

## OpenCode Fork Strategy

Instead of building TUI from scratch, fork OpenCode and:
1. Replace cloud AI provider with AFM helper
2. Keep the working OpenTUI frontend
3. Add command execution for CLI tools

OpenCode repo: https://github.com/anomalyco/opentui (11.8k stars)

## Building

```bash
# Build Swift AFM helper
cd LocalCode/Sources/afmhelper
swiftc -o afmhelper main.swift -framework FoundationModels -target arm64-apple-macosx26.0

# Run TUI (if using OpenCode fork)
cd tui && bun run src/index.ts
```

## Pre-commit Hook

The project includes a pre-commit hook that builds the Swift helper and TypeScript TUI.

To enable:
```bash
cp pre-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
git config core.hooksPath .git/hooks
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

- TypeScript for TUI, Swift for AFM integration
- Async/await for all model interactions
- If forking OpenCode, follow their patterns for OpenTUI usage

## Known Issues

- **OpenTUI InputRenderable.ENTER event**: The `input.on(InputRenderableEvents.ENTER, ...)` callback may not fire reliably in some terminal configurations. Consider using global `renderer.keyInput.on("keypress", ...)` as a workaround, or fork OpenCode which has already solved this.

## Session Notes

When wrapping up a session (end of day, user leaving, or session is pausing), write a session note:

```bash
sessions/YYYY-MM-DD_HHMM.md
```

Content should include:
- What's working / recent progress
- Test commands that work
- Known limitations or bugs
- Next steps or things to improve

Commit session notes so they can be reviewed later.