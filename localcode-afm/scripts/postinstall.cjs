#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const CONFIG_FILE = path.join(process.env.HOME, '.config/opencode/opencode.json');

console.log('Setting up LocalCode AFM for OpenCode...');

const providerConfig = {
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

try {
  let config = { provider: {} };

  if (fs.existsSync(CONFIG_FILE)) {
    try {
      config = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
      config.provider = config.provider || {};
    } catch (e) {
      console.log('Existing config corrupted, creating new one');
    }
  }

  if (config.provider['localcode-afm']) {
    console.log('Provider already configured in ~.config/opencode/opencode.json');
  } else {
    config.provider['localcode-afm'] = providerConfig;
    fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2));
    console.log('Added localcode-afm provider to ~.config/opencode/opencode.json');
  }

  console.log('');
  console.log('Setup complete!');
  console.log('');
  console.log('To start LocalCode AFM:');
  console.log('  localcode-afm');
  console.log('');
  console.log('Then in OpenCode:');
  console.log('  /models localcode-afm/afm');
  console.log('');
} catch (error) {
  console.error('Setup failed:', error.message);
  process.exit(1);
}