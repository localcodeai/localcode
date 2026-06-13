# Architecture

```
LocalCode/
├── LocalCode/Sources/afmhelper/   # Swift AFM helper
│   └── main.swift                # Apple FoundationModels integration
├── localcode-afm/                 # Distribution package
│   ├── bin/start.sh              # Entry point
│   ├── package.json              # Package config
│   └── src/main.swift            # Swift source
├── start-afm-server.sh           # HTTP middleware (Bun)
├── setup-localcode.sh            # Setup script
├── test-prompts.sh              # Test suite
├── pre-commit.sh                 # Pre-commit hook
└── Makefile                      # Build commands
```

## Flow

```
User Input → OpenCode → AFM Server → Swift Helper → Apple AFM
                ↑                                      ↓
            Approval UI                          Command
                ↑                                      ↓
            User approves → OpenCode executes command
```

## Components

### Swift AFM Helper

Uses `SystemLanguageModel.default` from Apple's FoundationModels framework.

```swift
let model = SystemLanguageModel.default
let session = LanguageModelSession()
let response = try await session.generate(prompt)
```

### AFM Server

Bun HTTP server that wraps the Swift helper with an OpenAI-compatible API.

Endpoints:
- `GET /v1/models` - List available models
- `POST /v1/chat/completions` - Chat completions with tool calls

### OpenCode Provider

Uses `@ai-sdk/openai-compatible` with config in `~/.config/opencode/opencode.json`:

```json
{
  "provider": {
    "localcode-afm": {
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "http://localhost:8080/v1",
        "stream": false
      }
    }
  }
}
```

## Tool Calls

AFM returns a command, the server wraps it as a tool call:

```json
{
  "tool_calls": [{
    "function": {
      "name": "bash",
      "arguments": "{\"command\": \"find . -name '*.py'\", \"description\": \"AFM generated command\"}"
    }
  }]
}
```

OpenCode displays approval UI before execution.

## No Fork Required

Uses global OpenCode with provider configuration - no modifications to OpenCode itself.