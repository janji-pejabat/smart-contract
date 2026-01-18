# 🚀 PANDUAN INSTALL PAXI CONTRACTS VIA GITHUB (TERMUX)

## 📋 **CARA PALING MUDAH - AUTO INSTALL**

### **Step 1: Buka Termux**

```bash
# Update Termux dulu
pkg update && pkg upgrade -y

# Install curl & git (kalau belum ada)
pkg install curl git -y
```

---

### **Step 2: Download & Install (1 Command)**

Ada 2 cara:

#### **CARA A: Via Raw GitHub (Recommended - Paling Cepat)** ⚡

```bash
curl -fsSL https://raw.githubusercontent.com/janji-pejabat/smart-contract/main/install.sh | bash
```

#### **CARA B: Clone Repository Lengkap**

```bash
# Clone repo
git clone https://github.com/janji-pejabat/smart-contract.git

# Masuk folder
cd smart-contract

# Jalankan installer
chmod +x install_all.sh
./install_all.sh
```

---

## 📦 **SETUP REPOSITORY GITHUB (Untuk Creator/Developer)**

Jika Anda yang bikin repository, ini langkah-langkahnya:

### **1. Buat Repository di GitHub**

```bash
# Di browser:
# 1. Buka github.com
# 2. Click "New Repository"
# 3. Nama: smart-contract
# 4. Public/Private: Public
# 5. Create Repository
```

### **2. Upload Script ke GitHub**

```bash
# Di Termux, dari folder smart-contract:

# Init git
git init

# Add semua file
git add .

# Commit
git commit -m "Initial commit - Paxi Smart Contracts Generator"

# Connect ke GitHub
git remote add origin https://github.com/janji-pejabat/smart-contract.git

# Push
git branch -M main
git push -u origin main
```

### **3. Buat Install Script untuk User**

Buat file baru: `install.sh`

```bash
nano install.sh
```

Copy script ini:

```bash
#!/data/data/com.termux/files/usr/bin/bash

# PAXI CONTRACTS - ONE-CLICK INSTALLER
# =====================================

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
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║    ██████╗  █████╗ ██╗  ██╗██╗                      ║
║    ██╔══██╗██╔══██╗╚██╗██╔╝██║                      ║
║    ██████╔╝███████║ ╚███╔╝ ██║                      ║
║    ██╔═══╝ ██╔══██║ ██╔██╗ ██║                      ║
║    ██║     ██║  ██║██╔╝ ██╗██║                      ║
║    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝                      ║
║                                                       ║
║         SMART CONTRACT GENERATOR                     ║
║              One-Click Installer                     ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
LOGO
echo -e "${NC}"

echo -e "${YELLOW}Installing Paxi Smart Contracts Generator...${NC}"
echo ""

# Configuration
REPO_URL="https://github.com/janji-pejabat/smart-contract"
INSTALL_DIR="$HOME/smart-contract"

# Check if already installed
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Paxi contracts already installed at $INSTALL_DIR${NC}"
    read -p "Reinstall? This will delete existing files [y/n]: " REINSTALL
    
    if [ "$REINSTALL" = "y" ]; then
        echo -e "${YELLOW}Removing old installation...${NC}"
        rm -rf "$INSTALL_DIR"
    else
        echo "Installation cancelled."
        exit 0
    fi
fi

# Update Termux
echo -e "${CYAN}[1/5] Updating Termux...${NC}"
pkg update -y >/dev/null 2>&1

# Install dependencies
echo -e "${CYAN}[2/5] Installing dependencies...${NC}"
pkg install -y git curl wget >/dev/null 2>&1

# Clone repository
echo -e "${CYAN}[3/5] Downloading from GitHub...${NC}"
git clone "$REPO_URL" "$INSTALL_DIR"

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to download repository!${NC}"
    echo "Please check your internet connection and repository URL."
    exit 1
fi

cd "$INSTALL_DIR"

# Make scripts executable
echo -e "${CYAN}[4/5] Setting up permissions...${NC}"
chmod +x *.sh

# Run auto-installer
echo -e "${CYAN}[5/5] Installing build tools...${NC}"
echo ""

if [ -f "install_all.sh" ]; then
    ./install_all.sh
else
    echo -e "${YELLOW}Warning: install_all.sh not found.${NC}"
    echo "You may need to install dependencies manually."
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ INSTALLATION COMPLETE!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Installation directory:${NC}"
echo "  $INSTALL_DIR"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo "  cd ~/smart-contract"
echo "  ./check_requirements.sh    # Check if all tools installed"
echo "  ./generate_contracts_smart.sh    # Start building!"
echo ""
echo -e "${YELLOW}Quick start guide:${NC}"
echo "  cat QUICK_GUIDE.txt"
echo ""
echo -e "${GREEN}Happy Building! 🚀${NC}"
```

Save (Ctrl+X, Y, Enter)

### **4. Test Install Script Locally**

```bash
# Test di Termux
chmod +x install.sh
./install.sh
```

### **5. Commit & Push Install Script**

```bash
git add install.sh
git commit -m "Add one-click installer"
git push
```

---

## 🌐 **CARA PAKAI UNTUK USER (SIMPEL!)**

Setelah di-upload ke GitHub, user tinggal jalankan:

```bash
curl -fsSL https://raw.githubusercontent.com/janji-pejabat/smart-contract/main/install.sh | bash
```

**SELESAI!** ✅

---

## 📖 **BUAT README.md di GitHub**

Buat file `README_INSTALL.md` untuk panduan user:

```markdown
# Paxi Smart Contracts - Termux Installation

## 🚀 Quick Install (Termux)

```bash
curl -fsSL https://raw.githubusercontent.com/janji-pejabat/smart-contract/main/install.sh | bash
```

## ✅ After Installation

```bash
cd ~/smart-contract
./check_requirements.sh
./generate_contracts_smart.sh
```

## 📚 Full Documentation

See [README.md](README.md) for complete guide.

## 🆘 Support

- Discord: https://discord.gg/rA9Xzs69tx
- Telegram: https://t.me/paxi_network
```

---

## 🎯 **CONTOH REAL WORLD**

Misal repository Anda: `github.com/paxi-dev/smart-contract`

User tinggal jalankan:

```bash
curl -fsSL https://raw.githubusercontent.com/paxi-dev/smart-contract/main/install.sh | bash
```

Boom! Otomatis:
1. ✅ Download semua script
2. ✅ Install Rust
3. ✅ Install WASM target
4. ✅ Install binaryen
5. ✅ Setup workspace
6. ✅ Siap compile!

---

## 🔒 **SECURITY NOTE**

Untuk user yang hati-hati:

```bash
# Download dulu, baca scriptnya, baru jalankan
curl -fsSL https://raw.githubusercontent.com/paxi-dev/smart-contract/main/install.sh -o install.sh

# Baca isi script
cat install.sh

# Kalau OK, jalankan
bash install.sh
```

---

## 📋 **CHECKLIST UPLOAD KE GITHUB**

- [ ] Buat repository di GitHub
- [ ] Upload semua file .sh
- [ ] Buat install.sh untuk one-click install
- [ ] Test install script
- [ ] Buat README.md dengan instruksi
- [ ] Set repository ke Public
- [ ] Share link ke community!

---

## 💡 **PRO TIP**

Tambahkan di README.md utama:

```markdown
## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/janji-pejabat/smart-contract/main/install.sh | bash
```

One command, everything ready! 🚀
```
