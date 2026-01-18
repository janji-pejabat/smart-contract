#!/data/data/com.termux/files/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${YELLOW}=========================================="
echo "  Building Vesting Contract"
echo "==========================================${NC}"
echo ""

# Cek folder contract ada
if [ ! -d "prc20-vesting" ]; then
    echo -e "${RED}✗ prc20-vesting folder not found!${NC}"
    echo "Run ./generate_vesting.sh first"
    exit 1
fi

cd prc20-vesting

echo -e "${YELLOW}[1/3] Compiling to WASM...${NC}"
cargo build --release --target wasm32-unknown-unknown

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Build failed${NC}"
    cd ..
    exit 1
fi

echo -e "${GREEN}✓ Compile successful${NC}"

# Check wasm-opt
if ! command -v wasm-opt &> /dev/null; then
    echo -e "${RED}✗ wasm-opt not found${NC}"
    echo "Install: pkg install binaryen -y"
    cd ..
    exit 1
fi

WASM_FILE="target/wasm32-unknown-unknown/release/prc20_vesting.wasm"
if [ ! -f "$WASM_FILE" ]; then
    echo -e "${RED}✗ WASM file not found: ${WASM_FILE}${NC}"
    cd ..
    exit 1
fi

SIZE_BEFORE=$(du -h "$WASM_FILE" | cut -f1)
echo -e "${YELLOW}Size before optimize: ${SIZE_BEFORE}${NC}"
echo ""

echo -e "${YELLOW}[2/3] Optimizing with wasm-opt...${NC}"
wasm-opt -Oz \
    target/wasm32-unknown-unknown/release/prc20_vesting.wasm \
    -o prc20_vesting_optimized.wasm

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Optimization failed${NC}"
    cd ..
    exit 1
fi

SIZE_AFTER=$(du -h prc20_vesting_optimized.wasm | cut -f1)
echo -e "${GREEN}✓ Optimized! Size: ${SIZE_AFTER}${NC}"
echo ""

echo -e "${YELLOW}[3/3] Copying to artifacts...${NC}"
cd ..
mkdir -p artifacts
cp prc20-vesting/prc20_vesting_optimized.wasm artifacts/

echo -e "${GREEN}✓ Build complete!${NC}"
echo -e "${GREEN}→ artifacts/prc20_vesting_optimized.wasm (${SIZE_AFTER})${NC}"
echo ""

# Ask to clean cache
read -p "Clean build cache to save storage? [y/n]: " CLEAN_CACHE
if [ "$CLEAN_CACHE" = "y" ] || [ "$CLEAN_CACHE" = "Y" ]; then
    echo -e "${YELLOW}Cleaning cache...${NC}"
    cd prc20-vesting
    cargo clean
    cd ..
    echo -e "${GREEN}✓ Cache cleaned! (~200MB freed)${NC}"
fi

echo ""
echo -e "${BLUE}=========================================="
echo "  Ready to deploy!"
echo "==========================================${NC}"
echo ""
