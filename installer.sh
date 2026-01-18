#!/data/data/com.termux/files/usr/bin/bash

# PAXI SMART CONTRACTS - ONE-CLICK INSTALLER
# ===========================================
# Usage: curl -fsSL https://raw.githubusercontent.com/janji-pejabat/smart-contract/main/install.sh | bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${BLUE}"
cat << "LOGO"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║    ██████╗  █████╗ ██╗  ██╗██╗                              ║
║    ██╔══██╗██╔══██╗╚██╗██╔╝██║                              ║
║    ██████╔╝███████║ ╚███╔╝ ██║                              ║
║    ██╔═══╝ ██╔══██║ ██╔██╗ ██║                              ║
║    ██║     ██║  ██║██╔╝ ██╗██║                              ║
║    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝                              ║
║                                                               ║
║         SMART CONTRACT GENERATOR                             ║
║              One-Click Installer for Termux                  ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
LOGO
echo -e "${NC}"

echo -e "${CYAN}Installing Paxi Smart Contracts Generator...${NC}"
echo ""

# Configuration
REPO_URL="https://github.com/janji-pejabat/smart-contract"
INSTALL_DIR="$HOME/paxi-contracts"
BRANCH="main"

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${YELLOW}Warning: This installer is designed for Termux.${NC}"
    echo "Some features may not work in other environments."
    echo ""
    read -p "Continue anyway? [y/n]: " CONTINUE
    if [ "$CONTINUE" != "y" ]; then
        exit 0
    fi
fi

# Check if already installed
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Paxi contracts already installed at $INSTALL_DIR${NC}"
    echo ""
    echo "Options:"
    echo "  1) Update (pull latest changes)"
    echo "  2) Reinstall (delete and fresh install)"
    echo "  3) Cancel"
    echo ""
    read -p "Choice [1-3]: " CHOICE
    
    case $CHOICE in
        1)
            echo -e "${CYAN}Updating existing installation...${NC}"
            cd "$INSTALL_DIR"
            git pull origin $BRANCH
            chmod +x *.sh
            echo -e "${GREEN}✓ Updated successfully!${NC}"
            echo ""
            echo "Run: cd ~/paxi-contracts && ./check_requirements.sh"
            exit 0
            ;;
        2)
            echo -e "${YELLOW}Removing old installation...${NC}"
            rm -rf "$INSTALL_DIR"
            ;;
        3)
            echo "Installation cancelled."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice!${NC}"
            exit 1
            ;;
    esac
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                    INSTALLATION STEPS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Step 1: Update Termux
echo -e "${CYAN}[1/6] Updating Termux packages...${NC}"
pkg update -y >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ Termux updated${NC}"
else
    echo -e "${YELLOW}  ⚠ Update failed, continuing...${NC}"
fi

# Step 2: Install basic dependencies
echo -e "${CYAN}[2/6] Installing basic dependencies...${NC}"
pkg install -y git curl wget >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ Basic tools installed (git, curl, wget)${NC}"
else
    echo -e "${RED}  ✗ Failed to install basic dependencies${NC}"
    exit 1
fi

# Step 3: Clone repository
echo -e "${CYAN}[3/6] Downloading from GitHub...${NC}"
echo -e "${YELLOW}  Repository: $REPO_URL${NC}"

git clone --depth 1 -b $BRANCH "$REPO_URL" "$INSTALL_DIR" >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}  ✗ Failed to download repository!${NC}"
    echo ""
    echo "Possible causes:"
    echo "  • No internet connection"
    echo "  • Repository not found or private"
    echo "  • GitHub is down"
    echo ""
    echo "Try manual installation:"
    echo "  git clone $REPO_URL"
    exit 1
fi

echo -e "${GREEN}  ✓ Repository downloaded to $INSTALL_DIR${NC}"

# Step 4: Setup permissions
echo -e "${CYAN}[4/6] Setting up permissions...${NC}"
cd "$INSTALL_DIR"
chmod +x *.sh
echo -e "${GREEN}  ✓ Scripts made executable${NC}"

# Step 5: Install build dependencies
echo -e "${CYAN}[5/6] Installing build dependencies...${NC}"
echo -e "${YELLOW}  This may take 5-10 minutes...${NC}"

pkg install -y clang binutils binaryen jq bc >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ Build tools installed${NC}"
else
    echo -e "${YELLOW}  ⚠ Some build tools may not be installed${NC}"
fi

# Step 6: Install Rust (if not already installed)
echo -e "${CYAN}[6/6] Checking Rust installation...${NC}"

if command -v rustc >/dev/null 2>&1; then
    RUST_VERSION=$(rustc --version | awk '{print $2}')
    echo -e "${GREEN}  ✓ Rust already installed (${RUST_VERSION})${NC}"
    
    # Check WASM target
    if rustup target list | grep -q "wasm32-unknown-unknown (installed)"; then
        echo -e "${GREEN}  ✓ WASM target already installed${NC}"
    else
        echo -e "${YELLOW}  → Adding WASM target...${NC}"
        rustup target add wasm32-unknown-unknown
        echo -e "${GREEN}  ✓ WASM target added${NC}"
    fi
else
    echo -e "${YELLOW}  Rust not found. Installing...${NC}"
    echo -e "${YELLOW}  This will take 10-15 minutes on average.${NC}"
    echo ""
    
    # Install Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}  ✗ Rust installation failed${NC}"
        echo ""
        echo "Please install Rust manually:"
        echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        echo ""
        echo "Then run the setup again:"
        echo "  cd $INSTALL_DIR && ./install_all.sh"
        exit 1
    fi
    
    # Load Rust environment
    source $HOME/.cargo/env
    
    echo -e "${GREEN}  ✓ Rust installed successfully${NC}"
    
    # Add WASM target
    echo -e "${YELLOW}  → Adding WASM target...${NC}"
    rustup default stable
    rustup target add wasm32-unknown-unknown
    echo -e "${GREEN}  ✓ WASM target added${NC}"
    
    # Add to .bashrc for persistence
    if ! grep -q "source \$HOME/.cargo/env" ~/.bashrc; then
        echo 'source $HOME/.cargo/env' >> ~/.bashrc
        echo -e "${GREEN}  ✓ Added Rust to .bashrc${NC}"
    fi
fi

# Final verification
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                    INSTALLATION COMPLETE!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Run requirements check
if [ -f "$INSTALL_DIR/check_requirements.sh" ]; then
    echo -e "${CYAN}Running system check...${NC}"
    echo ""
    cd "$INSTALL_DIR"
    ./check_requirements.sh
else
    echo -e "${GREEN}✓ Installation successful!${NC}"
fi

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}                         NEXT STEPS${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${CYAN}1. Navigate to installation directory:${NC}"
echo "   cd ~/paxi-contracts"
echo ""

echo -e "${CYAN}2. Verify all requirements are met:${NC}"
echo "   ./check_requirements.sh"
echo ""

echo -e "${CYAN}3. Generate your first contract:${NC}"
echo "   ./generate_contracts_smart.sh"
echo ""

echo -e "${CYAN}4. Read the quick guide:${NC}"
echo "   cat QUICK_GUIDE.txt"
echo ""

echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}📚 Documentation:${NC}"
echo "   README.md - Full documentation"
echo "   QUICK_GUIDE.txt - Quick reference"
echo ""

echo -e "${YELLOW}🆘 Need Help?${NC}"
echo "   Discord: https://discord.gg/rA9Xzs69tx"
echo "   Telegram: https://t.me/paxi_network"
echo ""

echo -e "${GREEN}Happy Building! 🚀${NC}"
echo ""

# If Rust was just installed, remind to reload shell
if ! command -v rustc >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ IMPORTANT: Restart Termux or run:${NC}"
    echo "   source ~/.bashrc"
    echo "   (This loads Rust into your environment)"
    echo ""
fi
