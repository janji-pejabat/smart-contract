#!/bin/bash

# Quick Install Script untuk Paxi Smart Contracts
# Download semua scripts yang diperlukan

set -e

echo "📦 Installing Paxi Smart Contract Scripts..."
echo ""

# Create working directory
WORK_DIR="$HOME/paxi-contracts"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "📁 Working directory: $WORK_DIR"
echo ""

# Base URL
BASE_URL="https://raw.githubusercontent.com/janji-pejabat/smart-contract/main"

# Download scripts
echo "⬇️  Downloading scripts..."

# LP Lock scripts
curl -fsSL "$BASE_URL/generate_lp_lock.sh" -o generate_lp_lock.sh
curl -fsSL "$BASE_URL/build_lp_lock.sh" -o build_lp_lock.sh

# Vesting scripts
curl -fsSL "$BASE_URL/generate_vesting.sh" -o generate_vesting.sh
curl -fsSL "$BASE_URL/build_vesting.sh" -o build_vesting.sh

# Make executable
chmod +x *.sh

echo "✅ Scripts downloaded successfully!"
echo ""

# Check Rust installation
echo "🔍 Checking Rust installation..."

if command -v rustc &> /dev/null; then
    echo "✅ Rust installed: $(rustc --version)"
    
    # Check wasm32 target
    if rustc --print target-list | grep -q "wasm32-unknown-unknown"; then
        echo "✅ wasm32-unknown-unknown target available"
    else
        echo "⚠️  wasm32-unknown-unknown target not found"
        echo "   Installing..."
        rustup target add wasm32-unknown-unknown
    fi
else
    echo "❌ Rust not installed"
    echo ""
    echo "📋 Install Rust:"
    echo "   For Termux: pkg install rust -y"
    echo "   For Ubuntu: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
fi

echo ""

# Check wasm-opt
echo "🔍 Checking wasm-opt (binaryen)..."

if command -v wasm-opt &> /dev/null; then
    echo "✅ wasm-opt installed: $(wasm-opt --version)"
else
    echo "❌ wasm-opt not installed"
    echo ""
    echo "📋 Install binaryen:"
    echo "   For Termux: pkg install binaryen -y"
    echo "   For Ubuntu: sudo apt-get install binaryen -y"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Installation complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📁 Location: $WORK_DIR"
echo ""
echo "📋 Available scripts:"
echo "   ./generate_lp_lock.sh    - Generate LP Lock contract"
echo "   ./build_lp_lock.sh       - Build LP Lock contract"
echo "   ./generate_vesting.sh    - Generate Vesting contract"
echo "   ./build_vesting.sh       - Build Vesting contract"
echo ""
echo "🚀 Quick Start:"
echo "   1. Generate contract:"
echo "      ./generate_lp_lock.sh"
echo ""
echo "   2. Build contract:"
echo "      ./build_lp_lock.sh"
echo ""
echo "   3. Deploy:"
echo "      Check artifacts/ folder for .wasm files"
echo ""
echo "💡 Note: Scripts sudah di-fix untuk compatibility dengan Edition 2021"
echo "   dan tidak akan require Edition 2024 dependencies"
echo ""