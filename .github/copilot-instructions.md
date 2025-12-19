# Copilot Instructions for adr-tools-alt

## Project Overview

This is a Rust CLI tool that replicates [adr-tools](https://github.com/npryce/adr-tools) for managing Architecture Decision Records (ADRs). The codebase is intentionally small and focused - four Rust modules totaling ~600 lines.

## Architecture

### Module Structure
- [src/main.rs](../src/main.rs): CLI definition using `clap` with derive macros
- [src/adr.rs](../src/adr.rs): Core operations (`init()`, `new()`, `list()`, `generate()`)
- [src/config.rs](../src/config.rs): `.adr-dir` file handling and directory resolution
- [src/template.rs](../src/template.rs): Markdown templates, date injection, and slug generation

### Key Patterns

**Configuration via `.adr-dir` file**: The tool reads from a `.adr-dir` file in the current directory to determine where ADRs are stored. If missing, defaults to `doc/adr/`. See [config.rs](../src/config.rs#L11-L21).

**Four-digit zero-padded numbering**: ADR files use `0001-title-slug.md` format. The `get_next_number()` function in [adr.rs](../src/adr.rs) parses all existing files via regex to determine the next number.

**Template substitution**: Templates use placeholder strings (`NUMBER`, `TITLE`, `DATE`, `STATUS`) replaced by `fill_template()` in [template.rs](../src/template.rs#L45-L53).

**Editor integration**: After creating an ADR, the tool attempts to open it in `$VISUAL` or `$EDITOR` if set. See [adr.rs](../src/adr.rs#L72-L75).

## Development Workflow

**Use the Makefile exclusively** - all legacy shell scripts in `scripts/legacy/` have been superseded:

```bash
make setup          # One-time: install rustfmt, clippy, cargo-llvm-cov, cargo-audit, syft
make test           # Run tests with --test-threads=1 (required for temp dir tests)
make check          # Run format-check + clippy with -D warnings
make coverage       # Generate coverage report with cargo-llvm-cov (requires llvm-tools-preview)
make security       # Run cargo-audit and Snyk scans
make sbom           # Generate CycloneDX, SPDX, and Syft SBOM files
```

**Testing conventions**:
- Unit tests in `src/**/*.rs` with `#[cfg(test)]` modules
- Integration tests in [tests/integration_test.rs](../tests/integration_test.rs) use `tempfile` crate and require `#![cfg(not(coverage))]` attribute to exclude from coverage (they test the compiled binary, not the code)
- Integration tests must run with `--test-threads=1` due to `chdir()` usage

**Code quality gates**:
- Clippy with `-D warnings` (treat all warnings as errors)
- Custom clippy thresholds in [clippy.toml](../clippy.toml): cognitive complexity ≤30, too-many-lines ≤100
- Rustfmt enforced in CI
- Documentation warnings (`RUSTDOCFLAGS="-D warnings"`) enforced for `cargo doc`

## Dependencies & Security

**Minimal dependency footprint**: Only 5 direct dependencies (`clap`, `chrono`, `serde`, `anyhow`, `regex`) - see [Cargo.toml](../Cargo.toml#L20-L24)

**Security scanning pipeline**:
- `cargo-audit` checks Rust advisory database
- Snyk scans dependencies and code (requires `SNYK_TOKEN` secret)
- Weekly automated SBOM generation via [.github/workflows/sbom.yml](../.github/workflows/sbom.yml)
- CI runs security scans on every push to `trunk`

**SBOM formats**: Project generates CycloneDX (preferred by Snyk), SPDX (Linux Foundation standard), Syft JSON, and human-readable table. Run `make sbom` locally or check [sbom-output/](../sbom-output/) for artifacts.

## CI/CD

**Branch model**: Uses `trunk` as the main branch (not `main` or `master`)

**GitHub Actions jobs**:
- `check`: formatting, clippy, doc generation
- `test`: unit + integration tests
- `security`: cargo-audit + Snyk scans
- `coverage`: cargo-llvm-cov with lcov upload
- `sbom`: weekly scheduled + on-release

**Making changes**:
1. Run `make check test` locally before pushing
2. Integration tests will fail in CI if you change command output format
3. Coverage runs separately from tests - exclude integration tests with `#![cfg(not(coverage))]`

## Common Tasks

**Adding a new command**: 
1. Add variant to `Commands` enum in [main.rs](../src/main.rs#L15-L31)
2. Implement function in [adr.rs](../src/adr.rs)
3. Match in `main()` to route to your function

**Changing ADR template**: Edit constants in [template.rs](../src/template.rs#L4-L42). Remember both `DEFAULT_TEMPLATE` and `INIT_TEMPLATE` exist.

**Adding dependencies**: Update [Cargo.toml](../Cargo.toml#L20), then run `make sbom` to regenerate SBOM files for security scanning.

## What NOT to Do

- Don't use `println!()` for errors - use `anyhow::Result` and `?` operator
- Don't create shell scripts - use Makefile targets instead
- Don't run `cargo test` without `--test-threads=1` (integration tests will flake)
- Don't bypass clippy warnings - fix them or add `#[allow(...)]` with justification
