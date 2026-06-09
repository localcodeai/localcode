# LocalCode

Open source CLI tools that unlock Apple's Foundation Models for local, privacy-first AI assistance.

## What is this?

LocalCode provides terminal-based AI assistance powered by Apple's on-device Foundation Models. It runs entirely on your Mac—no data leaves your machine.

## Features

- **Chat Interface**: Ask questions, get help with code, discuss architecture
- **CLI Execution**: Run shell commands with `!` prefix (e.g., `!ls -la`, `!git status`)
- **Privacy First**: All AI processing happens locally on Apple Silicon

## Requirements

- Apple Silicon Mac (M1/M2/M3/M4)
- macOS 26+
- Xcode 26+ (for building from source)

## Quick Start

```bash
# Clone the repo
git clone https://github.com/localcodeai/localcode.git
cd localcode/LocalCode

# Build
swift build -p Sources/afmhelper

# Run the Go TUI
go build -o localcode .
./localcode
```

Or run the AFM helper directly:

```bash
./Sources/afmhelper/afmhelper "Your question here"
```

## Project Structure

```
LocalCode/
├── main.go           # Go TUI (Bubble Tea)
└── Sources/
    └── afmhelper/    # Swift AFM integration
        └── main.swift
```

## Architecture

- **TUI Layer**: Go + Bubble Tea for the terminal interface
- **AI Layer**: Apple FoundationModels framework via Swift helper
- **CLI Exec**: Native command execution for `!` prefixed commands

## Development

```bash
# Build the Swift AFM helper
cd Sources/afmhelper
swiftc -o afmhelper main.swift -framework FoundationModels -target arm64-apple-macosx26.0

# Build the Go TUI
go build -o localcode .
```

## Contributing

Contributions welcome! Please:

1. Fork the repo
2. Create a feature branch
3. Make your changes
4. Submit a PR

## License

MIT