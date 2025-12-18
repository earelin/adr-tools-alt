# adr-tools-alt

Alternative tools for managing a repository of Architecture Decision Records (ADRs), written in Rust.

This is a Rust implementation that mimics the behavior of [adr-tools](https://github.com/npryce/adr-tools), providing a fast and reliable way to manage Architecture Decision Records.

## Installation

```bash
cargo install adr-tools-alt
```

Or build from source:

```bash
git clone https://github.com/earelin/adr-tools-alt
cd adr-tools-alt
cargo build --release
```

## Usage

### Initialize ADR directory

```bash
adr init [directory]
```

Creates a new ADR directory (default: `doc/adr`) and adds the first ADR documenting the decision to use ADRs.

### Create a new ADR

```bash
adr new "Title of the decision"
```

Creates a new numbered ADR file with the given title.

### Supersede an existing ADR

```bash
adr new "New decision" --supersede 5
```

Creates a new ADR and marks ADR #5 as superseded.

### List all ADRs

```bash
adr list
```

Lists all existing ADRs with their titles.

### Generate documentation

```bash
adr generate toc
```

Generates a table of contents for all ADRs in Markdown format.

## Features

- ✅ Initialize ADR directory structure
- ✅ Create new ADRs with automatic numbering
- ✅ Supersede existing ADRs
- ✅ List all ADRs
- ✅ Generate table of contents
- ✅ Configurable ADR directory
- ✅ Auto-open ADRs in editor (via VISUAL/EDITOR env vars)
- ✅ Proper filename slugification

## ADR Template

ADRs follow the standard format:

```markdown
# NUMBER. Title

Date: YYYY-MM-DD

## Status

Accepted

## Context

The issue motivating this decision...

## Decision

The change that we're proposing...

## Consequences

What becomes easier or more difficult...
```

## License

GPL-3.0
