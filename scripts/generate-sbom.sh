#!/bin/bash

# SBOM Generation Script for adr-tools-alt
# Generates Software Bill of Materials in multiple formats

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
OUTPUT_DIR="sbom-output"
FORMATS="cyclonedx,spdx,syft"
UPLOAD_TO_SNYK=false
VERBOSE=false

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Generate Software Bill of Materials (SBOM) for adr-tools-alt

OPTIONS:
    -o, --output DIR        Output directory (default: sbom-output)
    -f, --formats LIST      Comma-separated list of formats: cyclonedx,spdx,syft (default: all)
    -s, --snyk             Upload to Snyk for scanning (requires SNYK_TOKEN)
    -v, --verbose          Verbose output
    -h, --help             Show this help message

EXAMPLES:
    $0                                          # Generate all formats
    $0 -o /tmp/sbom -f cyclonedx               # Generate only CycloneDX format
    $0 -s                                       # Generate and upload to Snyk
    $0 -f cyclonedx,spdx -o ./reports -s       # Custom formats and Snyk upload

REQUIREMENTS:
    - Rust toolchain installed
    - cargo-cyclonedx (for CycloneDX format)
    - syft (for SPDX and Syft formats)
    - snyk CLI (for Snyk upload)

EOF
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v cargo >/dev/null 2>&1; then
        missing_deps+=("cargo (Rust toolchain)")
    fi
    
    if [[ "$FORMATS" == *"cyclonedx"* ]] && ! command -v cargo-cyclonedx >/dev/null 2>&1; then
        print_warning "cargo-cyclonedx not found. Installing..."
        if ! cargo install cargo-cyclonedx; then
            missing_deps+=("cargo-cyclonedx")
        fi
    fi
    
    if [[ "$FORMATS" == *"spdx"* || "$FORMATS" == *"syft"* ]] && ! command -v syft >/dev/null 2>&1; then
        print_warning "syft not found. Attempting to install..."
        if curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin 2>/dev/null; then
            print_success "syft installed successfully"
        else
            missing_deps+=("syft (https://github.com/anchore/syft)")
        fi
    fi
    
    if [[ "$UPLOAD_TO_SNYK" == true ]]; then
        if ! command -v snyk >/dev/null 2>&1; then
            missing_deps+=("snyk CLI (https://docs.snyk.io/snyk-cli/install-the-snyk-cli)")
        fi
        
        if [[ -z "${SNYK_TOKEN:-}" ]]; then
            print_error "SNYK_TOKEN environment variable is required for Snyk upload"
            missing_deps+=("SNYK_TOKEN environment variable")
        fi
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        return 1
    fi
}

# Function to generate CycloneDX SBOM
generate_cyclonedx() {
    print_info "Generating CycloneDX SBOM..."
    
    cargo cyclonedx --format json --output-dir "$OUTPUT_DIR"
    
    # Rename to standard naming
    if [[ -f "$OUTPUT_DIR/bom.json" ]]; then
        mv "$OUTPUT_DIR/bom.json" "$OUTPUT_DIR/sbom-cyclonedx.json"
        print_success "CycloneDX SBOM generated: $OUTPUT_DIR/sbom-cyclonedx.json"
    else
        print_error "Failed to generate CycloneDX SBOM"
        return 1
    fi
}

# Function to generate SPDX SBOM
generate_spdx() {
    print_info "Generating SPDX SBOM..."
    
    if syft packages . -o spdx-json="$OUTPUT_DIR/sbom-spdx.json"; then
        print_success "SPDX SBOM generated: $OUTPUT_DIR/sbom-spdx.json"
    else
        print_error "Failed to generate SPDX SBOM"
        return 1
    fi
}

# Function to generate Syft JSON SBOM
generate_syft() {
    print_info "Generating Syft JSON SBOM..."
    
    if syft packages . -o json="$OUTPUT_DIR/sbom-syft.json"; then
        print_success "Syft JSON SBOM generated: $OUTPUT_DIR/sbom-syft.json"
        
        # Also generate human-readable table
        if syft packages . -o table="$OUTPUT_DIR/sbom-table.txt"; then
            print_success "Human-readable SBOM table generated: $OUTPUT_DIR/sbom-table.txt"
        fi
    else
        print_error "Failed to generate Syft JSON SBOM"
        return 1
    fi
}

# Function to validate SBOM files
validate_sbom() {
    print_info "Validating SBOM files..."
    
    local valid_files=0
    local total_files=0
    
    for file in "$OUTPUT_DIR"/*.json; do
        if [[ -f "$file" ]]; then
            total_files=$((total_files + 1))
            local filename=$(basename "$file")
            local size=$(wc -c < "$file")
            
            # Basic JSON validation
            if jq empty "$file" 2>/dev/null; then
                # Check if contains components/packages
                if jq -e '.components // .packages // .artifacts' "$file" > /dev/null 2>&1; then
                    local count=$(jq -r '(.components // .packages // .artifacts) | length' "$file")
                    print_success "$filename: $size bytes, $count components - Valid"
                    valid_files=$((valid_files + 1))
                else
                    print_warning "$filename: $size bytes - Valid JSON but no components found"
                fi
            else
                print_error "$filename: Invalid JSON format"
            fi
        fi
    done
    
    print_info "Validation complete: $valid_files/$total_files files are valid"
}

# Function to upload to Snyk
upload_to_snyk() {
    print_info "Uploading SBOM files to Snyk..."
    
    local uploaded=0
    
    # Try CycloneDX first (preferred by Snyk)
    if [[ -f "$OUTPUT_DIR/sbom-cyclonedx.json" ]]; then
        print_info "Uploading CycloneDX SBOM to Snyk..."
        if snyk test --file="$OUTPUT_DIR/sbom-cyclonedx.json" \
                    --package-manager=cyclonedx \
                    --severity-threshold=medium \
                    --project-name="adr-tools-alt-sbom-cyclonedx"; then
            print_success "CycloneDX SBOM uploaded and scanned successfully"
            uploaded=$((uploaded + 1))
        else
            print_warning "CycloneDX SBOM scan found issues (check Snyk dashboard)"
        fi
        
        # Monitor in Snyk
        if snyk monitor --file="$OUTPUT_DIR/sbom-cyclonedx.json" \
                       --package-manager=cyclonedx \
                       --project-name="adr-tools-alt-sbom"; then
            print_success "CycloneDX SBOM added to Snyk monitoring"
        fi
    fi
    
    # Try SPDX as fallback
    if [[ -f "$OUTPUT_DIR/sbom-spdx.json" ]]; then
        print_info "Uploading SPDX SBOM to Snyk..."
        if snyk test --file="$OUTPUT_DIR/sbom-spdx.json" \
                    --package-manager=spdx \
                    --severity-threshold=medium \
                    --project-name="adr-tools-alt-sbom-spdx"; then
            print_success "SPDX SBOM uploaded and scanned successfully"
            uploaded=$((uploaded + 1))
        else
            print_warning "SPDX SBOM scan found issues (check Snyk dashboard)"
        fi
    fi
    
    if [[ $uploaded -eq 0 ]]; then
        print_error "Failed to upload any SBOM files to Snyk"
        return 1
    else
        print_success "Successfully uploaded $uploaded SBOM file(s) to Snyk"
    fi
}

# Function to generate summary report
generate_summary() {
    print_info "Generating SBOM summary..."
    
    local summary_file="$OUTPUT_DIR/sbom-summary.md"
    
    cat > "$summary_file" << EOF
# SBOM Generation Summary

**Generated on:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Project:** adr-tools-alt
**Directory:** $(pwd)

## Generated Files

| Format | File | Size | Components | Status |
|--------|------|------|------------|--------|
EOF
    
    for file in "$OUTPUT_DIR"/*.json; do
        if [[ -f "$file" ]]; then
            local name=$(basename "$file")
            local size=$(wc -c < "$file" | numfmt --to=iec)
            local count="N/A"
            local status="❌ Invalid"
            
            # Check if valid JSON and count components
            if jq empty "$file" 2>/dev/null; then
                if jq -e '.components // .packages // .artifacts' "$file" > /dev/null 2>&1; then
                    count=$(jq -r '(.components // .packages // .artifacts) | length' "$file")
                    status="✅ Valid"
                else
                    status="⚠️ No components"
                fi
            fi
            
            echo "| ${name#sbom-} | $name | $size | $count | $status |" >> "$summary_file"
        fi
    done
    
    cat >> "$summary_file" << EOF

## Key Dependencies

EOF
    
    # Extract key dependencies if available
    if [[ -f "$OUTPUT_DIR/sbom-cyclonedx.json" ]]; then
        echo "### From CycloneDX SBOM:" >> "$summary_file"
        echo "\`\`\`" >> "$summary_file"
        jq -r '.components[] | select(.type == "library") | "\(.name) \(.version // "unknown")"' \
           "$OUTPUT_DIR/sbom-cyclonedx.json" | head -20 >> "$summary_file"
        echo "\`\`\`" >> "$summary_file"
    fi
    
    print_success "Summary report generated: $summary_file"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -f|--formats)
            FORMATS="$2"
            shift 2
            ;;
        -s|--snyk)
            UPLOAD_TO_SNYK=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            set -x
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    print_info "Starting SBOM generation for adr-tools-alt"
    print_info "Output directory: $OUTPUT_DIR"
    print_info "Formats: $FORMATS"
    
    # Check if we're in a Rust project
    if [[ ! -f "Cargo.toml" ]]; then
        print_error "Cargo.toml not found. Please run this script from the project root."
        exit 1
    fi
    
    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Build project first (ensures accurate dependency resolution)
    print_info "Building project for accurate dependency resolution..."
    if cargo build --release; then
        print_success "Project built successfully"
    else
        print_warning "Build failed, but continuing with SBOM generation..."
    fi
    
    # Generate SBOM files based on requested formats
    local generated_any=false
    
    if [[ "$FORMATS" == *"cyclonedx"* ]]; then
        if generate_cyclonedx; then
            generated_any=true
        fi
    fi
    
    if [[ "$FORMATS" == *"spdx"* ]]; then
        if generate_spdx; then
            generated_any=true
        fi
    fi
    
    if [[ "$FORMATS" == *"syft"* ]]; then
        if generate_syft; then
            generated_any=true
        fi
    fi
    
    if [[ "$generated_any" == false ]]; then
        print_error "Failed to generate any SBOM files"
        exit 1
    fi
    
    # Validate generated files
    validate_sbom
    
    # Generate summary
    generate_summary
    
    # Upload to Snyk if requested
    if [[ "$UPLOAD_TO_SNYK" == true ]]; then
        upload_to_snyk
    fi
    
    print_success "SBOM generation completed successfully!"
    print_info "Files available in: $OUTPUT_DIR"
    
    if [[ "$UPLOAD_TO_SNYK" == true ]]; then
        print_info "Check your Snyk dashboard for scan results: https://app.snyk.io"
    fi
}

# Run main function
main "$@"