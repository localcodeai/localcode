# Quick Start

## 1. Install and Start

```bash
git clone https://github.com/localcodeai/localcode.git
cd localcode
make run
```

This builds the Swift helper, configures OpenCode, and starts the server.

Server runs on `http://localhost:8080`

## 2. Run OpenCode

```bash
opencode
```

Select "LocalCode AFM" provider:

```
/models localcode-afm/afm
```

## 4. Use

Try natural language commands:

```
You: list all python files in this directory
AFM: suggests: find . -name "*.py"
     ↑ approval UI appears
You: approves
OpenCode: executes find . -name "*.py"
```

## Example Commands

| What you type | Command suggested |
|--------------|-------------------|
| "list all files" | `find . -type f` |
| "show git status" | `git status` |
| "find files named test" | `find . -name "*test*"` |
| "count python files" | `find . -name "*.py" \| wc -l` |
| "check port 8080" | `lsof -i :8080` |

## Next Steps

- [Installation](installation) - More setup options
- [Testing](testing) - Run the test suite
- [Architecture](architecture) - How it works