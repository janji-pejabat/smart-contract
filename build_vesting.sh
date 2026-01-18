#!/usr/bin/env bash
# build_vesting.sh - Build script for Vesting contract

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${BLUE}=========================================="
echo "  VESTING CONTRACT BUILD"
echo "==========================================${NC}"

if [ ! -d "contracts/prc20-vesting" ]; then
    echo -e "${RED}✗ Contract folder not found!${NC}"
    echo "Run ./generate_vesting.sh first"
    exit 1
fi

if ! command -v cargo &> /dev/null; then
    echo -e "${RED}✗ Rust tidak ditemukan!${NC}"
    exit 1
fi

if ! command -v wasm-opt &> /dev/null; then
    echo -e "${RED}✗ wasm-opt tidak ditemukan!${NC}"
    echo "Install: pkg install binaryen -y"
    exit 1
fi

echo -e "${GREEN}✓ Build tools OK${NC}"
echo ""

cd contracts/prc20-vesting

echo -e "${CYAN}[1/3] Compiling to WASM...${NC}"
RUSTFLAGS='-C link-arg=-s' cargo build --release --target wasm32-unknown-unknown

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Compilation failed!${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}[2/3] Optimizing with wasm-opt...${NC}"
wasm-opt -Oz --enable-sign-ext target/wasm32-unknown-unknown/release/prc20_vesting.wasm \
    -o target/wasm32-unknown-unknown/release/prc20_vesting_optimized.wasm

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Optimization failed!${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}[3/3] Creating artifacts...${NC}"
mkdir -p ../../artifacts
cp target/wasm32-unknown-unknown/release/prc20_vesting_optimized.wasm \
    ../../artifacts/

cd ../..

SIZE=$(du -h artifacts/prc20_vesting_optimized.wasm | cut -f1)

echo ""
echo -e "${GREEN}=========================================="
echo "  ✓ BUILD SUCCESS!"
echo "==========================================${NC}"
echo -e "Contract: ${CYAN}prc20_vesting_optimized.wasm${NC}"
echo -e "Location: ${CYAN}artifacts/${NC}"
echo -e "Size:     ${CYAN}${SIZE}${NC}"
echo ""
echo -e "${YELLOW}Ready to deploy!${NC}"