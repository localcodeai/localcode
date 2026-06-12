#!/bin/bash
set -e

INSTALL_DIR="${HOME}/.local/bin"
CONFIG_FILE="${HOME}/.config/opencode/opencode.json"

echo "LocalCode AFM Setup"
echo "==================="
echo ""

if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
fi

echo "Installing start-afm-server.sh to $INSTALL_DIR..."
cp "$(dirname "$0")/start-afm-server.sh" "$INSTALL_DIR/localcode-afm"
chmod +x "$INSTALL_DIR/localcode-afm"

echo "Configuring OpenCode provider..."

if [ -f "$CONFIG_FILE" ]; then
    if grep -q "localcode-afm" "$CONFIG_FILE"; then
        echo "Provider already configured in $CONFIG_FILE"
    else
        echo "Adding provider to existing config..."
        node -e "
const fs = require('fs');
const config = JSON.parse(fs.readFileSync('$CONFIG_FILE', 'utf8'));
config.provider = config.provider || {};
config.provider['localcode-afm'] = {
    npm: '@ai-sdk/openai-compatible',
    name: 'LocalCode AFM',
    options: {
        baseURL: 'http://localhost:8080/v1',
        stream: false
    },
    models: {
        afm: { name: 'Apple Foundation Models' }
    }
};
fs.writeFileSync('$CONFIG_FILE', JSON.stringify(config, null, 2));
"
    fi
else
    echo "Creating new config with provider..."
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat > "$CONFIG_FILE" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {},
  "provider": {
    "localcode-afm": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "LocalCode AFM",
      "options": {
        "baseURL": "http://localhost:8080/v1",
        "stream": false
      },
      "models": {
        "afm": {
          "name": "Apple Foundation Models"
        }
      }
    }
  }
}
EOF
fi

echo ""
echo "Setup complete!"
echo ""
echo "To start LocalCode AFM:"
echo "  $INSTALL_DIR/localcode-afm &"
echo ""
echo "Then run opencode and select 'LocalCode AFM' provider"
echo ""
echo "Quick test:"
echo "  curl http://localhost:8080/v1/models"