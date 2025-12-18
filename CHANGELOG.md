# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial implementation of adr-tools-alt
- `adr init [directory]` command to initialize ADR directory
- `adr new <title>` command to create new ADRs
- `adr new <title> --supersede <number>` to supersede existing ADRs
- `adr list` command to list all ADRs
- `adr generate toc` command to generate table of contents
- Support for custom ADR directories via `.adr-dir` file
- Editor integration via VISUAL/EDITOR environment variables
- Automatic ADR numbering with 4-digit padding
- Filename slugification for ADR files
- CI/CD pipeline with GitHub Actions
- Cross-platform builds (Linux, macOS, Windows)
- Security auditing and dependency checking
- Code coverage reporting
- MSRV (Minimum Supported Rust Version) testing

### Fixed
- N/A

### Changed
- N/A

### Removed
- N/A

## [0.1.0] - 2025-12-18

### Added
- Initial release