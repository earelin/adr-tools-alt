# Legacy Workflows

## ⚠️ Pipeline Reorganization Notice

**These workflows have been replaced by the new CI/CD pipeline structure.**

### New Pipeline Organization

The security and SBOM workflows previously in this directory have been integrated into the main CI/CD pipelines:

#### CI Pipeline (`ci.yml`)
- **Triggers**: Pull request creation and updates
- **Purpose**: Fast feedback for code quality and functionality
- **Includes**:
  - Code quality checks (formatting, linting)
  - Test execution (unit + integration)
  - Build matrix validation
  - Code coverage analysis
  - MSRV compatibility
  - Workflow validation
- **Excludes**: Security scans (for faster PR feedback)

#### CD Pipeline (`cd.yml`)
- **Triggers**: Push to trunk branch, scheduled runs, manual dispatch
- **Purpose**: Comprehensive security validation and delivery preparation
- **Includes**:
  - Build validation
  - **Complete security audit** (cargo-audit + Snyk)
  - **SBOM generation and analysis** (CycloneDX, SPDX, Syft)
  - **Advanced security checks** (secret scanning, compliance)
  - Supply chain security validation
  - Documentation generation
  - Release readiness validation

### Migration Details

| **Legacy Workflow** | **Replaced By** | **New Location** |
|---------------------|-----------------|------------------|
| `snyk.yml` | CD Pipeline | `.github/workflows/cd.yml` (security-audit job) |
| `sbom.yml` | CD Pipeline | `.github/workflows/cd.yml` (sbom-security job) |
| `snyk.yml.backup` | *(deprecated)* | *(removed)* |

### Benefits of New Structure

1. **Faster PR Feedback**: CI pipeline excludes heavy security scans for quicker developer feedback
2. **Comprehensive Security**: CD pipeline includes all security validations in one place
3. **Better Organization**: Clear separation between continuous integration and continuous delivery
4. **Reduced Duplication**: Security logic consolidated rather than spread across multiple workflows
5. **Enhanced Reporting**: Comprehensive dashboards and summaries for each pipeline stage

### Security Scanning Schedule

- **PR Reviews**: Basic validation only (no security scans for speed)
- **Trunk Pushes**: Full security validation including SBOM generation
- **Scheduled**: Weekly comprehensive security scans (Mondays 08:00 UTC)
- **Manual**: On-demand security validation via workflow dispatch

### Accessing Security Results

Security scan results are available in multiple locations:

1. **GitHub Security Tab**: SARIF reports uploaded automatically
2. **Snyk Dashboard**: Direct integration for vulnerability tracking
3. **GitHub Actions**: Detailed job logs and summaries
4. **Artifacts**: SBOM files and reports stored as artifacts

### For Developers

#### Pull Request Workflow
```bash
# Fast feedback without security scans
git push origin feature-branch
# Creates PR → Triggers ci.yml → Quick validation
```

#### Main Branch Workflow
```bash
# Comprehensive security validation
git push origin trunk
# Triggers cd.yml → Full security audit + SBOM generation
```

#### Manual Security Check
```bash
# Via GitHub UI: Actions → CD Pipeline → Run workflow
# Or via GitHub CLI:
gh workflow run cd.yml --ref trunk -f force_security_scan=true
```

### Legacy Workflow Preservation

These legacy workflows are preserved for:
- **Reference**: Understanding the previous implementation
- **Emergency Use**: Temporary fallback if needed during transition
- **Documentation**: Historical record of security scanning evolution

### Next Steps

1. **Update Local Scripts**: Use `make security` and `make sbom` instead of calling workflows directly
2. **Update Documentation**: Reference new CI/CD structure in project docs
3. **Monitor Transition**: Ensure new pipelines provide equivalent or better security coverage
4. **Clean Up**: Legacy workflows can be removed after successful transition period

For questions about the new pipeline structure, see:
- [CI/CD Documentation](../../README.md#cicd-integration)
- [Security Documentation](../../SECURITY.md)
- [Makefile Migration Guide](../MAKEFILE_MIGRATION.md)