# Release Strategy

## Overview

Release early, release often. Keep the project stable with automated tests.

## Version Strategy

- `0.0.x` - Patch releases (bug fixes)
- `0.x.0` - Minor releases (new features, backwards compatible)
- `x.0.0` - Major releases (breaking changes)

## Pre-Release Test Gates

All tests must pass before a release:

1. **Swift build** - Compiles with FoundationModels framework
2. **Server curl tests** - `/v1/models` and `/v1/chat/completions` endpoints
3. **OpenCode integration** - Shows approval UI
4. **Prompt test suite** - 10 test cases covering file ops, search, system, count, simple
5. **Docs consistency** - README ↔ docs sync check

Run locally: `make pre-commit`

## Release Workflow

```
feature branch → PR → CI tests pass → merge to main
                                              ↓
                                  git tag v*.*.*
                                              ↓
                              GitHub Actions triggers:
                              1. Run full test suite
                              2. If passed → create GitHub release
                              3. If passed → npm publish (with dry-run validation)
                                              ↓
                              If any test fails → release blocked, notify maintainers
```

## Release Tools

### release-please
Automates changelog generation from commit messages.
- Configured via `release-please-config.json`
- Creates PR with updated version/changelog on merge
- Triggers publish on tag creation

### GitHub Actions
Gates the publish step:
```yaml
on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: make pre-commit
      - name: Publish to GitHub
        if: success()
        run: |
          gh release create ${{ github.ref_name }} ...
      - name: Publish to npm
        if: success()
        run: npm publish --dry-run
```

## npm Publishing

### One-time Setup
```bash
npm adduser  # Create npm account
npm login
```

### Publishing
```bash
# For @localcodeai/afm package
cd localcode-afm
npm version patch  # bump version
npm publish        # to npm registry

# Git tag after publish
git tag v0.0.2
git push origin v0.0.2
```

### Scoped vs Unscoped
- **@localcodeai/afm** - Requires npm org membership, publish under organization
- **localcode-afm** - Unscoped, anyone can publish

## GitHub Topics

Add to repo settings (Settings → General → Topics):
- `cli`
- `apple-silicon`
- `ai`
- `opencode`
- `foundation-models`
- `macos`
- `local-ai`

## Manual Checklist Before Release

- [ ] All tests pass locally (`make pre-commit`)
- [ ] CI passes on main branch
- [ ] Version bumped in package.json
- [ ] Changelog updated (or release-please PR merged)
- [ ] Docs updated if needed
- [ ] No console.log/debug statements left in code
- [ ] npm package clean (`rm -rf node_modules && npm install`)

## Rollback Plan

If bad release:
1. GitHub: Delete release + tag
2. npm: `npm unpublish localcode-afm@0.0.x` (within 72 hours)
3. Fix issue in next patch release

## Future Enhancements

- Manual approval gate for npm publish (require reviewer)
- Automated changelog via release-please
- Pre-release npm tagging (`npm publish --tag beta`)
- GitHub Release draft for review before publish