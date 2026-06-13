.PHONY: help install start test pre-commit clean server-test run

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
	@echo "Configuring OpenCode provider..."
	@INSTALL_DIR="$(HOME)/.local/bin" && \
	CONFIG_FILE="$(HOME)/.config/opencode/opencode.json" && \
	mkdir -p "$$INSTALL_DIR" && \
	cp "$(PWD)/start-afm-server.sh" "$$INSTALL_DIR/localcode-afm" && \
	chmod +x "$$INSTALL_DIR/localcode-afm" && \
	if [ -f "$$CONFIG_FILE" ]; then \
		if grep -q "localcode-afm" "$$CONFIG_FILE"; then \
			echo "Provider already configured"; \
		else \
			node -e " \
const fs=require('fs'); \
const c=JSON.parse(fs.readFileSync('$$CONFIG_FILE','utf8')); \
c.provider=c.provider||{}; \
c.provider['localcode-afm']={npm:'@ai-sdk/openai-compatible',name:'LocalCode AFM',options:{baseURL:'http://localhost:8080/v1',stream:false},models:{afm:{name:'Apple Foundation Models'}}}; \
fs.writeFileSync('$$CONFIG_FILE',JSON.stringify(c,null,2));"; \
			echo "Provider added"; \
		fi; \
	else \
		mkdir -p "$$(dirname $$CONFIG_FILE)" && \
		echo '{\"$schema\":\"https://opencode.ai/config.json\",\"mcp\":{},\"provider\":{\"localcode-afm\":{\"npm\":\"@ai-sdk/openai-compatible\",\"name\":\"LocalCode AFM\",\"options\":{\"baseURL\":\"http://localhost:8080/v1\",\"stream\":false},\"models\":{\"afm\":{\"name\":\"Apple Foundation Models\"}}}}}' > "$$CONFIG_FILE"; \
		echo "Config created"; \
	fi
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
	@echo "Cleaned built artifacts"

run:
	@make install
	@make start
	@echo "Server running, now run: opencode"