# 🚀 PAXI SMART CONTRACTS - TERMUX

Build CosmWasm contracts dari HP Android!

---

## ⚠️ INSTALL REQUIREMENTS DULU

**JANGAN langsung curl install!** Setup ini dulu:

### 1. Update Termux

```bash
pkg update && pkg upgrade -y
```

### 2. Install Basic Tools

```bash
pkg install curl git clang binutils binaryen jq bc -y
```

### 3. Install Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Saat ditanya, pilih: **1** (Proceed with installation)

### 4. Load Rust Environment

```bash
source $HOME/.cargo/env
```

Tambahkan ke `.bashrc` agar permanent:

```bash
echo 'source $HOME/.cargo/env' >> ~/.bashrc
```

### 5. Add WASM Target

```bash
rustup target add wasm32-unknown-unknown
```

### 6. Verify Installation

```bash
rustc --version
cargo --version
wasm-opt --version
rustup target list | grep wasm32
```

Output harus:
```
rustc 1.81.0
cargo 1.81.0  
wasm-opt version 116
wasm32-unknown-unknown (installed)
```

---

## ✅ SEKARANG BARU INSTALL PAXI TOOLS

```bash
curl -fsSL https://raw.githubusercontent.com/janji-pejabat/smart-contract/main/install.sh | bash
```

---

## 🚀 USAGE

```bash
# Generate contract
paxi-generate

# Build contract  
paxi-build

# Deploy contract
paxi-deploy
```

---

## 🔧 TROUBLESHOOTING

**Error: rustup not found**
```bash
# Install Rust dulu (lihat step 3-4 di atas)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

**Error: wasm32 not found**
```bash
rustup target add wasm32-unknown-unknown
```

**Error: wasm-opt not found**
```bash
pkg install binaryen -y
```

**Out of memory saat build**
```bash
export CARGO_BUILD_JOBS=1
```

**Storage full**
```bash
cargo clean
rm -rf ~/smart-contract/*/target
```

---

## 📊 BUILD TIME

| RAM | First Build | Next Build |
|-----|-------------|------------|
| 2GB | 10-15 min   | 3-5 min    |
| 4GB | 6-10 min    | 2-3 min    |
| 6GB+| 4-6 min     | 1-2 min    |

---

## 🆘 SUPPORT

- Discord: https://discord.gg/rA9Xzs69tx
- Telegram: https://t.me/paxi_network

---

**MIT © 2025**
