#!/bin/bash

# Script to generate test coverage report for adr-tools-alt

set -e

echo "🧪 Generating test coverage report..."

# Clean up any existing coverage data
rm -f lcov.info

# Generate coverage report (excluding integration tests to avoid issues)
cargo llvm-cov --all-features --lcov --output-path lcov.info

echo "✅ Coverage report generated: lcov.info"

# If genhtml is available, generate HTML report
if command -v genhtml &> /dev/null; then
    echo "📊 Generating HTML coverage report..."
    genhtml lcov.info --output-directory coverage-report
    echo "✅ HTML report generated in coverage-report/ directory"
    echo "📖 Open coverage-report/index.html in your browser to view the report"
else
    echo "💡 Install lcov to generate HTML coverage reports: apt-get install lcov"
fi

# Show basic coverage statistics
echo ""
echo "📈 Coverage Summary:"
echo "Source files: $(grep -c "^SF:" lcov.info)"
echo "Functions: $(grep -c "^FN:" lcov.info)"
echo "Lines hit: $(grep -c "^DA:" lcov.info | head -1)"

echo ""
echo "🎯 Coverage report completed successfully!"