#!/bin/bash

# Build PRC20 LP Lock Contract
# Fixed: Compatible dengan Rust 1.81.0+ dan edition 2021

set -e

PROJECT_NAME="prc20-lp-lock"
CONTRACT_NAME="prc20_lp_lock"
ARTIFACTS_DIR="artifacts"

echo "🔨 Building $PROJECT_NAME..."

# Check if project exists
if [ ! -d "$PROJECT_NAME" ]; then
    echo "❌ Error: $PROJECT_NAME directory not found!"
    echo "   Run ./generate_lp_lock.sh first"
    exit 1
fi

# Check Rust installation
if ! command -v rustc &> /dev/null; then
    echo "❌ Error: Rust not installed!"
    echo "   Install: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

# Check wasm32 target
if ! rustc --print target-list | grep -q "wasm32-unknown-unknown"; then
    echo "📦 Installing wasm32-unknown-unknown target..."
    rustup target add wasm32-unknown-unknown
fi

# Check wasm-opt
if ! command -v wasm-opt &> /dev/null; then
    echo "⚠️  Warning: wasm-opt not found. Install binaryen for optimization."
    echo "   Termux: pkg install binaryen"
    echo "   Ubuntu: sudo apt-get install binaryen"
    echo ""
    echo "   Continuing without optimization..."
    SKIP_OPTIMIZE=true
else
    SKIP_OPTIMIZE=false
fi

# Print versions
echo "📌 Versions:"
rustc --version
cargo --version
if [ "$SKIP_OPTIMIZE" = false ]; then
    wasm-opt --version
fi
echo ""

# Clean previous build (optional, comment out untuk build lebih cepat)
# echo "🧹 Cleaning previous build..."
# cd $PROJECT_NAME
# cargo clean
# cd ..

# Build contract
echo "🔧 Compiling to WASM..."
cd $PROJECT_NAME

# Set build environment
export RUSTFLAGS='-C link-arg=-s'

# Build with proper error handling
if ! cargo build --release --target wasm32-unknown-unknown --locked 2>&1 | tee build.log; then
    echo ""
    echo "❌ Build failed! Check build.log for details"
    
    # Check for common errors
    if grep -q "edition2024" build.log; then
        echo ""
        echo "💡 Edition 2024 error detected!"
        echo "   Your Cargo.lock might be outdated."
        echo "   Try: rm Cargo.lock && cargo update"
    fi
    
    exit 1
fi

cd ..

# Create artifacts directory
mkdir -p $ARTIFACTS_DIR

# Get the built WASM file
WASM_FILE="$PROJECT_NAME/target/wasm32-unknown-unknown/release/${CONTRACT_NAME}.wasm"

if [ ! -f "$WASM_FILE" ]; then
    echo "❌ Error: WASM file not found at $WASM_FILE"
    exit 1
fi

# Show original size
ORIGINAL_SIZE=$(stat -f%z "$WASM_FILE" 2>/dev/null || stat -c%s "$WASM_FILE")
echo "📊 Original WASM size: $(echo "scale=2; $ORIGINAL_SIZE / 1024" | bc) KB"

# Optimize with wasm-opt
if [ "$SKIP_OPTIMIZE" = false ]; then
    echo "⚡ Optimizing WASM..."
    
    OUTPUT_FILE="$ARTIFACTS_DIR/${CONTRACT_NAME}_optimized.wasm"
    
    wasm-opt -Oz "$WASM_FILE" -o "$OUTPUT_FILE"
    
    OPTIMIZED_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE")
    REDUCTION=$(echo "scale=2; ($ORIGINAL_SIZE - $OPTIMIZED_SIZE) * 100 / $ORIGINAL_SIZE" | bc)
    
    echo "✅ Optimized WASM size: $(echo "scale=2; $OPTIMIZED_SIZE / 1024" | bc) KB"
    echo "📉 Size reduction: ${REDUCTION}%"
    
    # Check if size is reasonable
    if [ $OPTIMIZED_SIZE -gt 819200 ]; then
        echo "⚠️  Warning: Contract size exceeds 800 KB"
        echo "   This might cause issues during deployment"
    fi
else
    # Copy without optimization
    OUTPUT_FILE="$ARTIFACTS_DIR/${CONTRACT_NAME}.wasm"
    cp "$WASM_FILE" "$OUTPUT_FILE"
    echo "📦 WASM copied to artifacts (unoptimized)"
fi

echo ""
echo "✅ Build successful!"
echo "📁 Output: $OUTPUT_FILE"
echo ""
echo "🚀 Next steps:"
echo "   1. Test locally (optional): cd $PROJECT_NAME && cargo test"
echo "   2. Deploy to testnet:"
echo "      paxid tx wasm store $OUTPUT_FILE --from <wallet> --chain-id paxi-testnet-1 ..."
echo ""