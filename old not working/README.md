# PAXI SMART CONTRACTS

Tutorial deploy smart contract LP Lock dan Vesting ke Paxi blockchain mainnet menggunakan Termux.

---

## DAFTAR ISI

1. [File WASM Artifacts](#file-wasm-artifacts)
2. [Requirements](#requirements)
3. [Setup Termux](#setup-termux)
4. [Deploy ke Paxi Mainnet](#deploy-ke-paxi-mainnet)
5. [Cara Pakai Contract](#cara-pakai-contract)
6. [Troubleshooting](#troubleshooting)

---

## FILE WASM ARTIFACTS

File WASM sudah di-build dan tersedia di GitHub Actions artifacts:

### Artifacts yang Tersedia

1. **paxi-contracts-release.zip** (132 KB)
   - Berisi: `prc20_lp_lock_optimized.wasm` + `prc20_vesting_optimized.wasm`
   
2. **prc20-lp-lock-wasm.zip** (63.9 KB)
   - Berisi: `prc20_lp_lock_optimized.wasm`
   
3. **prc20-vesting-wasm.zip** (68.4 KB)
   - Berisi: `prc20_vesting_optimized.wasm`

**File sudah di-download dan ada di folder Download HP Anda.**

---

## REQUIREMENTS

### Perangkat
- Android 7.0+
- RAM 2GB minimum
- Storage 500MB kosong
- Koneksi internet

### Yang Diperlukan
- Termux (dari F-Droid)
- Wallet Paxi dengan balance 0.1 PAXI minimum
- File WASM sudah di-download

---

## SETUP TERMUX

### 1. Update & Install Tools

```bash
pkg update && pkg upgrade -y
pkg install curl wget git jq unzip -y
```

### 2. Setup Storage Access

```bash
termux-setup-storage
```

Tekan "Allow" saat popup muncul.

### 3. Buat Folder Kerja

```bash
mkdir -p ~/paxi-deploy
cd ~/paxi-deploy
```

### 4. Copy File WASM dari Download

```bash
# Copy file dari Download ke Termux
cp /storage/emulated/0/Download/paxi-contracts-release.zip .

# Extract
unzip paxi-contracts-release.zip
```

### 5. Verify File

```bash
ls -lh *.wasm
```

Output:
```
prc20_lp_lock_optimized.wasm    ~64K
prc20_vesting_optimized.wasm    ~68K
```

path:
```
/storage/emulated/0/Download/prc20_lp_lock_optimized.wasm
/storage/emulated/0/Download/prc20_vesting_optimized.wasm
```
---

## DEPLOY KE PAXI MAINNET

### Install Paxid CLI

```bash
# Download paxid
wget https://github.com/paxi-web3/paxi/releases/latest/download/paxid-android-arm64 -O paxid
chmod +x paxid

# Move to bin
mkdir -p ~/bin
mv paxid ~/bin/

# Add to PATH
echo 'export PATH=$PATH:~/bin' >> ~/.bashrc
source ~/.bashrc
```

Verify:
```bash
paxid version
```

### Setup Wallet

#### Buat Wallet Baru

```bash
paxid keys add mywallet
```

**⚠️ PENTING: Simpan mnemonic 24 kata dengan AMAN!**

#### Import Wallet

```bash
paxid keys add mywallet --recover
```

#### Cek Address

```bash
paxid keys show mywallet -a
```

#### Cek Balance

```bash
paxid q bank balances $(paxid keys show mywallet -a)
```

### Deploy LP Lock Contract

#### 1. Upload WASM

```bash
paxid tx wasm store prc20_lp_lock_optimized.wasm \
  --from mywallet \
  --gas auto \
  --fees 10000upaxi \
```

Catat **CODE_ID** dari output (contoh: 123)

#### 2. Instantiate Contract

```bash
paxid tx wasm instantiate 123 '{}' \
  --from mywallet \
  --label "LP prc20 Lock v1.0" \
  --admin $(paxid keys show mywallet -a) \
  --gas auto \
  --fees 10000upaxi \
```

Catat **CONTRACT_ADDRESS** (contoh: `paxi14hj2tav...`)

### Deploy Vesting Contract

#### 1. Upload WASM

```bash
paxid tx wasm store prc20_vesting_optimized.wasm \
  --from mywallet \
  --gas auto \
  --fees 15000upaxi
```

Catat CODE_ID (contoh: 124)

#### 2. Instantiate dengan Token Address

```bash
paxid tx wasm instantiate 124 \
  '{"token_addr":"paxi1token..."}' \
  --from mywallet \
  --label "Vesting v1.0" \
  --admin $(paxid keys show mywallet -a) \
  --gas auto \
  --fees 10000upaxi \
```

Ganti `paxi1token...` dengan address token PRC20 Anda.

---

## CARA PAKAI CONTRACT

### LP LOCK CONTRACT

#### Approve Token Dulu

```bash
paxid tx wasm execute paxi12h8e2a7e4de4ksmyvg2tcv0utgkrrezerghyh3kla3czh6axwaaqwfurcf \
  '{
    "increase_allowance": {
      "spender": "paxi1jd28dky85c9akyfpxk983ddwslwn0e4snkpsge27zx3tqlq7dcms8jskwki",
      "amount": "1000000000"
    }
  }' \
  --from mywallet \
  --chain-id paxi-mainnet \
  --gas auto \
  --fees 5000upaxi
```

#### Lock by Time

```bash
paxid tx wasm execute paxi1jd28dky85c9akyfpxk983ddwslwn0e4snkpsge27zx3tqlq7dcms8jskwki \
  '{
    "lock_by_time": {
      "token_addr": "paxi12h8e2a7e4de4ksmyvg2tcv0utgkrrezerghyh3kla3czh6axwaaqwfurcf",
      "amount": "1000000000",
      "unlock_time": 1735689600
    }
  }' \
  --from mywallet \
  --gas auto \
  --fees 5000upaxi
```

Parameter:
- `token_addr`: Address token PRC20
- `amount`: Jumlah token (dalam unit terkecil)
- `unlock_time`: Unix timestamp

Hitung timestamp:
```bash
# Sekarang
date +%s

# 7 hari dari sekarang
echo $(($(date +%s) + 604800))
```

#### Lock by Height

```bash
paxid tx wasm execute paxi14hj2tav... \
  '{
    "lock_by_height": {
      "token_addr": "paxi1token...",
      "amount": "1000000000",
      "unlock_height": 1000000
    }
  }' \
  --from mywallet \
  --chain-id paxi-mainnet \
  --gas auto \
  --fees 5000upaxi
```

Cek current height:
```bash
paxid status --node https://mainnet-rpc.paxinet.io:443 | jq -r .sync_info.latest_block_height
```

#### Unlock Token

```bash
paxid tx wasm execute paxi14hj2tav... \
  '{
    "unlock": {
      "lock_id": 1
    }
  }' \
  --from mywallet \
  --chain-id paxi-mainnet \
  --gas auto \
  --fees 5000upaxi
```

#### Query Lock Info

```bash
paxid query wasm contract-state smart paxi14hj2tav... \
  '{
    "lock_info": {
      "owner": "paxi1your...",
      "lock_id": 1
    }
  }' \
  --chain-id paxi-mainnet \
  --output json | jq
```

#### Query All Locks

```bash
paxid query wasm contract-state smart paxi14hj2tav... \
  '{
    "all_locks": {
      "owner": "paxi1your..."
    }
  }' \
  --chain-id paxi-mainnet \
  --output json | jq
```

#### Query Total Locked

```bash
paxid query wasm contract-state smart paxi14hj2tav... \
  '{
    "total_locked": {
      "token_addr": "paxi1token..."
    }
  }' \
  --chain-id paxi-mainnet \
  --output json | jq
```

### VESTING CONTRACT

#### Approve Token Dulu

```bash
paxid tx wasm execute paxi1token... \
  '{
    "increase_allowance": {
      "spender": "paxi1vesting...",
      "amount": "10000000000"
    }
  }' \
  --from mywallet \
  --chain-id paxi-mainnet \
  --gas auto \
  --fees 5000upaxi
```

#### Create Vesting

```bash
paxid tx wasm execute paxi1vesting... \
  '{
    "create_vesting": {
      "beneficiary": "paxi1user...",
      "total_amount": "10000000000",
      "start_time": 1704067200,
      "cliff_duration": 7776000,
      "vesting_duration": 31536000
    }
  }' \
  --from mywallet \
  --chain-id paxi-mainnet \
  --gas auto \
  --fees 5000upaxi
```

Parameter:
- `beneficiary`: Address penerima
- `total_amount`: Total token
- `start_time`: Unix timestamp mulai
- `cliff_duration`: Durasi cliff (detik)
- `vesting_duration`: Total durasi vesting (detik)

Contoh durasi:
- 90 hari cliff: `7776000`
- 1 tahun vesting: `31536000`

#### Claim Vested Tokens

```bash
paxid tx wasm execute paxi1vesting... \
  '{"claim": {}}' \
  --from beneficiary-wallet \
  --chain-id paxi-mainnet \
  --gas auto \
  --fees 5000upaxi \
```

#### Revoke Vesting (Owner)

```bash
paxid tx wasm execute paxi1vesting... \
  '{
    "revoke_vesting": {
      "beneficiary": "paxi1user..."
    }
  }' \
  --from mywallet \
  --chain-id paxi-mainnet \
  --gas auto \
  --fees 5000upaxi
```

#### Query Vesting Info

```bash
paxid query wasm contract-state smart paxi1vesting... \
  '{
    "vesting_info": {
      "beneficiary": "paxi1user..."
    }
  }' \
  --chain-id paxi-mainnet \
  --output json | jq
```

#### Query Claimable Amount

```bash
paxid query wasm contract-state smart paxi1vesting... \
  '{
    "claimable_amount": {
      "beneficiary": "paxi1user..."
    }
  }' \
  --chain-id paxi-mainnet \
  --output json | jq
```

#### Query All Vesting

```bash
paxid query wasm contract-state smart paxi1vesting... \
  '{"all_vesting": {}}' \
  --chain-id paxi-mainnet \
  --output json | jq
```

#### Query Config

```bash
paxid query wasm contract-state smart paxi1vesting... \
  '{"config": {}}' \
  --chain-id paxi-mainnet \
  --output json | jq
```

---

## TROUBLESHOOTING

### Storage Permission Error

```bash
termux-setup-storage
```

Tekan "Allow" dan tunggu beberapa detik.

### File Not Found

```bash
# Cek file di Download
ls /storage/emulated/0/Download/

# Copy manual jika perlu
cp /storage/emulated/0/Download/paxi-contracts-release.zip ~/paxi-deploy/
```

### Insufficient Fees

```bash
# Tambah fees
--fees 20000upaxi

# Atau auto
--gas auto --gas-adjustment 1.3
```

### Out of Gas

```bash
# Naikkan gas limit
--gas 4000000
```

### Account Sequence Mismatch

Tunggu transaksi sebelumnya selesai, atau:

```bash
paxid query auth account $(paxid keys show mywallet -a) \
  --node https://mainnet-rpc.paxinet.io:443
```

### Unauthorized Error

Pastikan menggunakan wallet yang benar:
- Lock/Unlock: owner yang lock
- Create vesting: owner contract
- Claim: beneficiary
- Revoke: owner contract

### Token Transfer Failed

Approve dulu sebelum lock/vest:

```bash
paxid tx wasm execute paxi1token... \
  '{
    "increase_allowance": {
      "spender": "paxi1contract...",
      "amount": "1000000000"
    }
  }' \
  --from mywallet \
  --chain-id paxi-mainnet \
  --gas auto \
  --fees 5000upaxi
```

### Unlock Failed: Still Locked

Cek kondisi unlock:

```bash
# Cek lock info
paxid query wasm contract-state smart paxi1lplock... \
  '{"lock_info":{"owner":"paxi1...","lock_id":1}}' \
  --chain-id paxi-mainnet \
  --output json | jq

# Current time
date +%s

# Current block
paxid status --node https://mainnet-rpc.paxinet.io:443 | jq -r .sync_info.latest_block_height
```

### Claim Failed: Cliff Not Ended

```bash
# Cek vesting info
paxid query wasm contract-state smart paxi1vesting... \
  '{"vesting_info":{"beneficiary":"paxi1..."}}' \
  --chain-id paxi-mainnet \
  --output json | jq

# Compare cliff_time dengan current time
date +%s
```

### JSON Format Error

Gunakan **snake_case**, bukan camelCase:

✅ Benar:
```json
{"lock_by_time": {"token_addr": "...", "amount": "...", "unlock_time": ...}}
```

❌ Salah:
```json
{"lockByTime": {"tokenAddr": "...", "amount": "...", "unlockTime": ...}}
```

---

## ESTIMASI BIAYA

### Deploy
- Upload contract: 0.015 PAXI
- Instantiate: 0.01 PAXI
- **Total per contract: 0.025 PAXI**

### Operasional
- Lock/Unlock: 0.005 PAXI
- Create vesting: 0.005 PAXI
- Claim: 0.005 PAXI
- Revoke: 0.005 PAXI
- Query: 0 PAXI (gratis)

### Total Setup 2 Contracts
- Deploy 2 contracts: 0.05 PAXI
- 10 test tx: 0.05 PAXI
- **Total: 0.1 PAXI**

**Rekomendasi: Siapkan 0.15-0.2 PAXI**

---

## BUILD FROM SOURCE (OPTIONAL)

Jika ingin build sendiri dari source:

### Install Dependencies

```bash
pkg install rust binaryen -y
```

### Clone Repository

```bash
git clone https://github.com/janji-pejabat/smart-contract
cd smart-contract
```

### Build LP Lock

```bash
./generate_lp_lock.sh
./build_lp_lock.sh
```

### Build Vesting

```bash
./generate_vesting.sh
./build_vesting.sh
```

File hasil ada di `artifacts/`:
- `prc20_lp_lock_optimized.wasm`
- `prc20_vesting_optimized.wasm`

---

## CONTRACT DETAILS

### LP Lock

**Execute Messages:**
- `lock_by_time` - Lock sampai timestamp
- `lock_by_height` - Lock sampai block height
- `unlock` - Unlock token

**Query Messages:**
- `total_locked` - Total locked per token
- `lock_info` - Detail lock
- `all_locks` - Semua lock milik owner

**Security:**
- Overflow protection
- Reentrancy protection
- Access control
- Double unlock prevention

### Vesting

**Execute Messages:**
- `create_vesting` - Create schedule (owner)
- `claim` - Claim vested tokens (beneficiary)
- `revoke_vesting` - Revoke dan ambil unvested (owner)

**Query Messages:**
- `vesting_info` - Detail schedule
- `claimable_amount` - Jumlah bisa claim
- `all_vesting` - Semua schedules
- `config` - Config contract

**Vesting Calculation:**
```
vested = total * (current_time - start_time) / (end_time - start_time)
claimable = vested - claimed
```

**Security:**
- Overflow protection
- Reentrancy protection
- Access control
- Cliff protection
- Revoke protection

---

## RESOURCES

### Official
- Website: https://paxinet.io
- Docs: https://paxinet.io/paxi_docs
- Explorer: https://explorer.paxinet.io
- GitHub: https://github.com/paxi-web3/paxi

### Community
- Discord: https://discord.gg/rA9Xzs69tx
- Telegram: https://t.me/paxi_network
- Twitter: https://twitter.com/paxi_network

### Developer
- Repository: https://github.com/janji-pejabat/smart-contract
- CosmWasm: https://docs.cosmwasm.com
- Cosmos SDK: https://docs.cosmos.network

### Tools
- Unix Timestamp: https://www.unixtimestamp.com
- JSON Validator: https://jsonlint.com

---

## FAQ

**Q: File WASM aman untuk deploy?**  
A: Ya, file sudah di-build dengan optimization dan security best practices.

**Q: Bisa unlock sebelum waktunya?**  
A: Tidak. Contract enforce lock condition secara strict.

**Q: Bisa cancel vesting?**  
A: Owner bisa revoke. Vested tokens tetap bisa di-claim, unvested dikembalikan.

**Q: Berapa gas yang dibutuhkan?**  
A: ~200k gas untuk lock/unlock/create, ~150k untuk claim. Gunakan `--gas auto`.

**Q: Bisa lock multiple tokens?**  
A: Ya. Setiap lock punya ID unik.

**Q: Bisa multiple vesting per beneficiary?**  
A: Tidak. Satu beneficiary = satu schedule aktif.

---

## LICENSE

MIT © 2025 Paxi Network Community

---

## SUPPORT

**Discord:** https://discord.gg/rA9Xzs69tx  
**Telegram:** https://t.me/paxi_network  
**GitHub Issues:** https://github.com/janji-pejabat/smart-contract/issues

---

**Happy building on Paxi! 🚀**