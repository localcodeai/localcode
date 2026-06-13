# Testing

## Quick Test

Check server is running:

```bash
curl http://localhost:8080/v1/models
```

Test tool call:

```bash
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"afm","messages":[{"role":"user","content":"hello"}]}'
```

## Makefile Commands

```bash
make test         # Run prompt test suite (10 test cases)
make server-test  # Run server curl tests only
make pre-commit   # Run all checks
```

## Prompt Test Suite

The test suite validates 10 command categories:

- **File Operations** - list files, filter by type, find largest
- **Search Commands** - grep, find by name
- **System Commands** - git status, port check
- **Count/Stats** - count files, line counts
- **Simple Commands** - echo

Run tests:

```bash
./test-prompts.sh
```

## Pre-commit Hook

Install as git hook:

```bash
cp pre-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
git config core.hooksPath .git/hooks
```

Or run manually:

```bash
./pre-commit.sh
```

Pre-commit runs:
1. Swift build
2. Server health check
3. Non-streaming tool call test
4. Streaming tool call test
5. OpenCode integration test
6. Prompt test suite (10 cases)

## CI/CD

GitHub Actions workflows in `.github/workflows/`:

- `ci.yml` - Basic validation (runs on Linux)
- `afm-tests.yml` - Full AFM tests (requires macOS 26+)