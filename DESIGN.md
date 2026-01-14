# CircleCI Artifactory Orb - Design & Architecture

## Overview

A CircleCI orb for JFrog Artifactory with JFrog CLI v2 support, built on a two-layer architecture for reusability and maintainability.

## Architecture Pattern

```
┌─────────────────────────────────────────┐
│   Platform Layer (CircleCI-Specific)    │
│                                         │
│   • Orb commands (YAML)                │
│   • Orb jobs (YAML)                    │
│   • Parameter definitions              │
│   • CircleCI-specific workflows        │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      Core Layer (Generic CLI Wrapper)   │
│                                         │
│   • Reusable shell scripts             │
│   • JFrog CLI v2 operations            │
│   • Platform-agnostic logic            │
│   • Can be reused across platforms     │
└─────────────────────────────────────────┘
                  ↓
          JFrog CLI v2 → JFrog Platform
```

## Directory Structure

```
artifactory-orb-2/
├── cli-wrapper/              # Core Layer: Reusable scripts
│   ├── install.sh           # Install JFrog CLI
│   ├── configure.sh         # Configure server connection
│   ├── upload.sh            # Upload artifacts
│   ├── download.sh          # Download artifacts
│   ├── build-info.sh        # Collect & publish build info
│   ├── scan.sh              # Xray security scanning
│   └── docker.sh            # Docker operations
│
├── src/                     # Platform Layer: CircleCI orb
│   ├── @orb.yml            # Orb metadata
│   ├── commands/           # CircleCI commands
│   │   ├── install.yml
│   │   ├── configure.yml
│   │   ├── upload.yml
│   │   ├── download.yml
│   │   ├── build-integration.yml
│   │   ├── scan.yml
│   │   ├── docker-login.yml
│   │   ├── docker-push.yml
│   │   └── docker-promote.yml
│   ├── jobs/               # Pre-built workflows
│   │   ├── upload.yml
│   │   ├── docker-publish.yml
│   │   └── docker-promote.yml
│   ├── executors/          # Runtime environments
│   │   ├── default.yml
│   │   └── machine.yml
│   └── examples/           # Usage examples
│       ├── upload-artifacts.yml
│       ├── docker-workflow.yml
│       └── custom-workflow.yml
│
└── .circleci/config.yml    # Orb testing config
```

## Design Principles

### 1. Separation of Concerns
- **Core scripts** (`cli-wrapper/`) handle JFrog CLI operations
- **Platform layer** (`src/`) handles CircleCI-specific integration
- Clear boundary enables reuse for other CI/CD platforms

### 2. JFrog CLI v2 First
- Uses `jf config add` (not deprecated `jfrog rt config`)
- Uses `--access-token` (not `--password` which triggers 404)
- Uses official installer: `https://install-cli.jfrog.io`

### 3. Parameter Strategy
- **String parameters** for direct values (url, user, apikey)
- **Default to environment variables** for flexibility
- Jobs include credential parameters with env var defaults

### 4. Authentication Pattern
```bash
jf config add <server-id> \
  --artifactory-url="$URL" \
  --user="$USER" \
  --access-token="$API_KEY" \  # Works for API keys and access tokens
  --interactive=false
```

### 5. Error Handling
- Repository validation before upload
- Connection verification after configuration
- Clear error messages with remediation steps

## Key Implementation Details

### CLI Installation
- Uses official JFrog installer (not manual URL construction)
- Auto-detects OS and architecture
- Idempotent: checks if already installed

### Configuration
- Single command configures server connection
- Supports both API keys and access tokens
- Verifies configuration with `jf config show`

### Build Information
- `build-collect-env` and `build-add-git` run locally (no --server-id)
- `build-publish` uploads to server (requires --server-id)
- Attaches Git metadata and environment variables

### Upload/Download
- Uses `jf rt upload`/`jf rt download`
- Supports build info attachment via --build-name/--build-number
- Repository validation prevents cryptic 404 errors



### What Worked
✅ Two-layer architecture (generic + platform-specific)  
✅ Official JFrog CLI installer  
✅ --access-token for authentication  
✅ String parameters (not env_var_name type)  
✅ Pre-upload repository validation  

### What Didn't Work
❌ Hardcoded version URLs (broke with version changes)  
❌ --password flag (triggers encryption API 404)  
❌ JFrog CLI v1 syntax (deprecated warnings)  
❌ env_var_name parameters (type errors in orbs)  
❌ --server-id on local commands (wrong argument count)  

### Critical Fixes
1. **404 on configuration**: Changed `--password` to `--access-token`
2. **404 on upload**: Added URL validation (must end with `/artifactory`)
3. **Wrong argument count**: Removed `--server-id` from build-collect-env/build-add-git
4. **Type errors**: Changed from `env_var_name` to `string` parameters

## Reusability for Other Platforms

The `cli-wrapper/` scripts can be reused for:
- **GitHub Actions**: Call scripts from action.yml
- **GitLab CI**: Call scripts from .gitlab-ci.yml
- **Jenkins**: Call scripts from Groovy pipeline
- **Bitbucket Pipes**: Call scripts from pipe.sh

Only the platform layer needs to be recreated for each CI/CD tool.

