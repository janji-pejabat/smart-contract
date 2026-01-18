#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${BLUE}=========================================="
echo "  PAXI CONTRACTS INSTALLER"
echo "  Download All Scripts from GitHub"
echo "==========================================${NC}"
echo ""

# GitHub base URL
GITHUB_RAW="https://raw.githubusercontent.com/janji-pejabat/smart-contract/main"

# Buat folder kerja
WORK_DIR="$HOME/paxi-contracts"
echo -e "${YELLOW}Creating work directory: ${WORK_DIR}${NC}"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo ""
echo -e "${CYAN}Downloading scripts...${NC}"
echo ""

# Download LP Lock scripts
echo -e "${YELLOW}[1/4] LP Lock Generator...${NC}"
curl -fsSL "${GITHUB_RAW}/generate_lp_lock.sh" -o generate_lp_lock.sh
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ generate_lp_lock.sh${NC}"
else
    echo -e "${RED}✗ Failed to download generate_lp_lock.sh${NC}"
    exit 1
fi

echo -e "${YELLOW}[2/4] LP Lock Builder...${NC}"
curl -fsSL "${GITHUB_RAW}/build_lp_lock.sh" -o build_lp_lock.sh
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ build_lp_lock.sh${NC}"
else
    echo -e "${RED}✗ Failed to download build_lp_lock.sh${NC}"
    exit 1
fi

# Download Vesting scripts
echo -e "${YELLOW}[3/4] Vesting Generator...${NC}"
curl -fsSL "${GITHUB_RAW}/generate_vesting.sh" -o generate_vesting.sh
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ generate_vesting.sh${NC}"
else
    echo -e "${RED}✗ Failed to download generate_vesting.sh${NC}"
    exit 1
fi

echo -e "${YELLOW}[4/4] Vesting Builder...${NC}"
curl -fsSL "${GITHUB_RAW}/build_vesting.sh" -o build_vesting.sh
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ build_vesting.sh${NC}"
else
    echo -e "${RED}✗ Failed to download build_vesting.sh${NC}"
    exit 1
fi

# Set executable
echo ""
echo -e "${CYAN}Setting permissions...${NC}"
chmod +x *.sh
echo -e "${GREEN}✓ All scripts are executable${NC}"

echo ""
echo -e "${GREEN}=========================================="
echo "  Installation Complete!"
echo "==========================================${NC}"
echo ""
echo -e "${CYAN}Location: ${WORK_DIR}${NC}"
echo ""
echo -e "${YELLOW}Available commands:${NC}"
echo "  ./generate_lp_lock.sh  - Generate LP Lock contract"
echo "  ./build_lp_lock.sh     - Build LP Lock contract"
echo "  ./generate_vesting.sh  - Generate Vesting contract"
echo "  ./build_vesting.sh     - Build Vesting contract"
echo ""
echo -e "${CYAN}Quick start:${NC}"
echo "  cd ${WORK_DIR}"
echo "  ./generate_lp_lock.sh"
echo ""
echo -e "${GREEN}Ready to build Paxi contracts! 🚀${NC}"
echo ""
