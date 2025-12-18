# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is `adr-tools-alt`, a Rust implementation that replicates the functionality of the original [adr-tools](https://github.com/npryce/adr-tools) for managing Architecture Decision Records (ADRs).

## Development Commands

```bash
# Build the project
cargo build

# Run tests
cargo test

# Run linting
cargo clippy

# Format code
cargo fmt

# Run the application
cargo run -- [command]

# Build release version
cargo build --release
```

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

## License

GPL-3.0 - same as original adr-tools