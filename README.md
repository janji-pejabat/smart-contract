# PAXI SMART CONTRACTS - TERMUX

Build CosmWasm contracts langsung dari HP Android pake Termux.

---

## REQUIREMENTS

- Android 7.0 ke atas
- RAM minimal 2GB (rekomendasi 4GB)
- Storage kosong minimal 1GB
- Koneksi internet stabil

---

## PERSIAPAN AWAL

Sebelum install tools Paxi, setup dulu requirement dasarnya.

### Update Termux

```bash
pkg update && pkg upgrade -y
```

Proses ini download update package Termux. Tunggu sampai selesai.

### Install Build Tools

```bash
pkg install curl git clang binutils binaryen jq bc -y
```

Package yang diinstall:
- curl: download files
- git: version control
- clang: C compiler
- binutils: binary utilities
- binaryen: WebAssembly optimizer (wasm-opt)
- jq: JSON processor
- bc: calculator untuk script

### Install Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Saat muncul pilihan:
```
1) Proceed with installation (default)
2) Customize installation
3) Cancel installation
```

Ketik angka 1, tekan Enter.

Proses install Rust biasanya 5-10 menit tergantung koneksi internet.

### Load Rust ke Environment

Setelah install Rust selesai:

```bash
source $HOME/.cargo/env
```

Agar permanent tiap buka Termux:

```bash
echo 'source $HOME/.cargo/env' >> ~/.bashrc
```

### Install WASM Target

```bash
rustup target add wasm32-unknown-unknown
```

Target ini diperlukan untuk compile contract ke WebAssembly format.

### Verifikasi Semua Terinstall

Cek satu-satu:

```bash
rustc --version
```
Output: `rustc 1.81.0` atau versi terbaru

```bash
cargo --version
```
Output: `cargo 1.81.0` atau versi terbaru

```bash
wasm-opt --version
```
Output: `wasm-opt version 116` atau versi terbaru

```bash
rustup target list | grep wasm32
```
Output harus ada: `wasm32-unknown-unknown (installed)`

Kalau semua command di atas berhasil, lanjut ke step berikutnya.

---

## INSTALL PAXI TOOLS

Sekarang baru install script generator dan builder:

```bash
curl -fsSL https://raw.githubusercontent.com/janji-pejabat/smart-contract/main/install.sh | bash
```

Script ini akan:
- Download semua script generator
- Setup command shortcut
- Verifikasi environment

Tunggu sampai muncul:
```
Installation complete!
Ready to build Paxi contracts!
```

Restart Termux atau reload environment:

```bash
source ~/.bashrc
```

---

## CARA PAKAI

### Generate Contract

```bash
paxi-generate
```

Menu yang muncul:
```
Pilih contract yang ingin di-generate:

  1) LP Lock saja (recommended untuk mulai)
  2) Vesting saja
  3) Keduanya (akan pakai shared dependencies)
  4) Exit
```

Untuk pertama kali, pilih 1 (LP Lock).

Script akan generate file-file contract di folder `prc20-lp-lock/`:
- `src/contract.rs`: logic utama
- `src/msg.rs`: message definitions
- `src/state.rs`: state management
- `src/error.rs`: error handling
- `Cargo.toml`: dependencies

### Build Contract

```bash
paxi-build
```

Menu yang muncul:
```
Pilih contract yang ingin di-build:

  1) LP Lock saja
  2) Vesting saja
  3) Keduanya (sequential, hemat memory)
  4) Exit
```

Pilih 1 untuk build LP Lock.

Proses build ada 3 tahap:
1. Compile ke WASM (5-10 menit first build)
2. Optimize dengan wasm-opt
3. Copy ke folder artifacts

Setelah selesai, file hasil ada di `artifacts/prc20_lp_lock_optimized.wasm`

Build pertama paling lama karena download dependencies (~150MB). Build selanjutnya jauh lebih cepat (2-3 menit).

Saat ditanya clean cache:
```
Clean build cache untuk hemat storage? [y/n]:
```

Ketik `y` kalau mau hemat storage (~200MB). File WASM hasil build tetap aman di folder artifacts.

### Deploy Contract

```bash
paxi-deploy
```

Prerequisite untuk deploy:
- Sudah punya wallet Paxi
- Sudah install `paxid` CLI
- Ada balance minimal 0.1 PAXI untuk gas fee

Wizard akan tanya:
1. Nama wallet
2. Pilih network (testnet/mainnet)
3. Konfirmasi deploy

Rekomendasi: test di testnet dulu sebelum deploy ke mainnet.

---

## TROUBLESHOOTING

### Error: rustup command not found

Rust belum terinstall atau belum di-load ke environment.

Solusi:
```bash
# Cek apakah Rust sudah terinstall
ls ~/.cargo/bin/

# Kalau ada file rustup, cargo, rustc berarti sudah terinstall
# Tinggal load environment
source $HOME/.cargo/env

# Kalau folder tidak ada, install Rust dulu
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### Error: wasm32-unknown-unknown not installed

Target WASM belum ditambahkan.

Solusi:
```bash
rustup target add wasm32-unknown-unknown
```

### Error: wasm-opt not found

Binaryen belum terinstall.

Solusi:
```bash
pkg install binaryen -y
```

### Out of memory saat build

HP kehabisan RAM saat compile.

Solusi:
```bash
# Limit parallel compilation
export CARGO_BUILD_JOBS=1

# Tutup aplikasi lain
# Restart Termux
# Build ulang
paxi-build
```

Atau buat swap file (butuh storage lebih):
```bash
cd ~
dd if=/dev/zero of=swapfile bs=1M count=512
chmod 600 swapfile
mkswap swapfile
swapon swapfile
```

Cek swap aktif:
```bash
free -h
```

### Storage penuh

Build cache Rust bikin storage penuh.

Solusi:
```bash
# Clean cache contract tertentu
cd ~/smart-contract/prc20-lp-lock
cargo clean

# Atau clean semua
cd ~/smart-contract
rm -rf */target/

# Clean cargo global cache (ekstrim, re-download deps next build)
rm -rf ~/.cargo/registry/
```

### Build error: linking failed

Biasanya karena cache corrupt atau dependency conflict.

Solusi:
```bash
# Clean dan rebuild
cd ~/smart-contract/prc20-lp-lock
cargo clean
cd ..
paxi-build
```

### Command not found: paxi-generate / paxi-build / paxi-deploy

Shortcut command belum ke-load.

Solusi:
```bash
# Reload bashrc
source ~/.bashrc

# Atau restart Termux

# Kalau masih error, cek apakah file script ada
ls ~/smart-contract/

# Jalankan langsung tanpa shortcut
cd ~/smart-contract
./generate_contracts_smart.sh
./build_smart.sh
./deploy_smart.sh
```

---

## ESTIMASI WAKTU

### First Build (dengan download dependencies)

RAM 2GB: 10-15 menit  
RAM 4GB: 6-10 menit  
RAM 6GB+: 4-6 menit

### Subsequent Build (dependencies sudah ada)

RAM 2GB: 3-5 menit  
RAM 4GB: 2-3 menit  
RAM 6GB+: 1-2 menit

### Deploy ke Network

Upload contract: 30-60 detik  
Instantiate: 10-20 detik  
Total: ~2-3 menit

---

## PENGGUNAAN STORAGE

Source code contract: ~50KB  
Rust dependencies: ~150MB (shared)  
Build cache per contract: ~200MB  
Final WASM optimized: ~400KB

Total yang diperlukan: 500MB - 1GB

Tips hemat storage:
- Build satu contract dulu, clean cache, baru build yang lain
- Hapus folder target setelah dapat file WASM
- Jangan install terlalu banyak contract sekaligus

---

## CARA PAKAI CONTRACT

### Lock Token by Time

```bash
paxid tx wasm execute <contract-address> \
  '{"lock_by_time":{
    "token_addr":"paxi1token...",
    "amount":"1000000000",
    "unlock_time":1735689600
  }}' \
  --from wallet-name \
  --chain-id paxi-testnet-1 \
  --gas auto \
  --fees 5000upaxi
```

### Lock Token by Block Height

```bash
paxid tx wasm execute <contract-address> \
  '{"lock_by_height":{
    "token_addr":"paxi1token...",
    "amount":"1000000000",
    "unlock_height":1000000
  }}' \
  --from wallet-name \
  --chain-id paxi-testnet-1 \
  --gas auto \
  --fees 5000upaxi
```

### Unlock Token

```bash
paxid tx wasm execute <contract-address> \
  '{"unlock":{"lock_id":1}}' \
  --from wallet-name \
  --chain-id paxi-testnet-1 \
  --gas auto \
  --fees 5000upaxi
```

### Query Lock Info

```bash
paxid query wasm contract-state smart <contract-address> \
  '{"lock_info":{
    "owner":"paxi1user...",
    "lock_id":1
  }}' \
  --chain-id paxi-testnet-1
```

### Query Total Locked

```bash
paxid query wasm contract-state smart <contract-address> \
  '{"total_locked":{
    "token_addr":"paxi1token..."
  }}' \
  --chain-id paxi-testnet-1
```

### Create Vesting Schedule

```bash
paxid tx wasm execute <contract-address> \
  '{"create_vesting":{
    "beneficiary":"paxi1user...",
    "total_amount":"10000000000",
    "start_time":1704067200,
    "cliff_duration":7776000,
    "vesting_duration":31536000
  }}' \
  --from wallet-name \
  --chain-id paxi-testnet-1 \
  --gas auto \
  --fees 5000upaxi
```

### Claim Vested Tokens

```bash
paxid tx wasm execute <contract-address> \
  '{"claim":{}}' \
  --from beneficiary-wallet \
  --chain-id paxi-testnet-1 \
  --gas auto \
  --fees 5000upaxi
```

---

## STRUKTUR PROJECT

Setelah generate dan build, struktur folder jadi seperti ini:

```
smart-contract/
├── prc20-lp-lock/
│   ├── src/
│   │   ├── contract.rs
│   │   ├── msg.rs
│   │   ├── state.rs
│   │   ├── error.rs
│   │   └── lib.rs
│   ├── Cargo.toml
│   └── target/ (build cache, bisa dihapus setelah build)
│
├── prc20-vesting/
│   └── (struktur sama dengan LP Lock)
│
├── artifacts/
│   ├── prc20_lp_lock_optimized.wasm
│   └── prc20_vesting_optimized.wasm
│
├── generate_contracts_smart.sh
├── build_smart.sh
├── deploy_smart.sh
├── check_requirements.sh
└── deployment_info.txt
```

File yang penting:
- `artifacts/*.wasm`: hasil compile, ini yang di-deploy
- `deployment_info.txt`: catatan contract yang sudah di-deploy

File yang bisa dihapus untuk hemat storage:
- `*/target/`: build cache
- `~/.cargo/registry/`: dependencies cache

---

## TIPS & TRICKS

### Build Lebih Cepat

```bash
# Enable incremental compilation
export CARGO_INCREMENTAL=1

# Tapi pakai lebih banyak storage
```

### Hemat Memory

```bash
# Limit parallel jobs
export CARGO_BUILD_JOBS=1

# Build satu-satu, jangan sekaligus
```

### Monitor Progress Build

```bash
# Build dengan output verbose
cd prc20-lp-lock
RUST_LOG=debug cargo build --release --target wasm32-unknown-unknown
```

### Test Contract Locally (Tanpa Deploy)

```bash
cd prc20-lp-lock
cargo test
```

### Update Rust

```bash
rustup update stable
```

### Cek Size Contract

```bash
ls -lh artifacts/
du -h artifacts/prc20_lp_lock_optimized.wasm
```

Contract yang bagus biasanya di bawah 500KB setelah optimize.

---

## SECURITY NOTES

Contract ini sudah implement:
- Checked math operations (no overflow)
- Re-entrancy protection
- Input validation
- Access control

Tapi tetap lakukan audit sebelum deploy ke mainnet dengan dana besar.

Rekomendasi:
- Test extensively di testnet
- Code review dengan developer lain
- Audit oleh security expert kalau handle dana besar
- Start dengan amount kecil di mainnet

---

## RESOURCES

Dokumentasi:
- Paxi Network: https://paxinet.io
- Paxi Docs: https://docs.paxinet.io
- CosmWasm Docs: https://docs.cosmwasm.com

Tools:
- Explorer: https://ping.pub/paxi
- Testnet Faucet: (tanya di Discord)

Community:
- Discord: https://discord.gg/rA9Xzs69tx
- Telegram: https://t.me/paxi_network

---
