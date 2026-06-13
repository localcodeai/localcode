# QA Testing Process

## Server Commands

### Start AFM Server
```bash
cd /Users/christophercarvalho/localcode
pkill -f "bun" 2>/dev/null; sleep 1
./start-afm-server.sh &
sleep 2
```

### Test Server Health
```bash
curl -s http://localhost:8080/v1/models
```

### Test Non-Streaming Tool Call
```bash
curl -s -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"afm","messages":[{"role":"user","content":"list files"}],"stream":false}'
```

### Test Streaming Tool Call
```bash
curl -s -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"afm","messages":[{"role":"user","content":"list files"}],"stream":true}'
```

## OpenCode CLI Tests

### Basic Test (non-streaming via config)
```bash
timeout 45 opencode run --model localcode-afm/afm "list files in current directory" 2>&1 | head -60
```

### Full Test with Approval UI
```bash
timeout 90 opencode run --model localcode-afm/afm "list files" 2>&1 | head -100
```

## Expected Results

### Server Tests
- `/v1/models` returns: `{"object":"list","data":[{"id":"afm",...}]}`
- Non-streaming returns tool_calls with `description` field
- Streaming returns SSE with proper chunk sequence

### OpenCode Tests
- Should show approval UI for tool calls
- Tool call should execute after approval
- Should NOT loop infinitely
- Should NOT show raw red text for tool_calls

## Verification Checklist

- [ ] Server starts without port conflicts
- [ ] `/v1/models` endpoint works
- [ ] Non-streaming tool_calls include `description` field
- [ ] Streaming tool_calls send proper SSE format
- [ ] OpenCode shows tool call approval UI (not raw text)
- [ ] Tool executes successfully after approval
- [ ] No infinite loops after approval