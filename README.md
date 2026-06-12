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
./start-afm-server.sh &

# 2. Configure OpenCode provider in ~/.config/opencode/opencode.json:
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
- ✅ Tool call responses with description field for OpenCode bash tool
- ✅ SSE streaming support (chunk sequence for tool_calls)
- ✅ OpenCode provider integration via `@ai-sdk/openai-compatible`
- ✅ Non-streaming mode (set `stream: false` in provider config)
- ✅ Command approval UI displays correctly
- ✅ Shell prefix stripping for multi-line commands

**Known Limitations:**
- Streaming mode with tool_calls may cause issues in some OpenCode configurations
- Non-streaming mode recommended for stable behavior

## Installation for Others

### Manual Setup
```bash
# Clone the repo
git clone https://github.com/localcodeai/localcode.git
cd localcode

# Start the AFM server
./start-afm-server.sh &

# Configure OpenCode provider (see Quick Start above)
```

### Future Distribution Options

**Option 1: Setup Script**
Create a `setup-localcode.sh` script that:
1. Copies `start-afm-server.sh` to a bin directory
2. Edits `~/.config/opencode/opencode.json` to add the provider
3. Provides start/stop commands

**Option 2: npm Package**
```bash
npm install -g @localcodeai/afm-provider
localcode-afm-setup  # configures OpenCode and starts server
```

**Option 3: Homebrew Tap**
```bash
brew tap localcodeai/localcode
brew install localcode
localcode start  # starts AFM server
opencode         # uses AFM automatically
```

Note: OpenCode's plugin system is for adding custom tools, not AI providers. The current approach uses OpenCode's built-in provider configuration system.

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