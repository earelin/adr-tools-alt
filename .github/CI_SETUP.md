# CI/CD Setup for adr-tools-alt

This document describes the comprehensive CI/CD pipeline implemented for the adr-tools-alt project.

## Workflows Overview

### 1. Main CI Pipeline (`.github/workflows/ci.yml`)

**Triggers:** 
- Push to `trunk` branch
- Pull requests targeting `trunk`

**Jobs:**

#### Check Job
- Code formatting validation (`cargo fmt --check`)
- Clippy linting with warnings as errors
- Documentation generation check

#### Test Job  
- Unit tests with full workspace coverage
- Integration tests using actual binary
- Single-threaded execution to prevent test interference

#### Security Job
- Dependency vulnerability scanning with `cargo-audit`
- Automated security issue detection

#### Build Job
- Multi-platform builds (Linux, macOS, Windows)
- Cross-compilation for x86_64 targets
- Binary functionality verification
- Build artifact uploads

#### Coverage Job
- Code coverage generation with `cargo-llvm-cov`
- Codecov integration for coverage reporting

#### MSRV Job
- Minimum Supported Rust Version (1.70.0) compatibility check

#### Release Dry Run
- Test release workflow on PRs
- Validates release process without publishing

### 2. Release Pipeline (`.github/workflows/release.yml`)

**Triggers:** 
- Git tags matching `v*` pattern

**Jobs:**

#### Create Release
- Automatic GitHub release creation
- Release notes generation
- Asset upload preparation

#### Build Release
- Multi-platform release builds including:
  - Linux x86_64 (glibc)
  - Linux x86_64 (musl)
  - Windows x86_64
  - macOS x86_64
  - macOS ARM64
- Binary compression and packaging
- Asset upload to GitHub releases

#### Publish Crate
- Automated publishing to crates.io
- Requires `CARGO_REGISTRY_TOKEN` secret

### 3. Dependency Management (`.github/workflows/dependencies.yml`)

**Triggers:** 
- Weekly schedule (Sundays at 12:00 UTC)
- Manual trigger

**Jobs:**

#### Security Audit
- Weekly vulnerability scanning
- Automated issue creation on failures

#### Outdated Dependencies
- Detection of outdated dependencies
- Automated issue creation for maintenance

### 4. Performance Benchmarking (`.github/workflows/benchmark.yml`)

**Triggers:** 
- Push to `trunk` branch  
- Pull requests targeting `trunk`

**Jobs:**

#### Benchmark
- Performance testing with large ADR repositories
- Binary size tracking
- Performance regression detection

### 5. Snyk Security Scanning (`.github/workflows/snyk.yml`)

**Triggers:**
- Push to `trunk` branch
- Pull requests targeting `trunk`  
- Weekly schedule (Mondays at 08:00 UTC)

**Jobs:**

#### Snyk Open Source
- Dependency vulnerability scanning
- Cargo.toml and Cargo.lock analysis
- SARIF results upload to GitHub Security

#### Snyk Code Analysis
- Static code security analysis
- Rust-specific security pattern detection
- Security hotspot identification

#### Dependency Submission
- GitHub dependency graph submission
- Automated dependency review on PRs

## Configuration Files

### Rust Toolchain Configuration

#### `.rustfmt.toml`
- Stable-only formatting rules
- 100-character line width
- Consistent import ordering
- Unix line endings

#### `clippy.toml`
- Cognitive complexity threshold: 30
- Type complexity threshold: 250
- Custom lint configurations
- Documentation requirements

### Integration Tests

#### `tests/integration_test.rs`
- End-to-end binary testing
- Isolated temporary directory execution
- Full workflow validation including:
  - ADR initialization
  - ADR creation
  - Superseding functionality
  - Listing and TOC generation

## Security Features

- **Dependency Auditing:** Weekly automated scans with cargo-audit
- **Snyk Vulnerability Scanning:** Comprehensive dependency and code analysis
- **GitHub Security Integration:** Results in Security tab and Code Scanning alerts
- **SARIF Upload:** Standardized security result format
- **MSRV Enforcement:** Ensures compatibility with Rust 1.70.0+
- **Cargo.lock Validation:** Dependency integrity checks
- **Supply Chain Security:** Multi-platform build verification
- **Automated Security Monitoring:** Continuous monitoring via Snyk dashboard

## Quality Gates

All PRs must pass:
1. ✅ Code formatting check
2. ✅ Clippy linting (warnings as errors)
3. ✅ Unit tests (100% pass rate)
4. ✅ Integration tests (100% pass rate)
5. ✅ Multi-platform builds
6. ✅ Documentation generation
7. ✅ Security audit
8. ✅ MSRV compatibility

## Secrets Required

For full functionality, the following GitHub secrets must be configured:

### Required Secrets
- `CARGO_REGISTRY_TOKEN`: For crates.io publishing
- `SNYK_TOKEN`: For Snyk security scanning

### Optional Secrets
- `CODECOV_TOKEN`: For code coverage reporting
- `SNYK_ORG_ID`: For organization-specific Snyk scans

### Setup Instructions

1. **SNYK_TOKEN**: 
   - Create account at [snyk.io](https://snyk.io)
   - Go to Account Settings → API Token
   - Copy token to GitHub Secrets

2. **SNYK_ORG_ID** (Optional):
   - Find in Snyk dashboard URL or settings
   - Allows organization-specific scanning and monitoring

## Performance Optimizations

- **Rust Cache:** Aggressive caching with `Swatinem/rust-cache`
- **Parallel Builds:** Multi-platform builds run concurrently
- **Incremental Compilation:** Cache-friendly build configuration
- **Artifact Reuse:** Build once, test multiple times

## Maintenance

- **Automated Updates:** Dependabot configuration for dependency updates
- **Weekly Audits:** Automatic security scanning
- **Performance Tracking:** Continuous benchmark monitoring
- **Documentation:** Auto-generated docs on docs.rs

This CI/CD setup ensures high code quality, security, and reliability for the adr-tools-alt project while providing comprehensive automation for development and release processes.