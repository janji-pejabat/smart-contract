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

Sebelum generate contracts, setup dulu requirement dasarnya.

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

## DOWNLOAD SCRIPTS

Download script generator dari GitHub:

```bash
# LP Lock Contract
curl -O https://raw.githubusercontent.com/janji-pejabat/repo/main/generate_lp_lock.sh
curl -O https://raw.githubusercontent.com/janji-pejabat/repo/main/build_lp_lock.sh
chmod +x generate_lp_lock.sh build_lp_lock.sh

# Vesting Contract
curl -O https://raw.githubusercontent.com/janji-pejabat/repo/main/generate_vesting.sh
curl -O https://raw.githubusercontent.com/janji-pejabat/repo/main/build_vesting.sh
chmod +x generate_vesting.sh build_vesting.sh
```
---

## GENERATE & BUILD CONTRACTS

### LP Lock Contract

#### Generate

```bash
./generate_lp_lock.sh
```

Script akan generate file-file contract di folder `prc20-lp-lock/`:
- `src/contract.rs`: logic utama dengan security protections
- `src/msg.rs`: message definitions
- `src/state.rs`: state management
- `src/error.rs`: error handling
- `Cargo.toml`: dependencies

#### Build

```bash
./build_lp_lock.sh
```

Proses build ada 3 tahap:
1. Compile ke WASM (5-10 menit first build)
2. Optimize dengan wasm-opt
3. Copy ke folder artifacts

Setelah selesai, file hasil ada di `artifacts/prc20_lp_lock_optimized.wasm`

Build pertama paling lama karena download dependencies (~150MB). Build selanjutnya jauh lebih cepat (2-3 menit).

### Vesting Contract

#### Generate

```bash
./generate_vesting.sh
```

Script akan generate contract di folder `prc20-vesting/` dengan struktur yang sama.

#### Build

```bash
./build_vesting.sh
```

Kalau sudah pernah build LP Lock, build Vesting lebih cepat karena dependencies sudah ada.

File hasil: `artifacts/prc20_vesting_optimized.wasm`

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
cd prc20-lp-lock
cargo clean

# Atau clean semua
rm -rf prc20-*/target/

# Clean cargo global cache (ekstrim, re-download deps next build)
rm -rf ~/.cargo/registry/
```

### Build error: linking failed

Biasanya karena cache corrupt atau dependency conflict.

Solusi:
```bash
# Clean dan rebuild
cd prc20-lp-lock
cargo clean
cd ..
./build_lp_lock.sh
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

## DEPLOYMENT

### Prerequisite

- Sudah punya wallet Paxi
- Sudah install `paxid` CLI
- Ada balance minimal 0.1 PAXI untuk gas fee

### Deploy LP Lock

```bash
# Upload contract
paxid tx wasm store artifacts/prc20_lp_lock_optimized.wasm \
  --from wallet-name \
  --gas 3000000 \
  --fees 15000upaxi \
  --chain-id paxi-testnet-1 \
  --node https://testnet-rpc.paxinet.io:443 \
  --yes

# Catat CODE_ID dari output

# Instantiate
paxid tx wasm instantiate <CODE_ID> '{}' \
  --from wallet-name \
  --label "LP Lock v1.0.0" \
  --admin <your-address> \
  --gas auto \
  --fees 10000upaxi \
  --chain-id paxi-testnet-1 \
  --node https://testnet-rpc.paxinet.io:443 \
  --yes
```

### Deploy Vesting

```bash
# Upload contract
paxid tx wasm store artifacts/prc20_vesting_optimized.wasm \
  --from wallet-name \
  --gas 3000000 \
  --fees 15000upaxi \
  --chain-id paxi-testnet-1 \
  --node https://testnet-rpc.paxinet.io:443 \
  --yes

# Instantiate dengan token address
paxid tx wasm instantiate <CODE_ID> \
  '{"token_addr":"paxi1token..."}' \
  --from wallet-name \
  --label "Vesting v1.0.0" \
  --admin <your-address> \
  --gas auto \
  --fees 10000upaxi \
  --chain-id paxi-testnet-1 \
  --node https://testnet-rpc.paxinet.io:443 \
  --yes
```

Rekomendasi: test di testnet dulu sebelum deploy ke mainnet.

---

## CARA PAKAI CONTRACT

### LP Lock Contract

#### Lock Token by Time

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

#### Lock Token by Block Height

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

#### Unlock Token

```bash
paxid tx wasm execute <contract-address> \
  '{"unlock":{"lock_id":1}}' \
  --from wallet-name \
  --chain-id paxi-testnet-1 \
  --gas auto \
  --fees 5000upaxi
```

#### Query Lock Info

```bash
paxid query wasm contract-state smart <contract-address> \
  '{"lock_info":{
    "owner":"paxi1user...",
    "lock_id":1
  }}' \
  --chain-id paxi-testnet-1
```

#### Query Total Locked

```bash
paxid query wasm contract-state smart <contract-address> \
  '{"total_locked":{
    "token_addr":"paxi1token..."
  }}' \
  --chain-id paxi-testnet-1
```

#### Query All Locks (by Owner)

```bash
paxid query wasm contract-state smart <contract-address> \
  '{"all_locks":{
    "owner":"paxi1user..."
  }}' \
  --chain-id paxi-testnet-1
```

### Vesting Contract

#### Create Vesting Schedule

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

Parameter penjelasan:
- `start_time`: Unix timestamp kapan vesting mulai
- `cliff_duration`: Durasi cliff dalam detik (contoh: 7776000 = 90 hari)
- `vesting_duration`: Total durasi vesting dalam detik (contoh: 31536000 = 1 tahun)

#### Claim Vested Tokens

```bash
paxid tx wasm execute <contract-address> \
  '{"claim":{}}' \
  --from beneficiary-wallet \
  --chain-id paxi-testnet-1 \
  --gas auto \
  --fees 5000upaxi
```

#### Revoke Vesting (Owner Only)

```bash
paxid tx wasm execute <contract-address> \
  '{"revoke_vesting":{
    "beneficiary":"paxi1user..."
  }}' \
  --from owner-wallet \
  --chain-id paxi-testnet-1 \
  --gas auto \
  --fees 5000upaxi
```

Unvested tokens akan dikembalikan ke owner.

#### Query Vesting Info

```bash
paxid query wasm contract-state smart <contract-address> \
  '{"vesting_info":{
    "beneficiary":"paxi1user..."
  }}' \
  --chain-id paxi-testnet-1
```

#### Query Claimable Amount

```bash
paxid query wasm contract-state smart <contract-address> \
  '{"claimable_amount":{
    "beneficiary":"paxi1user..."
  }}' \
  --chain-id paxi-testnet-1
```

#### Query All Vesting Schedules

```bash
paxid query wasm contract-state smart <contract-address> \
  '{"all_vesting":{}}' \
  --chain-id paxi-testnet-1
```

#### Query Contract Config

```bash
paxid query wasm contract-state smart <contract-address> \
  '{"config":{}}' \
  --chain-id paxi-testnet-1
```

---

## STRUKTUR PROJECT

Setelah generate dan build, struktur folder jadi seperti ini:

```
/
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
│   ├── src/
│   │   ├── contract.rs
│   │   ├── msg.rs
│   │   ├── state.rs
│   │   ├── error.rs
│   │   └── lib.rs
│   ├── Cargo.toml
│   └── target/ (build cache, bisa dihapus setelah build)
│
├── artifacts/
│   ├── prc20_lp_lock_optimized.wasm
│   └── prc20_vesting_optimized.wasm
│
├── generate_lp_lock.sh
├── build_lp_lock.sh
├── generate_vesting.sh
└── build_vesting.sh
```

File yang penting:
- `artifacts/*.wasm`: hasil compile, ini yang di-deploy
- `src/*.rs`: source code contracts

File yang bisa dihapus untuk hemat storage:
- `*/target/`: build cache
- `~/.cargo/registry/`: dependencies cache

---

## SECURITY FEATURES

### LP Lock Contract

✅ **Overflow Protection** - Semua operasi arithmetic pakai checked methods  
✅ **Reentrancy Protection** - State update sebelum external call  
✅ **Access Control** - Hanya owner yang bisa unlock token mereka  
✅ **Input Validation** - Validasi amount, time, dan height  
✅ **Double Unlock Prevention** - Flag `is_unlocked` mencegah unlock berkali-kali  
✅ **Safe Math** - Semua addition/subtraction pakai `checked_add/checked_sub`

### Vesting Contract

✅ **Overflow Protection** - Time calculations pakai checked arithmetic  
✅ **Reentrancy Protection** - Update claimed_amount sebelum transfer  
✅ **Access Control** - Only owner bisa create/revoke vesting  
✅ **Revoke Protection** - Owner bisa revoke dan ambil unvested tokens  
✅ **Division by Zero** - Cek total_duration sebelum calculation  
✅ **Duplicate Prevention** - Cek vesting sudah exists atau belum  
✅ **Safe Math** - Semua operasi pakai safe methods

### Rekomendasi Sebelum Mainnet

- Test extensively di testnet
- Code review dengan developer lain
- Audit oleh security expert kalau handle dana besar
- Start dengan amount kecil di mainnet
- Monitor contract activity

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
du -h artifacts/*.wasm
```

Contract yang bagus biasanya di bawah 500KB setelah optimize.

### Clean All Build Cache

```bash
# Clean semua target folders
rm -rf prc20-*/target/

# Clean cargo cache (akan re-download dependencies)
cargo clean
```

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

## LICENSE

MIT © 2025 Paxi Network Contributors
