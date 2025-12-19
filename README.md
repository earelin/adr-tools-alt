# adr-tools-alt

Alternative tools for managing a repository of Architecture Decision Records (ADRs), written in Rust.

This is a Rust implementation that mimics the behavior of [adr-tools](https://github.com/npryce/adr-tools), providing a fast and reliable way to manage Architecture Decision Records.

## Installation

```bash
cargo install adr-tools-alt
```

Or build from source:

```bash
git clone https://github.com/earelin/adr-tools-alt
cd adr-tools-alt
cargo build --release
```

## Usage

### Initialize ADR directory

```bash
adr init [directory]
```

Creates a new ADR directory (default: `doc/adr`) and adds the first ADR documenting the decision to use ADRs.

### Create a new ADR

```bash
adr new "Title of the decision"
```

Creates a new numbered ADR file with the given title.

### Supersede an existing ADR

```bash
adr new "New decision" --supersede 5
```

Creates a new ADR and marks ADR #5 as superseded.

### List all ADRs

```bash
adr list
```

Lists all existing ADRs with their titles.

### Generate documentation

```bash
adr generate toc
```

Generates a table of contents for all ADRs in Markdown format.

## Features

- ✅ Initialize ADR directory structure
- ✅ Create new ADRs with automatic numbering
- ✅ Supersede existing ADRs
- ✅ List all ADRs
- ✅ Generate table of contents
- ✅ Configurable ADR directory
- ✅ Auto-open ADRs in editor (via VISUAL/EDITOR env vars)
- ✅ Proper filename slugification
- 🔒 Security scanning with Snyk integration
- 🛡️ Automated vulnerability detection

## ADR Template

ADRs follow the standard format:

```markdown
# NUMBER. Title

Date: YYYY-MM-DD

## Status

Accepted

## Context

The issue motivating this decision...

## Decision

The change that we're proposing...

## Consequences

What becomes easier or more difficult...
```

## Development

This project uses a modern CI/CD pipeline structure with separate validation for different stages:

### Quick Start
```bash
# Setup development environment  
make setup              # Install all dependencies and tools

# Development workflow
make ci                 # Run CI pipeline (PR validation - no security)
make cd                 # Run CD pipeline (full security validation)
make test-watch         # Watch mode for continuous testing
make demo               # Interactive demo

# View all available commands
make help               # Show all available targets
```

### CI/CD Pipeline Structure

#### CI Pipeline (`make ci`)
- **Purpose**: Fast feedback for pull requests
- **Triggers**: PR creation and updates
- **Includes**: Code quality, tests, build validation, coverage
- **Excludes**: Security scans (for speed)

#### CD Pipeline (`make cd`)  
- **Purpose**: Comprehensive validation for deployment
- **Triggers**: Pushes to trunk, scheduled runs
- **Includes**: All CI checks + security audit + SBOM generation + compliance

### Local Development Commands
For a complete list of available commands, run `make help`.

## Security & SBOM

This project includes comprehensive security scanning and Software Bill of Materials (SBOM) generation:

### SBOM Generation

Generate SBOM files for supply chain security analysis:

```bash
# Generate all SBOM formats using Makefile
make sbom

# Generate and upload to Snyk for scanning
make sbom-snyk

# Or use the standalone script (legacy)
./scripts/generate-sbom.sh --formats cyclonedx,spdx --output ./sbom-files
```

The SBOM generation creates files in multiple formats:
- **CycloneDX JSON** - Industry standard format, preferred by Snyk
- **SPDX JSON** - Linux Foundation standard
- **Syft JSON** - Anchore's comprehensive format
- **Human-readable table** - For easy inspection

### Automated Security Scanning

The project includes automated security scanning via GitHub Actions:
- **Snyk dependency scanning** - Weekly vulnerability assessment
- **SBOM-based analysis** - Supply chain security validation
- **SARIF report generation** - Integrated with GitHub Security tab
- **cargo-audit** - Rust security advisory checks

### CI/CD Integration

The project uses a modern two-pipeline approach:

#### CI Pipeline (Pull Requests)
- **Fast feedback** for developers
- Code quality checks, tests, and build validation
- **No security scans** for speed
- Triggered on PR creation/updates

#### CD Pipeline (Continuous Delivery)
- **Comprehensive security validation** for production
- Includes all CI checks plus security audits
- **SBOM generation and analysis**
- Triggered on trunk pushes and scheduled runs

Both pipelines can be run locally:
```bash
make ci    # PR validation pipeline
make cd    # Full security validation pipeline
```

## License

GPL-3.0
