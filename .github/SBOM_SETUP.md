# SBOM Generation Setup for adr-tools-alt

This document provides a quick reference for Software Bill of Materials (SBOM) generation and security scanning integration.

## Overview

The project now includes comprehensive SBOM generation capabilities integrated with Snyk security scanning:

- **Automated SBOM generation** via GitHub Actions
- **Multiple SBOM formats** (CycloneDX, SPDX, Syft)
- **Snyk integration** for vulnerability scanning
- **Local development script** for manual generation
- **CI/CD pipeline integration** with artifact storage

## Quick Start

### Generate SBOM Locally

```bash
# Generate all SBOM formats
./scripts/generate-sbom.sh

# Generate specific format only
./scripts/generate-sbom.sh --formats cyclonedx

# Generate and upload to Snyk (requires SNYK_TOKEN)
export SNYK_TOKEN="your-token-here"
./scripts/generate-sbom.sh --snyk
```

### CI/CD Integration

The SBOM generation is automatically triggered:
- **On every push** to trunk branch
- **On pull requests** for validation
- **Weekly schedule** (Sundays) for fresh analysis
- **Manual workflow dispatch** when needed

## File Structure

```
.github/workflows/
├── sbom.yml          # Main SBOM generation workflow
└── snyk.yml          # Enhanced Snyk security scanning

scripts/
└── generate-sbom.sh  # Local SBOM generation script

sbom-output/          # Default local output directory
├── sbom-cyclonedx.json
├── sbom-spdx.json
├── sbom-syft.json
├── sbom-table.txt
└── sbom-summary.md
```

## SBOM Formats

| Format | Description | Use Case | Tool |
|--------|-------------|----------|------|
| CycloneDX | Industry standard JSON format | Snyk scanning, compliance | cargo-cyclonedx |
| SPDX | Linux Foundation standard | License compliance, governance | syft |
| Syft JSON | Comprehensive package details | Deep analysis, custom tools | syft |
| Table | Human-readable text format | Manual inspection, docs | syft |

## Security Integration

### Snyk Scanning

The SBOM files are automatically scanned by Snyk for:
- **Dependency vulnerabilities**
- **License compliance issues**
- **Supply chain security risks**
- **Outdated package detection**

### GitHub Security Tab

Results are uploaded as SARIF files to GitHub's Security tab for:
- **Centralized vulnerability tracking**
- **Pull request security checks**
- **Security advisory notifications**
- **Compliance reporting**

## Setup Requirements

### For Local Development

1. **Install dependencies:**
   ```bash
   cargo install cargo-cyclonedx
   curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
   ```

2. **Install Snyk CLI** (optional, for scanning):
   ```bash
   npm install -g snyk
   # or use other installation methods from https://docs.snyk.io/snyk-cli/install-the-snyk-cli
   ```

3. **Configure Snyk token** (for scanning):
   ```bash
   export SNYK_TOKEN="your-snyk-token"
   # or add to your shell profile
   ```

### For GitHub Actions

1. **Add repository secrets:**
   - `SNYK_TOKEN`: Your Snyk API token
   - `SNYK_ORG_ID`: (Optional) Your Snyk organization ID

2. **Workflows are automatically enabled** - no additional setup needed

## Usage Examples

### Local Development

```bash
# Quick SBOM generation for development
./scripts/generate-sbom.sh --formats cyclonedx --output ./tmp

# Full analysis with Snyk scanning
./scripts/generate-sbom.sh --snyk --verbose

# Custom output location
./scripts/generate-sbom.sh --output /path/to/security-reports
```

### CI/CD Scenarios

```yaml
# Manually trigger SBOM generation with Snyk upload
workflow_dispatch:
  inputs:
    upload_to_snyk: true

# Schedule weekly comprehensive scan
schedule:
  - cron: '0 2 * * 0'  # Sundays at 2 AM UTC
```

## Troubleshooting

### Common Issues

1. **Missing dependencies:**
   - Install cargo-cyclonedx: `cargo install cargo-cyclonedx`
   - Install syft: Use the installation script provided

2. **Snyk token issues:**
   - Verify token is set: `echo $SNYK_TOKEN`
   - Check token permissions in Snyk dashboard

3. **Build failures:**
   - Ensure project builds successfully: `cargo build --release`
   - Check Rust toolchain version: `rustc --version`

### Debug Mode

Enable verbose output for troubleshooting:

```bash
./scripts/generate-sbom.sh --verbose
```

## Benefits

- **Supply Chain Security**: Comprehensive visibility into all dependencies
- **Vulnerability Tracking**: Automated scanning and alerting
- **Compliance**: License compliance checking and reporting  
- **Release Artifacts**: SBOM files included in releases
- **Integration**: Seamless integration with existing security tools

## Related Documentation

- [Snyk Setup Guide](.github/SNYK_SETUP.md)
- [Security Scanning Overview](.github/workflows/snyk.yml)
- [Project Security Policy](SECURITY.md)
- [Contributing Guidelines](CONTRIBUTING.md)