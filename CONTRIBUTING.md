# Contributing to adr-tools-alt

Thank you for your interest in contributing to adr-tools-alt! This document provides guidelines for contributing to the project.

## Development Setup

### Prerequisites
- Rust 1.70.0 or later
- Git

### Setup
1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/adr-tools-alt.git
   cd adr-tools-alt
   ```
3. Build the project:
   ```bash
   cargo build
   ```
4. Run tests:
   ```bash
   cargo test
   ```

## Development Workflow

### Before Making Changes
1. Create a new branch from `trunk`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. Make sure all tests pass:
   ```bash
   cargo test
   ```

### Code Quality
We maintain high code quality standards. Before submitting:

1. **Format your code:**
   ```bash
   cargo fmt
   ```

2. **Run clippy:**
   ```bash
   cargo clippy -- -D warnings
   ```

3. **Run all tests:**
   ```bash
   cargo test
   ```

4. **Check documentation:**
   ```bash
   cargo doc --no-deps
   ```

5. **Security scan (if Snyk CLI installed):**
   ```bash
   snyk test
   snyk code test
   ```

### Commit Guidelines
- Use conventional commit format: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Keep commits atomic and focused
- Write clear, descriptive commit messages

Examples:
```
feat(cli): add support for custom ADR templates
fix(config): handle missing .adr-dir file gracefully
docs(readme): update installation instructions
```

## Testing

### Unit Tests
Run unit tests with:
```bash
cargo test
```

### Integration Tests
Test the actual binary functionality:
```bash
cargo build --release
./target/release/adr-tools-alt init test-dir
./target/release/adr-tools-alt new "Test ADR"
./target/release/adr-tools-alt list
```

### Adding Tests
- Add unit tests for new functionality
- Test edge cases and error conditions
- Update existing tests when modifying behavior

### Code Coverage
Generate coverage reports with:
```bash
# Install cargo-llvm-cov (one time)
cargo install cargo-llvm-cov

# Generate coverage report
cargo llvm-cov --all-features --lcov --output-path lcov.info

# Or use the provided script
./scripts/coverage.sh
```

**Note:** Integration tests are excluded from coverage reports to avoid environment conflicts. Coverage focuses on unit tests of the core functionality.

## Pull Request Process

1. **Update documentation** if you've changed functionality
2. **Add tests** for new features
3. **Update CHANGELOG.md** with your changes
4. **Ensure all CI checks pass**
5. **Write a clear PR description** explaining:
   - What changes you made
   - Why you made them
   - How to test them

### PR Title Format
Use conventional commit format for PR titles:
```
feat: add support for custom templates
fix: resolve issue with Windows paths
docs: improve installation guide
```

## Code Guidelines

### Rust Style
- Follow the Rust API Guidelines
- Use `rustfmt` for consistent formatting
- Address all `clippy` warnings
- Prefer explicit error handling over panics
- Write clear, self-documenting code

### Architecture
- Keep modules focused and cohesive
- Minimize dependencies between modules
- Use appropriate error types
- Follow the existing code structure

### Documentation
- Document public APIs
- Include examples for complex functionality
- Update README.md for user-facing changes
- Add inline comments for complex logic

## Release Process

Releases are automated through GitHub Actions:

1. Update version in `Cargo.toml`
2. Update `CHANGELOG.md`
3. Create a tag: `git tag v0.1.1`
4. Push the tag: `git push origin v0.1.1`
5. GitHub Actions will build and publish the release

## Getting Help

- **Issues:** Check existing issues or create a new one
- **Discussions:** Use GitHub Discussions for questions
- **Code Review:** Maintainers will review PRs and provide feedback

## Code of Conduct

This project follows the [Rust Code of Conduct](https://www.rust-lang.org/policies/code-of-conduct).

## License

By contributing, you agree that your contributions will be licensed under the GPL-3.0 license.