# LocalCode Raycast Script

A [Raycast Script Command](https://manual.raycast.com/script-commands) that converts natural language to CLI commands using Apple Foundation Models.

## Requirements

- Raycast installed
- LocalCode server running (`make start`)
- macOS 26+, Xcode 26+, Apple Silicon Mac

## Installation

1. Open **Raycast Settings** (Cmd+,) → **Script Commands**
2. Click **Add Script Directory**
3. Select `localcode/raycast-extension/scripts/`

## Usage

1. Type "LocalCode" in Raycast
2. Enter a natural language prompt (e.g., "list all python files")
3. The command is copied to clipboard
4. Paste in terminal to run

## Server

The LocalCode server must be running:

```bash
cd localcode
make start
```
