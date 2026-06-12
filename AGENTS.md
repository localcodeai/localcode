# LocalCode

Proof-of-concept CLI tools that demonstrate Apple's Foundation Models framework for local, privacy-first AI.

## Project Status

**This is a POC** - not production software. It's meant to prove AFM is viable for CLI tools and inspire further development.

## Project Overview

- **Mission**: Make Apple's on-device AI accessible via open source CLI/TUI tools
- **Current focus**: Integrate AFM with OpenCode as local AI provider
- **Stack**: OpenCode with `@ai-sdk/openai-compatible` + Swift AFM helper

## Architecture

```
LocalCode/
├── LocalCode/Sources/afmhelper/   # Swift AFM helper
│   └── main.swift                # Apple FoundationModels integration
├── start-afm-server.sh            # HTTP middleware (Bun)
└── pre-commit.sh                  # Pre-commit hook
```

- **AFM Server**: Bun HTTP server wrapping Swift AFM helper with OpenAI-compatible API
- **AI Layer**: Apple FoundationModels framework (Swift)
- **TUI Layer**: OpenCode with `@ai-sdk/openai-compatible` provider
- **Command Flow**: You type → AFM suggests (tool call) → OpenCode approval UI → Command executes

## OpenCode Integration

No fork needed - use OpenCode's provider config with `@ai-sdk/openai-compatible`:

1. Add AFM provider to `~/.config/opencode/opencode.json`
2. AFM server wraps Swift helper with OpenAI-compatible API
3. OpenCode sees AFM as a standard provider

OpenCode repo: https://github.com/anomalyco/opencode

## Building

```bash
# Build Swift AFM helper
cd LocalCode/Sources/afmhelper
swiftc -o afmhelper main.swift -framework FoundationModels -target arm64-apple-macosx26.0
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

## Known Issues

- **OpenTUI InputRenderable.ENTER event**: The `input.on(InputRenderableEvents.ENTER, ...)` callback may not fire reliably in some terminal configurations. Consider using global `renderer.keyInput.on("keypress", ...)` as a workaround.

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

## Public Project Reminders

**This is a public open source project.** Before every commit:

1. **Update README.md** if you added new features, changed architecture, or modified the workflow
2. **Check examples still work** - commands in README should be tested
3. **Verify docs match code** - if you changed how something works, update the docs
4. **Update Makefile** if you added new commands or scripts
5. **Run `make test`** to ensure prompt tests pass

README is often the first thing new users see. Outdated docs = bad first impression.

## Agent Commands

Use Makefile for common operations:
```bash
make help          # Show available commands
make install        # Build Swift helper
make start          # Start AFM server
make test           # Run prompt test suite
make server-test    # Run server curl tests
make pre-commit     # Run all checks
make clean          # Remove built artifacts
```