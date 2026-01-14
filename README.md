# JFrog Artifactory CircleCI Orb v2

CircleCI Orb for JFrog Artifactory with JFrog CLI v2 support.

## Features

- ✅ JFrog CLI v2 syntax (no deprecated warnings)
- ✅ Modern authentication (access tokens)
- ✅ Artifact upload/download
- ✅ Build information collection & publishing
- ✅ Xray security scanning
- ✅ Docker image operations
- ✅ Reusable CLI wrapper scripts

## Quick Start

```yaml
version: 2.1

orbs:
  artifactory: <your-org>/artifactory-orb-v2@1.0.0

workflows:
  build-and-upload:
    jobs:
      - artifactory/upload:
          source: "build/*.jar"
          target: "libs-release-local/${CIRCLE_PROJECT_REPONAME}/"
          build-name: "${CIRCLE_PROJECT_REPONAME}"
          build-number: "${CIRCLE_BUILD_NUM}"
          context: jfrog-context
```

## Available Commands

| Command | Description |
|---------|-------------|
| `install` | Install JFrog CLI |
| `configure` | Configure server connection |
| `upload` | Upload artifacts to Artifactory |
| `download` | Download artifacts from Artifactory |
| `build-integration` | Collect and publish build information |
| `scan` | Scan build with Xray |
| `docker-login` | Login to Docker registry |
| `docker-push` | Push Docker image |
| `docker-promote` | Promote Docker image |

## Available Jobs

| Job | Description |
|-----|-------------|
| `upload` | Build artifacts and upload to Artifactory |
| `docker-publish` | Build and push Docker image |
| `docker-promote` | Promote Docker image between repos |

## Configuration

Set these environment variables in a CircleCI context:

```bash
ARTIFACTORY_URL=https://your.jfrog.io/artifactory  # Must end with /artifactory
ARTIFACTORY_USER=your-username
ARTIFACTORY_API_KEY=your-access-token
ARTIFACTORY_REPO=libs-release-local  # Optional, defaults to generic-local
```

## Architecture

Two-layer design for reusability:

- **Core Layer** (`cli-wrapper/`): Generic, reusable shell scripts
- **Platform Layer** (`src/`): CircleCI-specific YAML definitions

See [DESIGN.md](DESIGN.md) for architecture details.

## Publishing

See [PUBLISH.md](PUBLISH.md) for publishing instructions.

## Examples

### Using Commands

```yaml
jobs:
  custom-job:
    docker:
      - image: cimg/base:stable
    steps:
      - checkout
      - artifactory/install
      - artifactory/configure:
          url: ${ARTIFACTORY_URL}
          user: ${ARTIFACTORY_USER}
          apikey: ${ARTIFACTORY_API_KEY}
      - run: mvn clean package
      - artifactory/upload:
          source: "target/*.jar"
          target: "libs-release-local/"
```

### Using Pre-built Jobs

```yaml
workflows:
  deploy:
    jobs:
      - artifactory/upload:
          source: "dist/*"
          target: "npm-local/${CIRCLE_PROJECT_REPONAME}/"
          build-steps:
            - run: npm run build
```

## License

See [LICENSE](LICENSE) file.

## Related Projects

- [jfrog-plugin-generator](../jfrog-plugin-generator/) - Generator for JFrog plugins across platforms
