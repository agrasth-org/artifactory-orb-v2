# Testing the JFrog Artifactory Orb v2

## Prerequisites

Install CircleCI CLI:
```bash
# macOS
brew install circleci

# Or via curl
curl -fLSs https://raw.githubusercontent.com/CircleCI-Public/circleci-cli/master/install.sh | bash
```

## Option 1: Local Validation (Quick Check)

### Step 1: Validate Orb Syntax
```bash
cd /Users/agrasthn/workspace/plugins/artifactory-orb-2
circleci orb validate src/@orb.yml
```

### Step 2: Pack the Orb
```bash
# This combines all files in src/ into a single orb YAML
circleci orb pack src > orb.yml

# Validate the packed orb
circleci orb validate orb.yml
```

## Option 2: Inline Testing (Recommended for Development)

### Step 1: Pack the Orb
```bash
cd /Users/agrasthn/workspace/plugins/artifactory-orb-2
circleci orb pack src > orb.yml
```

### Step 2: Create a Test Project
Create a test directory with a `.circleci/config.yml`:

```yaml
version: 2.1

# Define the orb inline for testing
orbs:
  artifactory: {}  # Will be replaced by inline definition

# Or use local file directly
setup: true

workflows:
  test-orb:
    jobs:
      - test-install
      - test-upload:
          requires:
            - test-install

jobs:
  test-install:
    docker:
      - image: cimg/base:stable
    steps:
      - artifactory/install
      - run:
          name: Verify CLI Installation
          command: jf --version

  test-upload:
    docker:
      - image: cimg/base:stable
    steps:
      - checkout
      - artifactory/install
      - artifactory/configure:
          url: ${ARTIFACTORY_URL}
          user: ${ARTIFACTORY_USER}
          apikey: ${ARTIFACTORY_API_KEY}
      - artifactory/upload:
          source: "*.txt"
          target: "test-repo/"
```

### Step 3: Validate Config with Inline Orb
```bash
# Create a combined config with inline orb
cat > test-config.yml << 'EOF'
version: 2.1

orbs:
  artifactory:
    commands:
      install:
        # Copy content from your src/commands/install.yml
        steps:
          - run: echo "inline test"
# ... rest of config
EOF

circleci config validate test-config.yml
```

## Option 3: Publish as Dev Version (Real Pipeline Testing)

### Step 1: Setup CircleCI Authentication
```bash
# Get your token from CircleCI: https://app.circleci.com/settings/user/tokens
circleci setup

# Or set token directly
export CIRCLECI_CLI_TOKEN=your_token_here
```

### Step 2: Create Namespace (First Time Only)
```bash
# Check if you have a namespace
circleci namespace list

# If not, create one (requires organization admin)
circleci namespace create <your-namespace> <vcs-type> <org-name>
# Example: circleci namespace create my-company github my-github-org
```

### Step 3: Create the Orb (First Time Only)
```bash
circleci orb create <your-namespace>/artifactory-orb-v2
```

### Step 4: Publish Dev Version
```bash
cd /Users/agrasthn/workspace/plugins/artifactory-orb-2

# Pack and publish as dev version
circleci orb pack src > orb.yml
circleci orb publish orb.yml <your-namespace>/artifactory-orb-v2@dev:first

# Or use shorthand (auto-increments dev version)
circleci orb publish orb.yml <your-namespace>/artifactory-orb-v2@dev:alpha
```

### Step 5: Use Dev Version in Test Project
```yaml
version: 2.1

orbs:
  artifactory: <your-namespace>/artifactory-orb-v2@dev:first

workflows:
  test-workflow:
    jobs:
      - artifactory/upload:
          source: "*.txt"
          target: "test-repo/"
          url: ${ARTIFACTORY_URL}
          user: ${ARTIFACTORY_USER}
          apikey: ${ARTIFACTORY_API_KEY}
```

## Option 4: Local Docker Testing

Test CLI wrapper scripts independently:

```bash
cd /Users/agrasthn/workspace/plugins/artifactory-orb-2

# Test install script
docker run --rm -v $(pwd)/cli-wrapper:/scripts cimg/base:stable \
  bash /scripts/install.sh

# Test configure script
docker run --rm -v $(pwd)/cli-wrapper:/scripts \
  -e JFROG_URL=https://your.jfrog.io \
  -e JFROG_USER=admin \
  -e JFROG_API_KEY=your_key \
  cimg/base:stable \
  bash -c "/scripts/install.sh && /scripts/configure.sh default-server"

# Test upload script
docker run --rm -v $(pwd)/cli-wrapper:/scripts \
  -v $(pwd):/workspace \
  -w /workspace \
  cimg/base:stable \
  bash -c "/scripts/install.sh && /scripts/configure.sh default-server && \
           /scripts/upload.sh 'test.txt' 'test-repo/'"
```

## Recommended Testing Flow

### 1. Quick Validation (Start Here)
```bash
cd /Users/agrasthn/workspace/plugins/artifactory-orb-2

# Validate syntax
circleci orb validate src/@orb.yml

# Pack and validate
circleci orb pack src > orb.yml
circleci orb validate orb.yml
```

### 2. Test CLI Scripts Independently
```bash
# Create test files
echo "test content" > test.txt

# Test each script
./cli-wrapper/install.sh
./cli-wrapper/configure.sh test-server
# ... etc
```

### 3. Publish Dev Version & Test in Real Pipeline
```bash
# Publish
circleci orb publish orb.yml <namespace>/artifactory-orb-v2@dev:test1

# Create a test CircleCI project and use the dev orb
# Monitor the pipeline at https://app.circleci.com
```

### 4. Iterate
```bash
# Make changes, then republish
circleci orb publish orb.yml <namespace>/artifactory-orb-v2@dev:test2
```

## Environment Variables for Testing

Set these in CircleCI project settings or context:

```bash
ARTIFACTORY_URL=https://your-company.jfrog.io/artifactory
ARTIFACTORY_USER=your-username
ARTIFACTORY_API_KEY=your-api-key-or-access-token
```

## Common Issues

### Issue: "Orb not found"
- Ensure you've published the dev version
- Check namespace and orb name spelling
- Wait 1-2 minutes after publishing

### Issue: "Permission denied" on scripts
- Run: `chmod +x cli-wrapper/*.sh`
- Ensure scripts have executable permissions in git

### Issue: "jf: command not found"
- Check install.sh completed successfully
- Verify PATH includes JFrog CLI location
- Check CircleCI executor has internet access

## Next Steps After Successful Testing

1. Publish a production version:
   ```bash
   circleci orb publish promote <namespace>/artifactory-orb-v2@dev:test1 major|minor|patch
   ```

2. Update documentation and examples

3. Create GitHub repository for the orb

4. Submit to CircleCI orb registry (optional)

