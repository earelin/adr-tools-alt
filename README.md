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

This project includes a comprehensive Makefile for development workflows:

```bash
# Setup development environment  
make setup              # Install all dependencies and tools

# Build and test
make build              # Build the project
make test               # Run tests
make check              # Run code quality checks (format + lint)
make all                # Run comprehensive build pipeline

# Security and SBOM
make security           # Run comprehensive security scans
make sbom               # Generate Software Bill of Materials
make sbom-snyk          # Generate SBOM and upload to Snyk for scanning

# Development helpers
make demo               # Run a quick demo of the tool
make watch              # Watch for changes and run tests
make help               # Show all available targets
```

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

SBOM generation is integrated into the CI/CD pipeline:
- Automatic SBOM generation on pushes to main branch
- Weekly scheduled SBOM scans with Snyk
- SBOM artifacts stored with releases
- Quality validation and completeness checking

## License

GPL-3.0
