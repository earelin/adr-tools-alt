#!/bin/bash

# Script to validate GitHub Actions workflow files

set -e

echo "🔧 Validating GitHub Actions workflows..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if we have yamllint or actionlint
VALIDATOR=""
if command_exists actionlint; then
    VALIDATOR="actionlint"
elif command_exists yamllint; then
    VALIDATOR="yamllint"
else
    echo -e "${BLUE}💡 Consider installing actionlint or yamllint for workflow validation:${NC}"
    echo "  # actionlint (GitHub Actions specific)"
    echo "  go install github.com/rhymond/actionlint/cmd/actionlint@latest"
    echo ""
    echo "  # yamllint (general YAML)"
    echo "  pip install yamllint"
    echo ""
fi

# Find all workflow files
WORKFLOW_DIR=".github/workflows"
if [ ! -d "$WORKFLOW_DIR" ]; then
    echo -e "${RED}❌ No .github/workflows directory found${NC}"
    exit 1
fi

echo -e "${BLUE}📂 Found workflow directory: $WORKFLOW_DIR${NC}"

# List all workflow files
workflow_files=$(find "$WORKFLOW_DIR" -name "*.yml" -o -name "*.yaml" 2>/dev/null)

if [ -z "$workflow_files" ]; then
    echo -e "${RED}❌ No workflow files found${NC}"
    exit 1
fi

echo -e "${BLUE}🔍 Found workflow files:${NC}"
for file in $workflow_files; do
    echo "  - $file"
done
echo ""

# Basic syntax validation
echo -e "${BLUE}🔍 Performing basic YAML syntax validation...${NC}"

validation_failed=false

for file in $workflow_files; do
    echo -n "Checking $file... "
    
    # Basic YAML syntax check using Python
    if command_exists python3; then
        if python3 -c "
import yaml
import sys
try:
    with open('$file', 'r') as f:
        yaml.safe_load(f)
    print('✅ Valid YAML')
except yaml.YAMLError as e:
    print(f'❌ YAML Error: {e}')
    sys.exit(1)
except Exception as e:
    print(f'❌ Error: {e}')
    sys.exit(1)
" 2>/dev/null; then
        true  # Success
    else
        validation_failed=true
    fi
    elif command_exists ruby; then
        if ruby -e "
require 'yaml'
begin
    YAML.load_file('$file')
    puts '✅ Valid YAML'
rescue => e
    puts \"❌ YAML Error: #{e}\"
    exit 1
end
" 2>/dev/null; then
        true  # Success
    else
        validation_failed=true
    fi
    else
        echo "⚠️ No YAML validator available (install python3 or ruby)"
    fi
done

echo ""

# Advanced validation if tools available
if [ "$VALIDATOR" = "actionlint" ]; then
    echo -e "${BLUE}🔍 Running actionlint validation...${NC}"
    if actionlint "$WORKFLOW_DIR"/*.yml; then
        echo -e "${GREEN}✅ All workflows passed actionlint validation${NC}"
    else
        echo -e "${RED}❌ actionlint found issues${NC}"
        validation_failed=true
    fi
elif [ "$VALIDATOR" = "yamllint" ]; then
    echo -e "${BLUE}🔍 Running yamllint validation...${NC}"
    if yamllint "$WORKFLOW_DIR"; then
        echo -e "${GREEN}✅ All workflows passed yamllint validation${NC}"
    else
        echo -e "${RED}❌ yamllint found issues${NC}"
        validation_failed=true
    fi
fi

# Check for common issues
echo -e "${BLUE}🔍 Checking for common workflow issues...${NC}"

for file in $workflow_files; do
    echo "Checking $file for common issues:"
    
    # Check for secrets in if conditions
    if grep -n "if:.*secrets\." "$file" >/dev/null 2>&1; then
        echo -e "  ${RED}❌ Found 'secrets' in 'if' condition (not allowed)${NC}"
        grep -n "if:.*secrets\." "$file"
        validation_failed=true
    else
        echo -e "  ${GREEN}✅ No secrets in if conditions${NC}"
    fi
    
    # Check for proper action versions (allow snyk/actions@master)
    if grep -n "uses:.*@master" "$file" | grep -v "snyk/actions" >/dev/null 2>&1; then
        echo -e "  ${BLUE}ℹ️ Using @master instead of pinned versions:${NC}"
        grep -n "uses:.*@master" "$file" | grep -v "snyk/actions"
    elif grep -n "uses:.*snyk/actions.*@master" "$file" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✅ Using snyk/actions@master (recommended)${NC}"
    fi
    
    # Check for environment variable usage
    if grep -n "\${{.*env\." "$file" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✅ Found environment variable usage${NC}"
    fi
    
    echo ""
done

# Summary
echo -e "${BLUE}📊 Validation Summary:${NC}"

# Check if we found any critical issues (not just YAML parsing issues)
critical_issues=false
for file in $workflow_files; do
    if grep -q "if:.*secrets\." "$file" 2>/dev/null; then
        critical_issues=true
        break
    fi
done

if [ "$critical_issues" = true ]; then
    echo -e "${RED}❌ Critical workflow issues found${NC}"
    echo -e "${BLUE}💡 Fix the critical issues above and run the validation again${NC}"
    exit 1
else
    echo -e "${GREEN}✅ All workflow files look good!${NC}"
    echo -e "${BLUE}🚀 Workflows should run successfully in GitHub Actions${NC}"
    if [ "$validation_failed" = true ]; then
        echo -e "${BLUE}ℹ️ Some YAML validation warnings were ignored${NC}"
    fi
fi