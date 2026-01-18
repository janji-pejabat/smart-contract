# 🚀 PAXI SMART CONTRACTS - TERMUX

Build CosmWasm contracts dari HP Android!

---

## 📋 REQUIREMENTS

- Android 7.0+
- 2GB+ RAM
- 1GB storage free
- Internet stabil

---

## ⚡ INSTALLATION

### 1. Setup Termux

```bash
pkg update && pkg upgrade -y
pkg install curl git -y
```

### 2. Install Everything

```bash
curl -fsSL https://raw.githubusercontent.com/janji-pejabat/smart-contract/main/install.sh | bash
```

Tunggu 10-20 menit (download ~150MB)

### 3. Reload Environment

```bash
source ~/.bashrc
# atau restart Termux
```

### 4. Verify

```bash
check-paxi
```

Output harus:
```
✓ Rust installed
✓ Cargo installed  
✓ wasm32 installed
✓ wasm-opt installed
✓ All ready!
```

---

## 🚀 BUILD CONTRACT

### Generate

```bash
paxi-generate
# Pilih: 1 (LP Lock)
```

### Build

```bash
paxi-build
# Pilih: 1 (LP Lock)
# Tunggu 5-10 menit
```

### Deploy

```bash
paxi-deploy
# Ikuti wizard
```

---

## 🔧 TROUBLESHOOTING

**Out of memory:**
```bash
export CARGO_BUILD_JOBS=1
```

**Rust not found:**
```bash
source $HOME/.cargo/env
```

**Storage full:**
```bash
cargo clean
```

---

## 🆘 HELP

- Discord: https://discord.gg/rA9Xzs69tx
- Telegram: https://t.me/paxi_network

---

**MIT License © 2025**
