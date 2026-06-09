# LocalCode

Open source tools that unlock and use Apple's foundation models.

## Project Overview

- **Mission**: Make Apple's on-device AI models accessible via open source CLI/TUI tools
- **Current focus**: CLI chat interface using Apple's Foundation Models framework
- **Open source**: Transparency and documentation are core values

## Architecture

- **Language**: Swift
- **Target**: macOS 26+ with Apple Silicon (Foundation Models requires M-series chips)
- **Framework**: Apple's `FoundationModels` framework (part of Apple Intelligence)

## Development Commands

```bash
# Build the project
swift build

# Run in debug mode
swift run

# Run tests
swift test

# Generate Xcode project
swift package generate-xcodeproj
```

## Apple Foundation Models Framework Notes

- Available in iOS 26, iPadOS 26, macOS 26 (all in beta)
- Requires Apple Silicon (M1+)
- On-device, privacy-first AI (no data leaves the device)
- Access via `SystemLanguageModel.default` for general use
- Sessions (`LanguageModelSession`) maintain conversation history
- Supports streaming responses and structured output via `@Generable` macro
- Tools (custom function calling) via the `Tool` protocol

## Testing POC

Since macOS 26 is not yet released, the POC may require:
- Xcode 26 beta
- Running on Apple Silicon hardware
- Enabling Apple Intelligence in system settings

## Code Style

- Swift idioms and conventions
- Structured output using `@Generable` and `@Guide` macros
- Async/await for all model interactions