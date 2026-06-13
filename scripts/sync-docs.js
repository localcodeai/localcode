#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');

function read(file) {
  return fs.readFileSync(path.join(ROOT, file), 'utf8');
}

function extractSection(content, startMarker, endMarker) {
  const start = content.indexOf(startMarker);
  if (start === -1) return '';
  const end = endMarker ? content.indexOf(endMarker, start) : content.length;
  return content.slice(start, end).trim();
}

function check(key, readmePatterns, docPatterns) {
  const readme = read('README.md');
  const doc = read('docs/' + docPatterns.file);

  const issues = [];

  for (const pattern of readmePatterns) {
    if (!readme.includes(pattern)) {
      issues.push(`README.md missing: "${pattern}"`);
    }
  }

  if (docPatterns.content) {
    if (!doc.includes(docPatterns.content)) {
      issues.push(`docs/${docPatterns.file} missing: "${docPatterns.content}"`);
    }
  }

  return issues;
}

const checks = [
  {
    key: 'make install',
    readmePatterns: ['make install', 'make start'],
    docPatterns: { file: 'installation.md', content: 'make install' }
  },
  {
    key: 'OpenCode config',
    readmePatterns: ['localcode-afm', '@ai-sdk/openai-compatible'],
    docPatterns: { file: 'installation.md', content: 'localcode-afm' }
  },
  {
    key: 'Requirements',
    readmePatterns: ['Apple Silicon', 'macOS 26', 'Xcode 26', 'Bun', 'Node 18'],
    docPatterns: { file: 'installation.md', content: 'Apple Silicon' }
  },
  {
    key: 'Test commands',
    readmePatterns: ['make test', 'make pre-commit', 'test-prompts.sh'],
    docPatterns: { file: 'testing.md', content: 'make test' }
  },
  {
    key: 'Quick start steps',
    readmePatterns: ['make install', 'make start', 'opencode'],
    docPatterns: { file: 'quickstart.md', content: 'make install' }
  },
  {
    key: 'Architecture',
    readmePatterns: ['start-afm-server.sh', 'pre-commit.sh', 'Makefile'],
    docPatterns: { file: 'architecture.md', content: 'start-afm-server.sh' }
  }
];

console.log('Checking README ↔ docs consistency...\n');

let failed = false;

for (const c of checks) {
  const issues = check(c.key, c.readmePatterns, c.docPatterns);
  if (issues.length > 0) {
    console.log(`❌ ${c.key}`);
    issues.forEach(i => console.log(`   ${i}`));
    failed = true;
  } else {
    console.log(`✓ ${c.key}`);
  }
}

console.log('');

if (failed) {
  console.log('FAILED: Inconsistencies found between README and docs');
  process.exit(1);
} else {
  console.log('All consistency checks passed!');
  process.exit(0);
}