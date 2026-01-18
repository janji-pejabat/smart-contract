#!/usr/bin/env bash
# build_lp_lock.sh - Build secure version

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${GREEN}=========================================="
echo "  LP LOCK SECURE v2.0.0 - BUILD"
echo "  Production-Ready with Audit Fixes"
echo "==========================================${NC}"

PROJECT_DIR="contracts/prc20-lp-lock"

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}✗ Contract folder not found!${NC}"
    echo -e "${YELLOW}Run ./generate_lp_lock.sh first${NC}"
    exit 1
fi

if ! command -v cargo &> /dev/null; then
    echo -e "${RED}✗ Rust not found!${NC}"
    exit 1
fi

if ! command -v wasm-opt &> /dev/null; then
    echo -e "${YELLOW}⚠ wasm-opt not found - will skip optimization${NC}"
    SKIP_OPT=1
fi

echo -e "${GREEN}✓ Build tools OK${NC}"
echo ""

cd "$PROJECT_DIR"

echo -e "${CYAN}[1/4] Running tests...${NC}"
cargo test

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠ Tests failed - continue anyway? (y/n)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo -e "${CYAN}[2/4] Compiling to WASM...${NC}"
RUSTFLAGS='-C link-arg=-s' cargo build --release --target wasm32-unknown-unknown

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Compilation failed!${NC}"
    exit 1
fi

if [ -z "$SKIP_OPT" ]; then
    echo ""
    echo -e "${CYAN}[3/4] Optimizing with wasm-opt...${NC}"
    wasm-opt -Oz --enable-sign-ext \
        target/wasm32-unknown-unknown/release/prc20_lp_lock.wasm \
        -o target/wasm32-unknown-unknown/release/prc20_lp_lock_optimized.wasm

    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Optimization failed!${NC}"
        exit 1
    fi
    FINAL_WASM="prc20_lp_lock_optimized.wasm"
else
    echo -e "${YELLOW}[3/4] Skipping optimization${NC}"
    FINAL_WASM="prc20_lp_lock.wasm"
fi

echo ""
echo -e "${CYAN}[4/4] Creating artifacts...${NC}"
mkdir -p ../../artifacts
cp target/wasm32-unknown-unknown/release/$FINAL_WASM ../../artifacts/

# Generate checksum
cd ../../artifacts
sha256sum $FINAL_WASM > ${FINAL_WASM}.sha256
cd ..

SIZE=$(du -h artifacts/$FINAL_WASM | cut -f1)
CHECKSUM=$(cat artifacts/${FINAL_WASM}.sha256 | cut -d' ' -f1)

echo ""
echo -e "${GREEN}=========================================="
echo "  ✅ BUILD SUCCESS!"
echo "==========================================${NC}"
echo -e "Contract:  ${CYAN}$FINAL_WASM${NC}"
echo -e "Location:  ${CYAN}artifacts/${NC}"
echo -e "Size:      ${CYAN}${SIZE}${NC}"
echo -e "SHA256:    ${CYAN}${CHECKSUM:0:16}...${NC}"
echo ""
echo -e "${BLUE}Security Features:${NC}"
echo "  ✅ Emergency unlock safety delay (3 days)"
echo "  ✅ LP token whitelist enforcement"
echo "  ✅ Lock extension support"
echo "  ✅ Proper event emission"
echo "  ✅ Migration support"
echo "  ✅ Enhanced reentrancy protection"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Test on testnet (minimum 2 weeks)"
echo "  2. Approve Paxi LP tokens after deployment"
echo "  3. Optional: External security audit"
echo "  4. Deploy to mainnet"
echo ""
echo -e "${CYAN}Deployment Command:${NC}"
echo "  paxid tx wasm store artifacts/$FINAL_WASM \\"
echo "    --from admin --gas auto --gas-adjustment 1.3"
echo ""