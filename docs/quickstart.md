# Quick Start

## 1. Install

```bash
git clone https://github.com/localcodeai/localcode.git
cd localcode
make install
```

## 2. Start Server

```bash
make start
```

Server runs on `http://localhost:8080`

## 3. Run OpenCode

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