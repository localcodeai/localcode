# LocalCode

Turn natural language into CLI commands using Apple's on-device AI, powered by OpenCode.

<img width="738" height="687" alt="Screenshot 2026-06-12 at 12 45 50" src="https://github.com/user-attachments/assets/e9061028-0c56-4d71-9189-0a31236592f9" />

## What is this?

LocalCode is a proof-of-concept that integrates Apple Foundation Models (AFM) with OpenCode as a local AI provider. Tell it what you want in plain English, it suggests the right command via tool calls, and you approve before execution.

**All AI processing happens locally on your Mac.** No cloud, no data leaving your machine.

## Requirements

- Apple Silicon Mac (M1/M2/M3/M4)
- macOS 26+
- Xcode 26+ (for building the Swift helper)
- Bun 1.3+
- Node 18+ (for OpenCode and npm)

## Architecture

```
LocalCode/
├── LocalCode/Sources/afmhelper/   # Swift AFM helper
│   └── main.swift                # Apple FoundationModels integration
├── start-afm-server.sh           # HTTP middleware (Bun)
├── setup-localcode.sh            # One-command setup script
├── pre-commit.sh                 # Pre-commit hook with tests
├── test-prompts.sh              # Prompt test suite
└── docs/                        # VitePress documentation site
```

**[Latest Release](https://github.com/localcodeai/localcode/releases/latest): v0.0.1-alpha**

**No fork needed** - uses global OpenCode with provider config in `~/.config/opencode/opencode.json`

**Flow:**
1. AFM Server wraps Swift helper with OpenAI-compatible API
2. OpenCode uses AFM as a provider via `@ai-sdk/openai-compatible`
3. AFM returns command suggestions as tool calls
4. OpenCode shows command approval UI → user approves → command executes

## Quick Start

### Option 1: Makefile (Recommended)
```bash
git clone https://github.com/localcodeai/localcode.git
cd localcode

make install   # Build Swift helper
make start      # Start AFM server

opencode        # Select "LocalCode AFM" provider via /models
```

### Option 2: Setup Script
```bash
git clone https://github.com/localcodeai/localcode.git
cd localcode
./setup-localcode.sh
./start-afm-server.sh &
opencode
```

### Option 3: Manual
```bash
git clone https://github.com/localcodeai/localcode.git
cd localcode

# Build Swift helper
cd LocalCode/Sources/afmhelper
swiftc -o afmhelper main.swift -framework FoundationModels -target arm64-apple-macosx26.0
cd ../..

# Start server and configure OpenCode (see manual config below)
./start-afm-server.sh &
opencode
```

## How It Works

```
You: "list all python files in this directory"
OpenCode (AFM): [Tool Call: bash { command: "find . -name '*.py'" }]
                 ↑ Approval UI appears with approve/reject buttons
User: clicks approve
OpenCode: executes find . -name '*.py'
Output: ./file1.py
        ./subdir/file2.py
```

AFM acts as a command translator - it takes natural language and produces shell commands as tool calls that OpenCode can display with approval UI.

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

## Testing

### Makefile Commands
```bash
make test         # Run prompt test suite (10 cases)
make server-test  # Run server curl tests
make pre-commit   # Run all checks
```

### Manual Testing
```bash
# Check server
curl http://localhost:8080/v1/models

# Test tool call
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"afm","messages":[{"role":"user","content":"hello"}]}'
```

### Test Coverage
- File operations (list, filter, size)
- Search commands (grep, find)
- System commands (git, port check)
- Count/stats (files, lines)
- Simple commands (echo)

## Project Status

**Working:**
- ✅ AFM server with OpenAI-compatible API
- ✅ Tool call responses with description field for OpenCode bash tool
- ✅ SSE streaming support (chunk sequence for tool_calls)
- ✅ OpenCode provider integration via `@ai-sdk/openai-compatible`
- ✅ Non-streaming mode (set `stream: false` in provider config)
- ✅ Command approval UI displays correctly
- ✅ Shell prefix stripping for multi-line commands

**Known Limitations:**
- Streaming mode with tool_calls may cause issues in some OpenCode configurations
- Non-streaming mode recommended for stable behavior

## Installation

### Setup Script (Recommended)
```bash
git clone https://github.com/localcodeai/localcode.git
cd localcode
./setup-localcode.sh
```

This installs:
- `localcode-afm` command to start the server
- OpenCode provider configuration

### Manual Setup
```bash
git clone https://github.com/localcodeai/localcode.git
cd localcode
./start-afm-server.sh &
# Then configure OpenCode provider manually (see Quick Start)
```

## Development

Run pre-commit hook manually:
```bash
./pre-commit.sh
```

Or install as git hook:
```bash
cp pre-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
git config core.hooksPath .git/hooks
```

## Why does this exist?

Apple's Foundation Models framework is new and under-documented. This project proves it's viable for CLI tools and provides a reference implementation for others building on AFM with OpenCode.

## Contributing

POCs have rough edges. Contributions welcome:

1. Fork and create a feature branch
2. Make your changes
3. Open a PR

## License

MIT
