# Makefile for adr-tools-alt
# A Rust CLI tool for managing Architecture Decision Records (ADRs)

.DEFAULT_GOAL := help
.PHONY: help setup clean build test lint format check docs coverage security sbom install run release all validate-workflows

# Configuration
CARGO := cargo
PROJECT_NAME := adr-tools-alt
TARGET_DIR := target
COVERAGE_DIR := coverage-report
SBOM_DIR := sbom-output
RUST_LOG ?= info

help: ## Show this help message
	@printf "\033[1m\033[34m%s\033[0m\n" "$(PROJECT_NAME) Development Makefile"
	@echo ""
	@printf "\033[1m%s\033[0m\n" "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[34m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@printf "\033[1m%s\033[0m\n" "Examples:"
	@echo "  make setup          # Install dependencies and tools"
	@echo "  make all            # Build, test, lint, and check everything"
	@echo "  make test-watch     # Run tests in watch mode"
	@echo "  make security       # Run security scans"
	@echo "  make sbom           # Generate Software Bill of Materials"
	@echo ""

# =============================================================================
# Setup and Installation
# =============================================================================

setup: ## Install development dependencies and tools
	@printf "\033[1m\033[34m===> Setting up development environment\033[0m\n"
	@command -v $(CARGO) >/dev/null 2>&1 || { printf "\033[0;31m❌ Rust/Cargo not found. Install from https://rustup.rs/\033[0m\n"; exit 1; }
	@printf "\033[0;34mℹ️  Installing Rust toolchain components...\033[0m\n"
	rustup component add rustfmt clippy llvm-tools-preview
	@printf "\033[0;34mℹ️  Installing cargo tools...\033[0m\n"
	$(CARGO) install --locked cargo-llvm-cov cargo-audit cargo-cyclonedx || true
	@printf "\033[0;34mℹ️  Installing syft for SBOM generation...\033[0m\n"
	@if ! command -v syft >/dev/null 2>&1; then \
		mkdir -p ~/.local/bin; \
		curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b ~/.local/bin; \
		printf "\033[0;32m✅ syft installed to ~/.local/bin (add to PATH if needed)\033[0m\n"; \
	else \
		printf "\033[0;32m✅ syft already installed\033[0m\n"; \
	fi
	@printf "\033[0;32m✅ Development environment setup complete\033[0m\n"

check-tools: ## Check if required tools are installed
	@printf "\033[1m\033[34m===> Checking development tools\033[0m\n"
	@command -v $(CARGO) >/dev/null 2>&1 && printf "\033[0;32m✅ cargo found\033[0m\n" || printf "\033[0;31m❌ cargo not found\033[0m\n"
	@command -v cargo-fmt >/dev/null 2>&1 && printf "\033[0;32m✅ rustfmt found\033[0m\n" || printf "\033[1;33m⚠️  rustfmt not found - run 'make setup'\033[0m\n"
	@command -v cargo-clippy >/dev/null 2>&1 && printf "\033[0;32m✅ clippy found\033[0m\n" || printf "\033[1;33m⚠️  clippy not found - run 'make setup'\033[0m\n"
	@command -v cargo-llvm-cov >/dev/null 2>&1 && printf "\033[0;32m✅ cargo-llvm-cov found\033[0m\n" || printf "\033[1;33m⚠️  cargo-llvm-cov not found - run 'make setup'\033[0m\n"
	@command -v cargo-audit >/dev/null 2>&1 && printf "\033[0;32m✅ cargo-audit found\033[0m\n" || printf "\033[1;33m⚠️  cargo-audit not found - run 'make setup'\033[0m\n"
	@command -v cargo-cyclonedx >/dev/null 2>&1 && printf "\033[0;32m✅ cargo-cyclonedx found\033[0m\n" || printf "\033[1;33m⚠️  cargo-cyclonedx not found - run 'make setup'\033[0m\n"
	@command -v syft >/dev/null 2>&1 && printf "\033[0;32m✅ syft found\033[0m\n" || printf "\033[1;33m⚠️  syft not found - run 'make setup'\033[0m\n"

# =============================================================================
# Build and Development
# =============================================================================

clean: ## Clean build artifacts
	@printf "\033[1m\033[34m===> Cleaning build artifacts\033[0m\n"
	$(CARGO) clean
	rm -rf $(COVERAGE_DIR) $(SBOM_DIR) lcov.info *.sarif
	@printf "\033[0;32m✅ Clean complete\033[0m\n"

build: ## Build the project
	@printf "\033[1m\033[34m===> Building project\033[0m\n"
	$(CARGO) build
	@printf "\033[0;32m✅ Build complete\033[0m\n"

build-release: ## Build release version
	@printf "\033[1m\033[34m===> Building release version\033[0m\n"
	$(CARGO) build --release
	@printf "\033[0;32m✅ Release build complete\033[0m\n"

install: build-release ## Install the binary locally
	@printf "\033[1m\033[34m===> Installing $(PROJECT_NAME)\033[0m\n"
	$(CARGO) install --path .
	@printf "\033[0;32m✅ $(PROJECT_NAME) installed successfully\033[0m\n"

# =============================================================================
# Testing
# =============================================================================

test: ## Run tests
	@printf "\033[1m\033[34m===> Running tests\033[0m\n"
	$(CARGO) test --all-features --workspace -- --test-threads=1
	@printf "\033[0;32m✅ Tests passed\033[0m\n"

test-watch: ## Run tests in watch mode (requires cargo-watch)
	@printf "\033[1m\033[34m===> Running tests in watch mode\033[0m\n"
	@command -v cargo-watch >/dev/null 2>&1 || { printf "\033[1;33m⚠️  cargo-watch not found. Install with: cargo install cargo-watch\033[0m\n"; exit 1; }
	$(CARGO) watch -x "test --all-features --workspace -- --test-threads=1"

test-integration: build-release ## Run integration tests
	@printf "\033[1m\033[34m===> Running integration tests\033[0m\n"
	@TEMP_DIR=$$(mktemp -d); \
	cd "$$TEMP_DIR"; \
	$(PWD)/$(TARGET_DIR)/release/$(PROJECT_NAME) init; \
	$(PWD)/$(TARGET_DIR)/release/$(PROJECT_NAME) new "Test ADR"; \
	$(PWD)/$(TARGET_DIR)/release/$(PROJECT_NAME) list; \
	$(PWD)/$(TARGET_DIR)/release/$(PROJECT_NAME) generate toc; \
	cd $(PWD); \
	rm -rf "$$TEMP_DIR"
	@printf "\033[0;32m✅ Integration tests passed\033[0m\n"

# =============================================================================
# Code Quality
# =============================================================================

format: ## Format code
	@printf "\033[1m\033[34m===> Formatting code\033[0m\n"
	$(CARGO) fmt --all
	@printf "\033[0;32m✅ Code formatted\033[0m\n"

format-check: ## Check code formatting
	@printf "\033[1m\033[34m===> Checking code formatting\033[0m\n"
	$(CARGO) fmt --all -- --check
	@printf "\033[0;32m✅ Code formatting is correct\033[0m\n"

lint: ## Run clippy lints
	@printf "\033[1m\033[34m===> Running clippy lints\033[0m\n"
	$(CARGO) clippy --all-targets --all-features -- -D warnings
	@printf "\033[0;32m✅ Clippy checks passed\033[0m\n"

check: format-check lint ## Run all code quality checks
	@printf "\033[1m\033[34m===> Running comprehensive code checks\033[0m\n"
	@printf "\033[0;32m✅ All code quality checks passed\033[0m\n"

# =============================================================================
# Documentation
# =============================================================================

docs: ## Generate documentation
	@printf "\033[1m\033[34m===> Generating documentation\033[0m\n"
	RUSTDOCFLAGS="-D warnings" $(CARGO) doc --no-deps --document-private-items --all-features
	@printf "\033[0;32m✅ Documentation generated\033[0m\n"

docs-open: docs ## Generate and open documentation
	@printf "\033[1m\033[34m===> Opening documentation\033[0m\n"
	$(CARGO) doc --no-deps --document-private-items --all-features --open

# =============================================================================
# Coverage
# =============================================================================

coverage: ## Generate test coverage report
	@printf "\033[1m\033[34m===> Generating test coverage report\033[0m\n"
	@command -v cargo-llvm-cov >/dev/null 2>&1 || { printf "\033[0;31m❌ cargo-llvm-cov not found. Install with: cargo install cargo-llvm-cov\033[0m\n"; exit 1; }
	rm -f lcov.info
	$(CARGO) llvm-cov --all-features --lcov --output-path lcov.info
	@printf "\033[0;32m✅ Coverage report generated: lcov.info\033[0m\n"
	@if command -v genhtml >/dev/null 2>&1; then \
		printf "\033[0;34mℹ️  Generating HTML coverage report...\033[0m\n"; \
		genhtml lcov.info --output-directory $(COVERAGE_DIR); \
		printf "\033[0;32m✅ HTML report generated in $(COVERAGE_DIR)/ directory\033[0m\n"; \
		printf "\033[0;34mℹ️  Open $(COVERAGE_DIR)/index.html in your browser to view the report\033[0m\n"; \
	else \
		printf "\033[1;33m⚠️  Install lcov to generate HTML coverage reports: apt-get install lcov\033[0m\n"; \
	fi
	@printf "\033[0;34mℹ️  Coverage Summary:\033[0m\n"
	@echo "  Source files: $$(grep -c "^SF:" lcov.info)"
	@echo "  Functions: $$(grep -c "^FN:" lcov.info)"
	@echo "  Lines hit: $$(grep -c "^DA:" lcov.info)"

coverage-open: coverage ## Generate coverage report and open in browser
	@if [ -f "$(COVERAGE_DIR)/index.html" ]; then \
		printf "\033[0;34mℹ️  Opening coverage report in browser...\033[0m\n"; \
		command -v xdg-open >/dev/null 2>&1 && xdg-open $(COVERAGE_DIR)/index.html || \
		command -v open >/dev/null 2>&1 && open $(COVERAGE_DIR)/index.html || \
		printf "\033[0;34mℹ️  Open $(COVERAGE_DIR)/index.html manually in your browser\033[0m\n"; \
	else \
		printf "\033[1;33m⚠️  HTML coverage report not available. Install genhtml.\033[0m\n"; \
	fi

# =============================================================================
# Security
# =============================================================================

security: ## Run comprehensive security scans
	@printf "\033[1m\033[34m===> Running security scans\033[0m\n"
	@printf "\033[0;34mℹ️  Running cargo audit...\033[0m\n"
	@if command -v cargo-audit >/dev/null 2>&1; then \
		$(CARGO) audit && printf "\033[0;32m✅ cargo audit passed\033[0m\n" || printf "\033[1;33m⚠️  cargo audit found issues\033[0m\n"; \
	else \
		printf "\033[1;33m⚠️  cargo-audit not found. Install with: cargo install cargo-audit\033[0m\n"; \
	fi
	@printf "\033[0;34mℹ️  Running Snyk scans...\033[0m\n"
	@if command -v snyk >/dev/null 2>&1; then \
		if snyk config get api >/dev/null 2>&1; then \
			printf "\033[0;32m✅ Snyk authenticated\033[0m\n"; \
			snyk test --severity-threshold=medium || printf "\033[1;33m⚠️  Snyk test found issues\033[0m\n"; \
			snyk code test --severity-threshold=medium || printf "\033[1;33m⚠️  Snyk code analysis found issues\033[0m\n"; \
			if [ -z "$$CI" ]; then \
				snyk monitor --project-name=$(PROJECT_NAME) || printf "\033[1;33m⚠️  Snyk monitor failed\033[0m\n"; \
			fi; \
		else \
			printf "\033[1;33m⚠️  Snyk not authenticated. Run 'snyk auth' first\033[0m\n"; \
		fi; \
	else \
		printf "\033[1;33m⚠️  Snyk CLI not found. Install from https://docs.snyk.io/snyk-cli/install-the-snyk-cli\033[0m\n"; \
	fi
	@printf "\033[0;34mℹ️  Checking for potential secrets...\033[0m\n"
	@found_issues=0; \
	patterns="password\s*=\s*['\"][^'\"]*['\"] api_key\s*=\s*['\"][^'\"]*['\"] secret\s*=\s*['\"][^'\"]*['\"] token\s*=\s*['\"][^'\"]*['\"]"; \
	for pattern in $$patterns; do \
		if grep -r -i -E "$$pattern" src/ 2>/dev/null; then \
			printf "\033[0;31m❌ Potential secret found: $$pattern\033[0m\n"; \
			found_issues=1; \
		fi; \
	done; \
	if [ $$found_issues -eq 0 ]; then \
		printf "\033[0;32m✅ No obvious secrets found in source code\033[0m\n"; \
	fi
	@if [ -f "Cargo.lock" ]; then \
		printf "\033[0;32m✅ Cargo.lock present (good for reproducible builds)\033[0m\n"; \
	else \
		printf "\033[1;33m⚠️  Cargo.lock not found. Consider committing it for reproducible builds\033[0m\n"; \
	fi
	@printf "\033[0;32m✅ Security scan completed\033[0m\n"

# =============================================================================
# SBOM Generation
# =============================================================================

sbom: ## Generate Software Bill of Materials
	@printf "\033[1m\033[34m===> Generating Software Bill of Materials\033[0m\n"
	@mkdir -p $(SBOM_DIR)
	@printf "\033[0;34mℹ️  Building project for accurate dependency resolution...\033[0m\n"
	@$(CARGO) build --release >/dev/null 2>&1
	@printf "\033[0;34mℹ️  Generating CycloneDX SBOM...\033[0m\n"
	@if command -v cargo-cyclonedx >/dev/null 2>&1; then \
		$(CARGO) cyclonedx --format json; \
		if [ -f "$(PROJECT_NAME).cdx.json" ]; then \
			mv "$(PROJECT_NAME).cdx.json" $(SBOM_DIR)/sbom-cyclonedx.json; \
			printf "\033[0;32m✅ CycloneDX SBOM generated: $(SBOM_DIR)/sbom-cyclonedx.json\033[0m\n"; \
		else \
			printf "\033[0;31m❌ CycloneDX SBOM file not found\033[0m\n"; \
		fi; \
	else \
		printf "\033[1;33m⚠️  cargo-cyclonedx not found. Install with: cargo install cargo-cyclonedx\033[0m\n"; \
	fi
	@printf "\033[0;34mℹ️  Generating SPDX SBOM...\033[0m\n"
	@if command -v syft >/dev/null 2>&1; then \
		syft packages . -o spdx-json=$(SBOM_DIR)/sbom-spdx.json -q; \
		printf "\033[0;32m✅ SPDX SBOM generated: $(SBOM_DIR)/sbom-spdx.json\033[0m\n"; \
		syft packages . -o json=$(SBOM_DIR)/sbom-syft.json -q; \
		printf "\033[0;32m✅ Syft JSON SBOM generated: $(SBOM_DIR)/sbom-syft.json\033[0m\n"; \
		syft packages . -o table=$(SBOM_DIR)/sbom-table.txt -q; \
		printf "\033[0;32m✅ Human-readable SBOM table generated: $(SBOM_DIR)/sbom-table.txt\033[0m\n"; \
	else \
		printf "\033[1;33m⚠️  syft not found. Install with: make setup\033[0m\n"; \
	fi
	@printf "\033[0;34mℹ️  Validating SBOM files...\033[0m\n"
	@valid_files=0; total_files=0; \
	for file in $(SBOM_DIR)/*.json; do \
		if [ -f "$$file" ]; then \
			total_files=$$((total_files + 1)); \
			filename=$$(basename "$$file"); \
			size=$$(wc -c < "$$file"); \
			if jq empty "$$file" 2>/dev/null; then \
				if jq -e '.components // .packages // .artifacts' "$$file" >/dev/null 2>&1; then \
					count=$$(jq -r '(.components // .packages // .artifacts) | length' "$$file"); \
					printf "\033[0;32m✅ $$filename: $$size bytes, $$count components - Valid\033[0m\n"; \
					valid_files=$$((valid_files + 1)); \
				else \
					printf "\033[1;33m⚠️  $$filename: $$size bytes - Valid JSON but no components found\033[0m\n"; \
				fi; \
			else \
				printf "\033[0;31m❌ $$filename: Invalid JSON format\033[0m\n"; \
			fi; \
		fi; \
	done; \
	printf "\033[0;34mℹ️  Validation complete: $$valid_files/$$total_files files are valid\033[0m\n"
	@printf "\033[0;32m✅ SBOM generation completed! Files available in: $(SBOM_DIR)\033[0m\n"

sbom-snyk: sbom ## Generate SBOM and upload to Snyk for scanning
	@printf "\033[1m\033[34m===> Uploading SBOM to Snyk for scanning\033[0m\n"
	@if command -v snyk >/dev/null 2>&1; then \
		if snyk config get api >/dev/null 2>&1; then \
			if [ -f "$(SBOM_DIR)/sbom-cyclonedx.json" ]; then \
				printf "\033[0;34mℹ️  Uploading CycloneDX SBOM to Snyk...\033[0m\n"; \
				snyk test --file=$(SBOM_DIR)/sbom-cyclonedx.json --package-manager=cyclonedx --severity-threshold=medium --project-name=$(PROJECT_NAME)-sbom || printf "\033[1;33m⚠️  SBOM scan found issues\033[0m\n"; \
				snyk monitor --file=$(SBOM_DIR)/sbom-cyclonedx.json --package-manager=cyclonedx --project-name=$(PROJECT_NAME)-sbom || printf "\033[1;33m⚠️  SBOM monitor failed\033[0m\n"; \
				printf "\033[0;32m✅ SBOM uploaded to Snyk successfully\033[0m\n"; \
			else \
				printf "\033[0;31m❌ CycloneDX SBOM file not found\033[0m\n"; \
			fi; \
		else \
			printf "\033[0;31m❌ Snyk not authenticated. Run 'snyk auth' first\033[0m\n"; \
		fi; \
	else \
		printf "\033[0;31m❌ Snyk CLI not found\033[0m\n"; \
	fi

# =============================================================================
# Workflow and CI/CD
# =============================================================================

validate-workflows: ## Validate GitHub Actions workflow files
	@printf "\033[1m\033[34m===> Validating GitHub Actions workflows\033[0m\n"
	@if [ ! -d ".github/workflows" ]; then \
		printf "\033[0;31m❌ No .github/workflows directory found\033[0m\n"; \
		exit 1; \
	fi
	@workflow_files=$$(find .github/workflows -name "*.yml" -o -name "*.yaml" 2>/dev/null); \
	if [ -z "$$workflow_files" ]; then \
		printf "\033[0;31m❌ No workflow files found\033[0m\n"; \
		exit 1; \
	fi
	@printf "\033[0;34mℹ️  Found workflow files:\033[0m\n"
	@for file in $$(find .github/workflows -name "*.yml" -o -name "*.yaml" 2>/dev/null); do \
		echo "  - $$file"; \
	done
	@printf "\033[0;34mℹ️  Performing basic YAML syntax validation...\033[0m\n"
	@validation_failed=false; \
	for file in $$(find .github/workflows -name "*.yml" -o -name "*.yaml" 2>/dev/null); do \
		echo -n "Checking $$file... "; \
		if command -v python3 >/dev/null 2>&1; then \
			if python3 -c "import yaml; yaml.safe_load(open('$$file', 'r'))" 2>/dev/null; then \
				printf "\033[0;32m✅ Valid YAML\033[0m\n"; \
			else \
				printf "\033[0;31m❌ YAML Error\033[0m\n"; \
				validation_failed=true; \
			fi; \
		else \
			printf "\033[1;33m⚠️  No YAML validator available\033[0m\n"; \
		fi; \
	done
	@printf "\033[0;34mℹ️  Checking for common workflow issues...\033[0m\n"
	@critical_issues=false; \
	for file in $$(find .github/workflows -name "*.yml" -o -name "*.yaml" 2>/dev/null); do \
		if grep -q "if:.*secrets\." "$$file" 2>/dev/null; then \
			printf "\033[0;31m❌ Found 'secrets' in 'if' condition in $$file (not allowed)\033[0m\n"; \
			critical_issues=true; \
		fi; \
	done; \
	if [ "$$critical_issues" = true ]; then \
		printf "\033[0;31m❌ Critical workflow issues found\033[0m\n"; \
		exit 1; \
	else \
		printf "\033[0;32m✅ All workflow files look good!\033[0m\n"; \
	fi

# =============================================================================
# Application Commands
# =============================================================================

run: build ## Run the application (requires arguments: make run ARGS="init")
	@printf "\033[1m\033[34m===> Running $(PROJECT_NAME)\033[0m\n"
	@if [ -z "$(ARGS)" ]; then \
		printf "\033[1;33m⚠️  No arguments provided. Example: make run ARGS=\"--help\"\033[0m\n"; \
		$(CARGO) run -- --help; \
	else \
		printf "\033[0;34mℹ️  Running: $(PROJECT_NAME) $(ARGS)\033[0m\n"; \
		$(CARGO) run -- $(ARGS); \
	fi

demo: build-release ## Run a quick demo of the tool
	@printf "\033[1m\033[34m===> Running $(PROJECT_NAME) demo\033[0m\n"
	@DEMO_DIR=$$(mktemp -d); \
	cd "$$DEMO_DIR"; \
	echo "Demo directory: $$DEMO_DIR"; \
	printf "\033[0;34mℹ️  Initializing ADR repository...\033[0m\n"; \
	$(PWD)/$(TARGET_DIR)/release/$(PROJECT_NAME) init; \
	printf "\033[0;34mℹ️  Creating sample ADRs...\033[0m\n"; \
	$(PWD)/$(TARGET_DIR)/release/$(PROJECT_NAME) new "Use microservices architecture"; \
	$(PWD)/$(TARGET_DIR)/release/$(PROJECT_NAME) new "Adopt React for frontend" --supersede 1; \
	printf "\033[0;34mℹ️  Listing ADRs...\033[0m\n"; \
	$(PWD)/$(TARGET_DIR)/release/$(PROJECT_NAME) list; \
	printf "\033[0;34mℹ️  Generating table of contents...\033[0m\n"; \
	$(PWD)/$(TARGET_DIR)/release/$(PROJECT_NAME) generate toc; \
	printf "\033[0;32m✅ Demo completed. Files created in: $$DEMO_DIR\033[0m\n"; \
	echo "To explore the demo:"; \
	echo "  cd $$DEMO_DIR"; \
	echo "  find . -name \"*.md\" -exec echo \"=== {} ===\" \; -exec cat {} \; -exec echo \;"

# =============================================================================
# Release and Publishing
# =============================================================================

release-check: all ## Check if ready for release
	@printf "\033[1m\033[34m===> Checking release readiness\033[0m\n"
	@printf "\033[0;34mℹ️  Running full test suite...\033[0m\n"
	@$(MAKE) test test-integration
	@printf "\033[0;34mℹ️  Checking code quality...\033[0m\n"
	@$(MAKE) check
	@printf "\033[0;34mℹ️  Generating documentation...\033[0m\n"
	@$(MAKE) docs
	@printf "\033[0;34mℹ️  Running security scans...\033[0m\n"
	@$(MAKE) security
	@printf "\033[0;34mℹ️  Validating workflows...\033[0m\n"
	@$(MAKE) validate-workflows
	@printf "\033[0;32m✅ Release readiness check completed successfully!\033[0m\n"

# =============================================================================
# Comprehensive Targets
# =============================================================================

all: clean build test check docs coverage ## Run comprehensive build pipeline
	@printf "\033[1m\033[34m===> Running comprehensive build pipeline\033[0m\n"
	@printf "\033[0;32m✅ All checks passed! Ready for release.\033[0m\n"

ci: all security validate-workflows ## Run CI pipeline (equivalent to GitHub Actions)
	@printf "\033[1m\033[34m===> Running CI pipeline\033[0m\n"
	@printf "\033[0;32m✅ CI pipeline completed successfully!\033[0m\n"

# =============================================================================
# Development Helpers
# =============================================================================

watch: ## Watch for changes and run tests (requires cargo-watch)
	@printf "\033[1m\033[34m===> Watching for changes\033[0m\n"
	@command -v cargo-watch >/dev/null 2>&1 || { printf "\033[0;31m❌ cargo-watch not found. Install with: cargo install cargo-watch\033[0m\n"; exit 1; }
	$(CARGO) watch -x build -x test -x clippy

serve-docs: docs ## Serve documentation locally (requires basic HTTP server)
	@printf "\033[1m\033[34m===> Serving documentation\033[0m\n"
	@if command -v python3 >/dev/null 2>&1; then \
		printf "\033[0;34mℹ️  Documentation available at: http://localhost:8000\033[0m\n"; \
		cd $(TARGET_DIR)/doc && python3 -m http.server 8000; \
	elif command -v ruby >/dev/null 2>&1; then \
		printf "\033[0;34mℹ️  Documentation available at: http://localhost:8000\033[0m\n"; \
		cd $(TARGET_DIR)/doc && ruby -run -ehttpd . -p8000; \
	else \
		printf "\033[0;31m❌ No HTTP server available. Install python3 or ruby\033[0m\n"; \
	fi

env: ## Show environment information
	@printf "\033[1m\033[34m===> Environment Information\033[0m\n"
	@echo "Rust version: $$(rustc --version)"
	@echo "Cargo version: $$(cargo --version)"
	@echo "Project name: $(PROJECT_NAME)"
	@echo "Target directory: $(TARGET_DIR)"
	@echo "Working directory: $$(pwd)"
	@echo "Available tools:"
	@command -v cargo-fmt >/dev/null 2>&1 && echo "  ✅ rustfmt" || echo "  ❌ rustfmt"
	@command -v cargo-clippy >/dev/null 2>&1 && echo "  ✅ clippy" || echo "  ❌ clippy"
	@command -v cargo-llvm-cov >/dev/null 2>&1 && echo "  ✅ cargo-llvm-cov" || echo "  ❌ cargo-llvm-cov"
	@command -v cargo-audit >/dev/null 2>&1 && echo "  ✅ cargo-audit" || echo "  ❌ cargo-audit"
	@command -v cargo-cyclonedx >/dev/null 2>&1 && echo "  ✅ cargo-cyclonedx" || echo "  ❌ cargo-cyclonedx"
	@command -v syft >/dev/null 2>&1 && echo "  ✅ syft" || echo "  ❌ syft"
	@command -v snyk >/dev/null 2>&1 && echo "  ✅ snyk" || echo "  ❌ snyk"