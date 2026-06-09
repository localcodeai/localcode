# LocalCode

Proof-of-concept CLI tool showcasing Apple's Foundation Models framework for local, privacy-first AI assistance.

## What is this?

A working demo that proves you can build CLI tools powered by Apple's on-device Foundation Models. The AI runs entirely on your Mac—no cloud, no data leaving your machine.

**This is a POC, not a production tool.** It's meant to demonstrate what's possible with AFM and inspire further development.

## Features

- **Chat Interface**: Ask questions, get help with code
- **Command Suggestions**: Model suggests shell commands, you approve before running
- **Privacy First**: All AI processing happens locally on Apple Silicon

## Requirements

- Apple Silicon Mac (M1/M2/M3/M4)
- macOS 26+
- Xcode 26+ (for building from source)
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

## Project Structure

```
LocalCode/
├── main.go              # Go TUI (Bubble Tea)
├── pre-commit.sh        # Pre-commit hook (optional)
└── Sources/
    └── afmhelper/       # Swift → Apple FoundationModels
        └── main.swift
```

- **TUI Layer**: Go + Bubble Tea
- **AI Layer**: Apple FoundationModels framework (Swift)
- **Command Flow**: Model suggests → You approve → Command executes

## Development

A pre-commit hook is included to ensure the project builds:

```bash
cp pre-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
git config core.hooksPath .git/hooks
```

## Why does this exist?

Apple's Foundation Models framework is new and under-documented. This project proves it's viable for CLI tools and provides a reference implementation for others building on AFM.

The framework is powerful—on-device inference, privacy-first, no API costs—but the tooling ecosystem is still nascent. LocalCode aims to change that.

## Contributing

POCs have lots of rough edges—and that's okay. Contributions welcome:

1. Fork and create a feature branch
2. Make your changes
3. Open a PR

## License

MIT