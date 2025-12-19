# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is `adr-tools-alt`, a Rust implementation that replicates the functionality of the original [adr-tools](https://github.com/npryce/adr-tools) for managing Architecture Decision Records (ADRs).

## Development Commands

The project uses a comprehensive Makefile for development workflows:

```bash
# Setup development environment
make setup              # Install all dependencies and tools
make check-tools        # Check which tools are installed

# Build and development
make build              # Build the project  
make build-release      # Build release version
make clean              # Clean build artifacts
make install            # Install the binary locally

# Testing
make test               # Run all tests
make test-integration   # Run integration tests  
make test-watch         # Run tests in watch mode (requires cargo-watch)
make demo               # Run a quick demo of the tool

# Code quality
make format             # Format code with rustfmt
make format-check       # Check code formatting
make lint               # Run clippy lints
make check              # Run all code quality checks (format + lint)

# Documentation
make docs               # Generate documentation
make docs-open          # Generate and open documentation
make serve-docs         # Serve documentation locally

# Security and SBOM
make security           # Run comprehensive security scans
make sbom               # Generate Software Bill of Materials
make sbom-snyk          # Generate SBOM and upload to Snyk for scanning

# CI/CD and validation  
make validate-workflows # Validate GitHub Actions workflow files
make ci                 # Run CI pipeline (equivalent to GitHub Actions)
make all                # Run comprehensive build pipeline
make release-check      # Check if ready for release

# Development helpers
make watch              # Watch for changes and run tests
make env                # Show environment information
make run ARGS="--help"  # Run the application with arguments
```

### Legacy Scripts (Replaced by Makefile)

The following scripts have been replaced by Makefile targets:
- `scripts/coverage.sh` → `make coverage`
- `scripts/security-scan.sh` → `make security`
- `scripts/validate-workflows.sh` → `make validate-workflows`
- `scripts/generate-sbom.sh` → `make sbom`

## CLI Usage Examples

```bash
# Initialize ADR directory
cargo run -- init

# Create new ADR
cargo run -- new "Use database for persistence"

# List all ADRs
cargo run -- list

# Create ADR that supersedes another
cargo run -- new "Use PostgreSQL" --supersede 5

# Generate table of contents
cargo run -- generate toc
```

## Project Architecture

The project is structured as a CLI application with these main modules:

### `src/main.rs`
- Entry point with CLI definition using `clap`
- Command routing to appropriate functions

### `src/adr.rs`
- Core ADR functionality: `init()`, `new()`, `list()`, `generate()`
- File management and ADR operations
- Superseding logic

### `src/config.rs`
- Configuration management
- ADR directory detection and setup
- `.adr-dir` file handling

### `src/template.rs`
- ADR templates (default and init templates)
- Template variable substitution
- Filename generation and slugification

## Key Features Implemented

- ✅ ADR initialization with default template
- ✅ Automatic numbering (0001, 0002, etc.)
- ✅ Superseding existing ADRs
- ✅ Directory configuration via `.adr-dir` file
- ✅ Editor integration via VISUAL/EDITOR env vars
- ✅ Table of contents generation
- ✅ Proper filename slugification

## Testing

Run tests with `cargo test`. Tests cover:
- Filename parsing and generation
- Title slugification
- ADR file detection

## Dependencies

- `clap`: CLI argument parsing
- `chrono`: Date handling
- `anyhow`: Error handling
- `regex`: Pattern matching for filenames
- `serde`: Serialization (for future features)

## Security

This project integrates comprehensive security scanning:

### Automated Security (CI)
- **Snyk Integration**: Dependency and code vulnerability scanning
- **SBOM Generation**: Software Bill of Materials in multiple formats (CycloneDX, SPDX, Syft)
- **cargo-audit**: Rust security advisory database checking  
- **GitHub Security**: Results integrated into Security tab via SARIF uploads
- **Supply Chain Security**: SBOM-based vulnerability analysis

### SBOM (Software Bill of Materials)
The project generates comprehensive SBOM files for supply chain security:

```bash
# Generate all SBOM formats locally
./scripts/generate-sbom.sh

# Generate specific formats
./scripts/generate-sbom.sh --formats cyclonedx,spdx

# Generate and scan with Snyk
./scripts/generate-sbom.sh --snyk
```

**SBOM Formats Supported:**
- **CycloneDX JSON**: Industry standard, preferred by Snyk and most tools
- **SPDX JSON**: Linux Foundation standard for license compliance
- **Syft JSON**: Comprehensive format with detailed package information
- **Human-readable table**: For manual inspection and documentation

**Automated SBOM Generation:**
- GitHub Actions workflow generates SBOM on every commit
- Weekly scheduled SBOM scans with vulnerability assessment
- SBOM files attached to releases for distribution
- Quality validation ensures completeness and accuracy

### Local Security Testing
```bash
# Run all security scans
./scripts/security-scan.sh

# Individual tools
cargo audit                    # Dependency vulnerabilities
snyk test                     # Dependency scanning
snyk code test               # Static code analysis

# SBOM generation and scanning
./scripts/generate-sbom.sh --snyk   # Generate SBOM and scan with Snyk
```

### Security Configuration
- `.snyk` - Snyk policy and configuration
- Security thresholds: Medium+ for most scans
- Automatic security monitoring via Snyk dashboard
- Weekly automated security reviews

### Setup Requirements
1. Add `SNYK_TOKEN` to GitHub repository secrets
2. Optionally add `SNYK_ORG_ID` for organization scans  
3. See `.github/SNYK_SETUP.md` for detailed setup instructions

## License

GPL-3.0 - same as original adr-tools