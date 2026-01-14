# Publishing the Orb

## One-Time Setup

```bash
# Authenticate
circleci setup

# Create namespace (first time only)
circleci namespace create <your-org> github <your-github-org>

# Create orb (first time only)
circleci orb create <your-org>/artifactory-orb-v2
```

## Publish Dev Version

```bash
# Pack and publish
circleci orb pack src > orb.yml
circleci orb validate orb.yml
circleci orb publish orb.yml <your-org>/artifactory-orb-v2@dev:test1
```

## Publish Production Version

```bash
# Increment version (major.minor.patch)
circleci orb publish promote <your-org>/artifactory-orb-v2@dev:test1 patch
# Or: minor, major
```

## Usage

```yaml
version: 2.1

orbs:
  artifactory: <your-org>/artifactory-orb-v2@1.0.0

workflows:
  build:
    jobs:
      - artifactory/upload:
          source: "*.jar"
          target: "libs-release-local/"
          context: jfrog-context
```

## Required Context Variables

```
ARTIFACTORY_URL = https://your.jfrog.io/artifactory
ARTIFACTORY_USER = your-username
ARTIFACTORY_API_KEY = your-access-token
ARTIFACTORY_REPO = libs-release-local  # Optional
```

---

**Note:** Orb must be public or organization must enable private orbs.

