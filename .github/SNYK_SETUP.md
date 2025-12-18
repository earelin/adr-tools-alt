# Snyk Security Integration

This document describes the Snyk security integration for the adr-tools-alt project, providing comprehensive vulnerability scanning for dependencies and code.

## Overview

Snyk is integrated into our CI/CD pipeline to provide:
- **Open Source Security**: Dependency vulnerability scanning
- **Code Analysis**: Static code analysis for security issues
- **GitHub Security Integration**: Results appear in GitHub Security tab
- **Automated Monitoring**: Continuous monitoring of the project

## Setup Requirements

### 1. Snyk Account & Token

1. **Create a Snyk Account**:
   - Go to [snyk.io](https://snyk.io) and create an account
   - Connect it to your GitHub account for seamless integration

2. **Generate API Token**:
   - Go to Account Settings → API Token
   - Generate a new token and copy it

3. **Add GitHub Secrets**:
   - Add `SNYK_TOKEN` in Repository Settings → Secrets and Variables → Actions
   - Optionally add `SNYK_ORG_ID` for organization-specific scans

### 2. GitHub Permissions

Ensure your GitHub repository has:
- **Security Events**: Write permissions for uploading security results
- **Actions**: Read/Write permissions for running workflows
- **Code Scanning**: Enabled in repository settings

## Workflow Configuration

### Automatic Scans

The Snyk integration runs automatically on:
- **Pull Requests**: Security checks on new code
- **Push to trunk**: Full security scan and monitoring
- **Weekly Schedule**: Comprehensive security review (Mondays 8:00 UTC)

### Scan Types

#### 1. Open Source Vulnerability Scanning
```yaml
# Scans Cargo.toml and Cargo.lock for vulnerable dependencies
snyk test --severity-threshold=medium
```

**What it checks**:
- Direct dependencies in `Cargo.toml`
- Transitive dependencies in `Cargo.lock`
- Known vulnerabilities in the Snyk database
- License compliance issues

#### 2. Code Analysis
```yaml
# Static analysis of Rust source code
snyk code test --severity-threshold=medium
```

**What it checks**:
- Security anti-patterns in Rust code
- Potential injection vulnerabilities
- Insecure cryptographic usage
- Memory safety issues specific to Rust

#### 3. Dependency Monitoring
```yaml
# Continuous monitoring in Snyk dashboard
snyk monitor --project-name=adr-tools-alt
```

**Features**:
- Ongoing vulnerability monitoring
- Automated alerts for new vulnerabilities
- Project dashboard in Snyk web interface
- Integration with GitHub Security advisories

## Configuration Files

### `.snyk` Policy File

The `.snyk` file controls scan behavior:

```yaml
# Severity thresholds
severity-threshold:
  oss: high        # Fail on high/critical dependency vulnerabilities
  code: high       # Fail on high/critical code issues
  container: medium # More sensitive for container scans
```

### Exclusions

Automatically excludes:
- Build artifacts (`target/`, `.cargo/`)
- Test files (`tests/`, `**/tests/`)
- Documentation (`*.md`, `docs/`, `examples/`)
- Development tools (`.github/`, `scripts/`)

### Language Settings

Configured for Rust:
- Package manager: Cargo
- Exclude dev dependencies in production scans
- Rust-specific security rules enabled

## Local Development

### Install Snyk CLI

```bash
# Via npm (requires Node.js)
npm install -g snyk

# Via Homebrew (macOS)
brew install snyk

# Via curl (Linux/macOS)
curl https://static.snyk.io/cli/latest/snyk-linux -o snyk
chmod +x snyk
sudo mv snyk /usr/local/bin/
```

### Local Commands

```bash
# Authenticate with Snyk
snyk auth

# Test current project
snyk test

# Test with custom severity
snyk test --severity-threshold=high

# Code analysis
snyk code test

# Monitor project (sends data to Snyk)
snyk monitor
```

### IDE Integration

Snyk provides plugins for:
- **VS Code**: Snyk Security extension
- **IntelliJ/CLion**: Snyk Security plugin
- **Vim/Neovim**: Available through various plugins

## Security Results

### GitHub Security Tab

Results automatically appear in:
- Repository → Security → Code scanning alerts
- Repository → Security → Dependabot alerts (for dependencies)
- Pull Request → Security tab

### Result Types

#### Open Source Vulnerabilities
- **CVE Information**: Detailed vulnerability descriptions
- **CVSS Scores**: Severity ratings
- **Fix Recommendations**: Upgrade paths and patches
- **License Issues**: License compliance warnings

#### Code Analysis Issues
- **Security Hotspots**: Potentially vulnerable code patterns
- **Best Practice Violations**: Rust-specific security recommendations
- **Fix Suggestions**: Code improvement recommendations

## Thresholds & Policies

### Current Configuration

| Scan Type | Threshold | Action |
|-----------|-----------|---------|
| Dependencies | Medium+ | Fail CI |
| Code Analysis | Medium+ | Fail CI |
| Weekly Scan | Low+ | Report only |

### Customizing Thresholds

Edit `.snyk` file to adjust:
```yaml
severity-threshold:
  oss: critical    # Only fail on critical issues
  code: medium     # Fail on medium and above
```

## Troubleshooting

### Common Issues

#### 1. Missing SNYK_TOKEN
```
Error: Missing snyk token
```
**Solution**: Add `SNYK_TOKEN` to GitHub repository secrets

#### 2. Authentication Failed
```
Error: Authentication failed
```
**Solution**: Regenerate token in Snyk dashboard and update secret

#### 3. No Results Uploaded
```
Warning: No SARIF file found
```
**Solution**: Check if Snyk found any issues; empty results are normal

### Debug Commands

```bash
# Verbose output
snyk test --debug

# Check authentication
snyk config get api

# Test specific file
snyk test --file=Cargo.toml

# Generate SARIF locally
snyk test --sarif-file-output=results.sarif
```

## Best Practices

### 1. Regular Updates
- Keep dependencies updated with `cargo update`
- Review Snyk alerts promptly
- Update `Cargo.lock` regularly

### 2. Vulnerability Management
- Don't ignore vulnerabilities without good reason
- Document exceptions in `.snyk` with expiry dates
- Monitor for updates to ignored vulnerabilities

### 3. CI Integration
- Don't skip security checks in CI
- Review security results before merging PRs
- Use fail-fast approach for critical vulnerabilities

### 4. Development Workflow
- Run `snyk test` before committing
- Use IDE integration for real-time feedback
- Address security issues during development, not after

## Support & Resources

- **Snyk Documentation**: [docs.snyk.io](https://docs.snyk.io)
- **Rust Security**: [security.rust-lang.org](https://security.rust-lang.org)
- **GitHub Security**: [docs.github.com/security](https://docs.github.com/en/code-security)
- **Snyk Community**: [community.snyk.io](https://community.snyk.io)

## License & Privacy

Snyk may collect:
- Dependency information (package names, versions)
- Vulnerability scan results
- Basic project metadata

See [Snyk Privacy Policy](https://snyk.io/privacy/) for details.