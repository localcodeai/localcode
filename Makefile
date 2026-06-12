.PHONY: help install start test pre-commit clean server-test

help:
	@echo "LocalCode - Apple Foundation Models for OpenCode"
	@echo ""
	@echo "Usage:"
	@echo "  make install      Build Swift helper and setup OpenCode config"
	@echo "  make start        Start the AFM server"
	@echo "  make test         Run prompt test suite"
	@echo "  make server-test  Run server curl tests only"
	@echo "  make pre-commit   Run all checks (Swift build + server + OpenCode + prompts)"
	@echo "  make clean        Remove built artifacts"
	@echo ""
	@echo "Requirements: macOS 26+, Xcode 26+, Bun 1.3+, Node 18+"

install:
	@echo "Building Swift AFM helper..."
	@cd LocalCode/Sources/afmhelper && swiftc -o afmhelper main.swift -framework FoundationModels -target arm64-apple-macosx26.0
	@echo "Swift build: OK"
	@echo "Run 'make start' to start the server, then 'opencode'"

start:
	@echo "Starting AFM server on http://localhost:8080..."
	@pkill -f "bun.*8080" 2>/dev/null || true
	@sleep 1
	@nohup ./start-afm-server.sh > /tmp/afm-server.log 2>&1 &
	@sleep 2
	@curl -s http://localhost:8080/v1/models | grep -q "afm" && echo "Server running" || echo "Server failed to start"

stop:
	@pkill -f "bun.*8080" 2>/dev/null || true
	@echo "Server stopped"

test:
	@./test-prompts.sh

server-test:
	@echo "Testing server endpoints..."
	@curl -s http://localhost:8080/v1/models | grep -q "afm" || (echo "Server not running - run 'make start' first" && exit 1)
	@curl -s -X POST http://localhost:8080/v1/chat/completions \
		-H "Content-Type: application/json" \
		-d '{"model":"afm","messages":[{"role":"user","content":"test"}],"stream":false}' \
		| grep -q "tool_calls" && echo "Server tests: OK" || echo "Server tests: FAILED"

pre-commit:
	@./pre-commit.sh

clean:
	@rm -f LocalCode/Sources/afmhelper/afmhelper
	@rm -f localcode-afm/src/afmhelper
	@echo "Cleaned built artifacts"