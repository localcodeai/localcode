# LocalCode

Turn natural language into CLI commands using Apple's on-device AI, powered by OpenCode.

## What is this?

LocalCode is a proof-of-concept that integrates Apple Foundation Models (AFM) with OpenCode as a local AI provider. Tell it what you want in plain English, it suggests the right command via tool calls, and you approve before execution.

**All AI processing happens locally on your Mac.** No cloud, no data leaving your machine.

## Requirements

- Apple Silicon Mac (M1/M2/M3/M4)
- macOS 26+
- Xcode 26+ (for building the Swift helper)
- Bun 1.3+

## Architecture

```
LocalCode/
├── LocalCode/Sources/afmhelper/   # Swift AFM helper
│   └── main.swift                # Apple FoundationModels integration
├── start-afm-server.sh           # HTTP middleware (Bun)
└── pre-commit.sh                 # Pre-commit hook
```

**No fork needed** - uses global OpenCode with provider config in `~/.config/opencode/opencode.json`

**Flow:**
1. AFM Server wraps Swift helper with OpenAI-compatible API
2. OpenCode uses AFM as a provider via `@ai-sdk/openai-compatible`
3. AFM returns command suggestions as tool calls
4. OpenCode shows command approval UI → user approves → command executes

## Quick Start

```bash
# 1. Start the AFM middleware server
cd /Users/christophercarvalho/localcode
./start-afm-server.sh &

# 2. Configure OpenCode provider in ~/.config/opencode/opencode.json:
{
  "provider": {
    "localcode-afm": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "LocalCode AFM",
      "options": {
        "baseURL": "http://localhost:8080/v1"
      },
      "models": {
        "afm": { "name": "Apple Foundation Models" }
      }
    }
  }
}

# 3. Run OpenCode
opencode

# 4. Select "LocalCode AFM" provider via /models command
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

## Testing the AFM Server

```bash
# Check server is running
curl http://localhost:8080/v1/models

# Test chat completion (returns tool call)
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"afm","messages":[{"role":"user","content":"hello"}]}'

# Test streaming
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"afm","messages":[{"role":"user","content":"hello"}],"stream":true}'
```

## Project Status

**Working:**
- ✅ AFM server with OpenAI-compatible API
- ✅ Tool call responses for command approval UI
- ✅ SSE streaming support
- ✅ OpenCode provider integration via `@ai-sdk/openai-compatible`
- ✅ Extracts user message from OpenCode's system prompt

**Known Limitations:**
- OpenCode sends full system prompt with all tool definitions - AFM can get confused and output partial commands
- Command approval UI shows tool_calls but may need OpenCode-side configuration
- Further debugging needed on OpenCode integration

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