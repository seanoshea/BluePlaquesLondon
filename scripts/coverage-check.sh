#!/bin/bash

# Coverage threshold (percentage)
THRESHOLD=70

# Find the xcresult bundle
XCRESULT_PATH=$(find . -name "*.xcresult" -type d | head -1)

if [ -z "$XCRESULT_PATH" ]; then
    echo "❌ No xcresult bundle found"
    exit 1
fi

echo "📊 Found xcresult at: $XCRESULT_PATH"

# Create test_output directory if it doesn't exist
mkdir -p test_output

# Export coverage data
xcrun xccov view --report --json "$XCRESULT_PATH" > test_output/coverage.json

# Show the BluePlaquesLondon.app line for debugging
echo "🔍 Looking for BluePlaquesLondon.app coverage..."
APP_LINE=$(xcrun xccov view --report "$XCRESULT_PATH" | grep "BluePlaquesLondon.app")
echo "📋 App line: $APP_LINE"

# Extract coverage percentage from BluePlaquesLondon.app line
COVERAGE=$(echo "$APP_LINE" | awk '{print $2}' | sed 's/%.*$//')

# If that doesn't work, try extracting from the coverage column
if [ -z "$COVERAGE" ]; then
    COVERAGE=$(echo "$APP_LINE" | sed -n 's/.*\([0-9]\+\.[0-9]\+\)%.*/\1/p')
fi

if [ -z "$COVERAGE" ]; then
    echo "❌ Could not extract coverage percentage"
    echo "📊 Full coverage report:"
    xcrun xccov view --report "$XCRESULT_PATH" | head -20
    exit 1
fi

echo "📈 Current coverage: ${COVERAGE}%"
echo "🎯 Required threshold: ${THRESHOLD}%"

# Check if coverage meets threshold
if (( $(echo "$COVERAGE >= $THRESHOLD" | bc -l) )); then
    echo "✅ Coverage threshold met!"
    exit 0
else
    echo "❌ Coverage below threshold (${COVERAGE}% < ${THRESHOLD}%)"
    exit 1
fi