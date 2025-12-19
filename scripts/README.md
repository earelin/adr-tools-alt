# Scripts Directory

## ⚠️ Migration Notice

**The shell scripts in this project have been replaced by a comprehensive Makefile.**

### Quick Migration Guide

Instead of using individual scripts, use these Makefile targets:

```bash
# Old way                    →  # New way
./scripts/legacy/coverage.sh →  make coverage
./scripts/legacy/security-scan.sh →  make security  
./scripts/legacy/validate-workflows.sh →  make validate-workflows
./scripts/legacy/generate-sbom.sh →  make sbom
./scripts/legacy/generate-sbom.sh --snyk →  make sbom-snyk
```

### Why the Migration?

1. **Better Integration**: Single entry point for all development tasks
2. **Improved Error Handling**: Proper exit codes and clear error messages  
3. **Enhanced Features**: Colored output, dependency checking, parallel execution
4. **Simplified Interface**: Consistent `make <target>` commands with built-in help

### Getting Started

```bash
make help               # Show all available targets
make setup              # Install development dependencies
make all                # Run comprehensive build pipeline
make demo               # Try a quick demo
```

### Full Documentation

- [Makefile Migration Guide](../.github/MAKEFILE_MIGRATION.md) - Complete migration documentation
- [Project README](../README.md) - Updated development commands
- [Development Guide](../CLAUDE.md) - Enhanced development workflows

## Legacy Scripts

The original scripts are preserved in the `legacy/` subdirectory for backward compatibility:

- `legacy/coverage.sh` - Generate test coverage reports
- `legacy/security-scan.sh` - Run comprehensive security scans  
- `legacy/validate-workflows.sh` - Validate GitHub Actions workflows
- `legacy/generate-sbom.sh` - Generate Software Bill of Materials

### Deprecation Timeline

- **Current**: Scripts moved to legacy/, Makefile is the preferred method
- **Next Release**: Legacy scripts marked as deprecated
- **Future Release**: Legacy scripts may be removed

### Support

If you encounter issues with the Makefile migration:

1. Check the [migration guide](../.github/MAKEFILE_MIGRATION.md)
2. Run `make env` to verify your development environment
3. Use `make check-tools` to ensure all required tools are installed
4. Temporarily use legacy scripts if needed while transitioning

The Makefile provides a superior development experience while maintaining full feature parity with the original scripts.