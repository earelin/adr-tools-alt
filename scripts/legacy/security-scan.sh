#!/bin/bash

# Script to run comprehensive security scans for adr-tools-alt

set -e

echo "🔒 Running security scans for adr-tools-alt..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run with status
run_with_status() {
    local description="$1"
    local command="$2"
    
    echo -e "${BLUE}📊 $description...${NC}"
    
    if eval "$command"; then
        echo -e "${GREEN}✅ $description completed successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ $description failed${NC}"
        return 1
    fi
}

# Cargo audit scan
if command_exists cargo-audit; then
    run_with_status "Running cargo audit" "cargo audit"
else
    echo -e "${YELLOW}⚠️  cargo-audit not found. Install with: cargo install cargo-audit${NC}"
fi

# Snyk scans
if command_exists snyk; then
    echo -e "${BLUE}🔍 Checking Snyk authentication...${NC}"
    
    if snyk config get api > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Snyk authenticated${NC}"
        
        # Open source vulnerability scan
        run_with_status "Snyk open source scan" "snyk test --severity-threshold=medium" || true
        
        # Code analysis
        run_with_status "Snyk code analysis" "snyk code test --severity-threshold=medium" || true
        
        # Monitor (only if not in CI)
        if [ -z "$CI" ]; then
            echo -e "${BLUE}📈 Adding project to Snyk monitoring...${NC}"
            snyk monitor --project-name=adr-tools-alt || echo -e "${YELLOW}⚠️  Monitor failed (this is usually fine for local development)${NC}"
        fi
        
    else
        echo -e "${YELLOW}⚠️  Snyk not authenticated. Run 'snyk auth' first${NC}"
        echo -e "${BLUE}💡 To install Snyk CLI:${NC}"
        echo "   npm install -g snyk"
        echo "   # or"
        echo "   brew install snyk"
    fi
else
    echo -e "${YELLOW}⚠️  Snyk CLI not found${NC}"
    echo -e "${BLUE}💡 To install Snyk CLI:${NC}"
    echo "   npm install -g snyk"
    echo "   # or" 
    echo "   brew install snyk"
    echo "   # or"
    echo "   curl https://static.snyk.io/cli/latest/snyk-linux -o snyk && chmod +x snyk && sudo mv snyk /usr/local/bin/"
fi

# Additional security checks
echo -e "${BLUE}🔧 Additional security recommendations:${NC}"

# Check for Cargo.lock
if [ -f "Cargo.lock" ]; then
    echo -e "${GREEN}✅ Cargo.lock present (good for reproducible builds)${NC}"
else
    echo -e "${YELLOW}⚠️  Cargo.lock not found. Consider committing it for reproducible builds${NC}"
fi

# Check for sensitive patterns (basic)
if command_exists grep; then
    echo -e "${BLUE}🔍 Checking for potential secrets in source code...${NC}"
    
    # Basic patterns to avoid
    patterns=(
        "password\s*=\s*['\"][^'\"]*['\"]"
        "api_key\s*=\s*['\"][^'\"]*['\"]"
        "secret\s*=\s*['\"][^'\"]*['\"]"
        "token\s*=\s*['\"][^'\"]*['\"]"
    )
    
    found_issues=0
    for pattern in "${patterns[@]}"; do
        if grep -r -i -E "$pattern" src/ 2>/dev/null; then
            echo -e "${RED}❌ Potential secret found: $pattern${NC}"
            found_issues=1
        fi
    done
    
    if [ $found_issues -eq 0 ]; then
        echo -e "${GREEN}✅ No obvious secrets found in source code${NC}"
    fi
fi

echo ""
echo -e "${GREEN}🎯 Security scan completed!${NC}"
echo -e "${BLUE}📚 For more information, see .github/SNYK_SETUP.md${NC}"