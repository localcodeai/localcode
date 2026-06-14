# Raycast Integration

Add LocalCode as a [Raycast Script Command](https://manual.raycast.com/script-commands) for quick access from anywhere on your Mac.

## Setup

1. Open **Raycast Settings** (Cmd+,) → **Script Commands**
2. Click **Add Script Directory**
3. Select `localcode/raycast-extension/scripts/`
4. Type **"LocalCode"** in Raycast to use

## Usage

1. Type "LocalCode" in Raycast
2. Enter a description like "list all python files"
3. The suggested command is **copied to clipboard**
4. Paste in terminal to run

## Requirements

- [AFM server running](./installation.md#starting-the-server)
- Raycast Script Commands enabled

## How It Works

The Raycast script:
1. Sends your description to the AFM server
2. Receives the suggested CLI command
3. Copies it to clipboard for you to review and paste

Unlike OpenCode which shows an approval UI, Raycast gives you a quick way to get commands without leaving your workflow.
