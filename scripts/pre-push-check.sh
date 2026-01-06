#!/bin/bash
# Pre-push check script for OrionHealth
# Runs all tests and checks before pushing to ensure CI will pass

set -e  # Exit on error

echo "🚀 OrionHealth Pre-Push Check"
echo "=============================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FAILED=0

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        FAILED=1
    fi
}

# 1. Flutter Analyze
echo "📊 Running Flutter analyze..."
if flutter analyze; then
    print_status 0 "Flutter analyze"
else
    print_status 1 "Flutter analyze"
fi
echo ""

# 2. Rust Format Check
echo "🦀 Checking Rust format..."
cd rust
if cargo fmt --all -- --check; then
    print_status 0 "Rust format"
else
    print_status 1 "Rust format (run: cargo fmt)"
fi
cd ..
echo ""

# 3. Rust Clippy
echo "🔬 Running Rust clippy..."
cd rust
if cargo clippy --all-targets --all-features -- -D warnings; then
    print_status 0 "Rust clippy"
else
    print_status 1 "Rust clippy"
fi
cd ..
echo ""

# 4. Rust Tests
echo "🧪 Running Rust tests..."
cd rust
if cargo test --all-features; then
    print_status 0 "Rust tests"
else
    print_status 1 "Rust tests"
fi
cd ..
echo ""

# 5. Flutter-Rust Bridge Sync Check
echo "🌉 Checking flutter_rust_bridge sync..."
if command -v flutter_rust_bridge_codegen &> /dev/null; then
    flutter_rust_bridge_codegen generate &> /dev/null

    if git diff --quiet lib/src/rust/; then
        print_status 0 "Bridge sync"
    else
        print_status 1 "Bridge out of sync (run: flutter_rust_bridge_codegen generate)"
        echo -e "${YELLOW}ℹ️  Run: flutter_rust_bridge_codegen generate${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  flutter_rust_bridge_codegen not installed, skipping bridge check${NC}"
fi
echo ""

# 6. Flutter Tests
echo "🧪 Running Flutter tests..."
if flutter test; then
    print_status 0 "Flutter tests"
else
    print_status 1 "Flutter tests"
fi
echo ""

# 7. Integration Tests (if exist)
if [ -d "integration_test" ] && [ "$(ls -A integration_test/*.dart 2>/dev/null)" ]; then
    echo "🔗 Running integration tests..."
    if flutter test integration_test/; then
        print_status 0 "Integration tests"
    else
        print_status 1 "Integration tests"
    fi
    echo ""
fi

# Summary
echo "=============================="
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! Safe to push.${NC}"
    exit 0
else
    echo -e "${RED}❌ Some checks failed. Fix issues before pushing.${NC}"
    exit 1
fi
