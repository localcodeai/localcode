# LocalCode Raycast Extension

A Raycast extension that converts natural language to CLI commands using Apple Foundation Models.

## Requirements

- Raycast installed
- LocalCode server running (`make start` in the LocalCode repo)
- macOS 26+, Xcode 26+, Apple Silicon Mac

## Installation

1. Open Raycast
2. Navigate to `Extensions` (Cmd+, → Extensions)
3. Click "Import Extension"
4. Select this folder (`raycast-extension`)

Or use the CLI:

```bash
cd raycast-extension
raycast extension install .
```

## Usage

1. Press `Cmd+Shift+P` to open the command palette
2. Type "LocalCode"
3. Enter a natural language prompt (e.g., "list all python files")
4. Copy the suggested command or run it directly

## Configuration

Edit `manifest.json` to change the server URL if needed. Default: `http://localhost:8080`

## Development

```bash
cd raycast-extension
raycast extension dev
```

## Notes

The LocalCode server must be running for this extension to work:

```bash
cd /path/to/localcode
make start
```