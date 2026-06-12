# @localcodeai/afm

Apple Foundation Models provider for OpenCode.

## Install

```bash
npm install -g @localcodeai/afm
```

This will:
1. Install the package
2. Build the Swift AFM helper
3. Configure OpenCode to use localcode-afm provider

## Usage

```bash
# Start the AFM server
localcode-afm

# In OpenCode, select the provider
/opencode
> /models localcode-afm/afm
```

## Requirements

- Apple Silicon Mac (M1/M2/M3/M4)
- macOS 26+
- Xcode 26+
- Bun 1.3+
- Node 18+

## What is this?

This package provides a local AI provider for OpenCode using Apple's on-device Foundation Models. Your commands and data never leave your machine.

## Uninstall

```bash
npm uninstall -g @localcodeai/afm
```