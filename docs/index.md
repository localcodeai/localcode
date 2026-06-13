# LocalCode

Turn natural language into CLI commands using Apple's on-device AI, powered by OpenCode.

<div align="center">

![Platform](https://img.shields.io/badge/platform-Apple%20Silicon%20(M1--M4)-lightgray)
![macOS](https://img.shields.io/badge/macOS-26%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)

</div>

## What is this?

LocalCode integrates Apple Foundation Models (AFM) with OpenCode as a local AI provider. Tell it what you want in plain English, it suggests the right command via tool calls, and you approve before execution.

**All AI processing happens locally on your Mac.** No cloud, no data leaving your machine.

## Features

- **Local AI** - Uses Apple Foundation Models, no internet required
- **Privacy-first** - Your commands and data never leave your machine
- **Tool Calls** - OpenCode shows command approval UI before execution
- **OpenAI Compatible** - Works with any OpenAI-compatible provider client

## Requirements

- Apple Silicon Mac (M1/M2/M3/M4)
- macOS 26+
- Xcode 26+ (for building the Swift helper)
- Bun 1.3+
- Node 18+

## Quick Start

```bash
git clone https://github.com/localcodeai/localcode.git
cd localcode

make install   # Build Swift helper
make start      # Start AFM server

opencode        # Select "LocalCode AFM" provider
```

## How It Works

```
You: "list all python files in this directory"
AFM: [Tool Call: bash { command: "find . -name '*.py'" }]
     ↑ Approval UI appears
User: approves
OpenCode: executes find . -name '*.py'
Output: ./file1.py
        ./subdir/file2.py
```

## Example Commands

**File Operations:**
- "list all python files"
- "show me the largest files"
- "count all files in this directory"

**System & Network:**
- "show git status"
- "check if port 8080 is in use"

**Search:**
- "grep for hello in this directory"