# Migration from Scripts to Makefile

This document helps developers transition from the individual shell scripts to the new Makefile-based development workflow.

## Quick Reference

### Script to Makefile Command Mapping

| Old Script | New Makefile Target | Notes |
|------------|-------------------|-------|
| `./scripts/coverage.sh` | `make coverage` | Enhanced with HTML report generation |
| `./scripts/security-scan.sh` | `make security` | More comprehensive security checks |
| `./scripts/validate-workflows.sh` | `make validate-workflows` | Better validation and error reporting |
| `./scripts/generate-sbom.sh` | `make sbom` | Simplified interface, same functionality |
| `./scripts/generate-sbom.sh --snyk` | `make sbom-snyk` | Direct Snyk integration |

### Common Development Tasks

| Task | Old Way | New Way |
|------|---------|---------|
| Build project | `cargo build` | `make build` |
| Run tests | `cargo test` | `make test` |
| Format code | `cargo fmt` | `make format` |
| Run lints | `cargo clippy` | `make lint` |
| Full CI pipeline | Multiple commands | `make ci` |
| Setup environment | Manual installation | `make setup` |
| Generate coverage | `./scripts/coverage.sh` | `make coverage` |
| Security scan | `./scripts/security-scan.sh` | `make security` |
| SBOM generation | `./scripts/generate-sbom.sh` | `make sbom` |

## Benefits of the Makefile

### 1. **Simplified Interface**
- Single entry point for all development tasks
- Consistent command structure: `make <target>`
- Built-in help system: `make help`

### 2. **Better Error Handling**
- Proper exit codes for CI/CD integration
- Clear error messages with colored output
- Dependency checking for required tools

### 3. **Enhanced Features**
- Parallel execution support
- Conditional execution based on tool availability
- Comprehensive validation and reporting

### 4. **Cross-Platform Compatibility**
- Works on Linux, macOS, and Windows (with WSL/MinGW)
- Consistent behavior across different environments
- Automatic tool installation where possible

## Migration Steps

### For Developers

1. **Start using Makefile commands**:
   ```bash
   # Instead of: ./scripts/coverage.sh
   make coverage
   
   # Instead of: ./scripts/security-scan.sh  
   make security
   
   # Instead of: ./scripts/generate-sbom.sh --formats cyclonedx
   make sbom
   ```

2. **Setup your development environment**:
   ```bash
   make setup          # Install all required tools
   make check-tools    # Verify installation
   ```

3. **Use comprehensive targets for efficiency**:
   ```bash
   make all           # Build, test, lint, docs, coverage
   make ci            # Full CI pipeline
   make release-check # Pre-release validation
   ```

### For CI/CD

Update your automation scripts:

```bash
# Old workflow
./scripts/security-scan.sh
./scripts/validate-workflows.sh  
./scripts/coverage.sh

# New workflow
make ci  # Runs everything in the right order
```

### For Docker/Container Builds

Update Dockerfile commands:

```dockerfile
# Old approach
COPY scripts/ scripts/
RUN ./scripts/security-scan.sh

# New approach  
COPY Makefile .
RUN make security
```

## Backward Compatibility

### Scripts Are Still Available

The original scripts remain in the `scripts/` directory for backward compatibility:

- `scripts/coverage.sh` - Still functional
- `scripts/security-scan.sh` - Still functional  
- `scripts/validate-workflows.sh` - Still functional
- `scripts/generate-sbom.sh` - Still functional

### Gradual Migration

You can migrate gradually:

1. **Week 1**: Use Makefile for new tasks, keep scripts for existing automation
2. **Week 2**: Update local development to use Makefile targets
3. **Week 3**: Update CI/CD pipelines to use Makefile
4. **Week 4**: Consider deprecating script usage

## Advanced Usage

### Custom Arguments

```bash
# Run application with arguments
make run ARGS="init"
make run ARGS="new 'Sample ADR'"

# Custom output directories
make sbom  # Uses default: sbom-output/
```

### Parallel Execution

```bash
# Run multiple independent tasks
make build test docs &  # Background execution
make clean build       # Sequential execution
```

### Development Workflow

```bash
# Start development session
make setup              # One-time setup
make watch              # Continuous testing
```

## Troubleshooting

### Common Issues

1. **"make: command not found"**
   ```bash
   # Install make
   sudo apt-get install make  # Ubuntu/Debian
   brew install make         # macOS
   ```

2. **"No rule to make target"**
   ```bash
   # Check available targets
   make help
   ```

3. **Tool not found errors**
   ```bash
   # Install missing tools
   make setup
   make check-tools
   ```

### Getting Help

```bash
make help              # Show all available targets
make env               # Show environment information
make check-tools       # Check tool installation status
```

## FAQ

### Q: Can I still use the original scripts?
**A**: Yes, the scripts are still available for backward compatibility.

### Q: What if I prefer the script interface?
**A**: The scripts remain functional, but the Makefile provides better integration and error handling.

### Q: Are there any breaking changes?
**A**: No, the Makefile adds functionality without breaking existing workflows.

### Q: How do I customize the Makefile?
**A**: You can modify the variables at the top of the Makefile or create local overrides.

### Q: What about Windows support?
**A**: The Makefile works on Windows with WSL, MinGW, or Git Bash.

## Next Steps

1. **Try the Makefile**: Start with `make help` and `make demo`
2. **Update your workflow**: Gradually replace script usage with Makefile targets
3. **Provide feedback**: Report any issues or suggestions for improvement
4. **Share knowledge**: Help other team members migrate to the new system

The Makefile represents a significant improvement in developer experience while maintaining full backward compatibility with existing workflows.