#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title LocalCode
# @raycast.mode silent
# @raycast.description Get CLI commands from natural language
# @raycast.packageName LocalCode
# @raycast.argument1 { "type": "text", "placeholder": "Describe command", "required": true }
# @raycast.refreshTime 1h

PROMPT="$1"
SERVER_URL="${SERVER_URL:-http://localhost:8080}"

if [ -z "$PROMPT" ]; then
  echo "Enter a command description"
  exit 0
fi

RESPONSE=$(curl -s --fail -X POST "$SERVER_URL/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"afm\",\"messages\":[{\"role\":\"user\",\"content\":\"$PROMPT\"}],\"stream\":false}") || {
  echo "Error: Could not reach server"
  exit 1
}

COMMAND=$(echo "$RESPONSE" | python3 -c "
import sys, json
data = json.loads(sys.stdin.read())
tool_calls = data.get('choices', [{}])[0].get('message', {}).get('tool_calls', [])
if tool_calls:
    args = tool_calls[0].get('function', {}).get('arguments', '{}')
    args_data = json.loads(args)
    print(args_data.get('command', ''))
" 2>&1)

if [ -n "$COMMAND" ]; then
  echo "$COMMAND" | pbcopy
  osascript -e 'display notification "Command copied! Paste in terminal to run." with title "LocalCode"'
  echo "Copied: $COMMAND"
else
  echo "Error: No command generated"
  exit 1
fi
