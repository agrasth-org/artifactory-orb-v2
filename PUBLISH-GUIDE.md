# Publishing and Testing Guide

## Option 1: Local Testing (No Publishing Required) ⭐ EASIEST

**Best for:** Quick validation without authentication

### Steps:

1. **Use the test-local.yml config**
   ```bash
   # Copy to your CircleCI project
   cp test-local.yml /path/to/your/circleci-project/.circleci/config.yml
   ```

2. **Set environment variables in CircleCI**
   - Go to your project settings in CircleCI
   - Navigate to Environment Variables
   - Add:
     - `ARTIFACTORY_URL` = `https://your-company.jfrog.io/artifactory`
     - `ARTIFACTORY_USER` = your username
     - `ARTIFACTORY_API_KEY` = your API key or access token

3. **Commit and push**
   ```bash
   git add .circleci/config.yml
   git commit -m "Test JFrog orb locally"
   git push
   ```

4. **Check CircleCI dashboard** - The pipeline will run with the inline orb

**Pros:**
- No authentication needed with CircleCI CLI
- No namespace creation needed
- Quick iteration
- Tests the actual functionality

**Cons:**
- Config file is larger (orb is inline)
- Not testing the full publishing flow

---

## Option 2: Publish as Dev Version (Full Flow)

**Best for:** Complete testing including orb publishing

### Step 1: Authenticate with CircleCI

```bash
# Get your personal API token from:
# https://app.circleci.com/settings/user/tokens

circleci setup
# Paste your token when prompted
```

### Step 2: Check/Create Namespace

A **namespace** is like a package namespace (e.g., `@angular/core`). Format: `namespace/orb-name@version`

```bash
# Check existing namespaces
circleci orb list

# If you don't have a namespace, create one
# Namespace format: your-github-username or your-org-name
circleci namespace create <your-name> github <your-github-org>

# Example:
# circleci namespace create agrasthn github agrasthn
```

**What is namespace?**
- It's YOUR unique identifier in the CircleCI orb registry
- Usually your GitHub username or organization name
- Example: If namespace is `agrasthn`, orb will be `agrasthn/artifactory-orb-v2@dev:test`

### Step 3: Create the Orb (First Time Only)

```bash
# Create the orb under your namespace
circleci orb create <your-namespace>/artifactory-orb-v2

# Example:
# circleci orb create agrasthn/artifactory-orb-v2
```

### Step 4: Publish Dev Version

```bash
cd /Users/agrasthn/workspace/plugins/artifactory-orb-2

# Pack (you already did this)
circleci orb pack src > orb.yml

# Validate (optional, but recommended)
circleci orb validate orb.yml

# Publish as dev version
circleci orb publish orb.yml <your-namespace>/artifactory-orb-v2@dev:test1

# Example:
# circleci orb publish orb.yml agrasthn/artifactory-orb-v2@dev:test1
```

### Step 5: Update test-config.yml

```yaml
orbs:
  # Replace <your-namespace> with your actual namespace
  artifactory: agrasthn/artifactory-orb-v2@dev:test1
```

### Step 6: Use in CircleCI Project

Copy `test-config.yml` to your CircleCI project's `.circleci/config.yml` and push.

---

## Quick Decision Matrix

| Scenario | Recommended Option |
|----------|-------------------|
| Just want to test if it works | **Option 1 (Local)** |
| Learning CircleCI orbs | Option 1 |
| Want to share with team | Option 2 |
| Publishing to CircleCI registry | Option 2 |
| First time testing | **Option 1 (Local)** |

---

## Troubleshooting

### "Error: please set a token"
Run `circleci setup` and create a token at https://app.circleci.com/settings/user/tokens

### "Namespace not found"
You need to create a namespace first:
```bash
circleci namespace create <name> github <org>
```

### "Orb not found"
Make sure you created the orb:
```bash
circleci orb create <namespace>/artifactory-orb-v2
```

### Testing takes too long
Use Option 1 (local testing) for faster iterations. Publish only when you're confident.

