# 🚀 Complete Usage Guide - Paxi LP Lock Secure

- **Versi 2**: **DEPLOYED** di blockchain Paxi
  - Contract Address: `paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e`
  - Lock Counter: 3 (sudah ada 3 lock aktif)
  - Admin: `paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz`
  - 
Verified Working Version: https://github.com/janji-pejabat/smart-contract/commit/edb5fe6f2ee92782eb7af89f601e66fd525b375f

## 📑 Table of Contents
1. [Quick Start](#quick-start)
2. [Developer Guide](#developer-guide)
3. [Admin Guide](#admin-guide)
4. [User Guide](#user-guide)
5. [Troubleshooting](#troubleshooting)

---

## ⚡ Quick Start

### Step 1: Generate Contract (PILIH SALAH SATU)

**Option A: Secure Version (RECOMMENDED) ✅**
```bash
# 1. Buat file generator
cat > generate_lp_lock_secure.sh << 'EOF'
[paste content dari artifact generate_lp_lock_secure.sh]
EOF

# 2. Set permission
chmod +x generate_lp_lock_secure.sh

# 3. Generate
./generate_lp_lock_secure.sh
```

**Option B: Original Version (NOT RECOMMENDED) ❌**
```bash
chmod +x generate_paxi_lp_lock_final.sh
./generate_paxi_lp_lock_final.sh
```

### Step 2: Build Contract

```bash
# 1. Buat build script
cat > build_lp_lock_secure.sh << 'EOF'
[paste content dari artifact build_lp_lock_secure.sh]
EOF

# 2. Set permission
chmod +x build_lp_lock_secure.sh

# 3. Build
./build_lp_lock_secure.sh
```

### Step 3: Verify Output

```bash
# Check artifacts
ls -lh artifacts/

# Should see:
# prc20_lp_lock_secure_optimized.wasm
# prc20_lp_lock_secure_optimized.wasm.sha256
```

---

## 👨‍💻 Developer Guide

### Installation & Setup

#### Prerequisites
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Add WASM target
rustup target add wasm32-unknown-unknown

# Install optimizer tools
cargo install cosmwasm-check
pkg install binaryen -y  # For wasm-opt
```

#### Project Structure
```
your-project/
├── contracts/
│   └── prc20-lp-lock-secure/
│       ├── src/
│       │   ├── contract.rs      # Main logic
│       │   ├── state.rs         # Storage
│       │   ├── msg.rs           # Messages
│       │   ├── error.rs         # Errors
│       │   ├── events.rs        # Events
│       │   ├── paxi.rs          # Paxi integration
│       │   └── lib.rs
│       └── Cargo.toml
├── artifacts/                    # Compiled WASM
├── generate_lp_lock_secure.sh
└── build_lp_lock_secure.sh
```

### Development Workflow

#### 1. Generate Contract
```bash
./generate_lp_lock_secure.sh
```

Output:
```
==========================================
  LP LOCK CONTRACT - SECURE VERSION
  ✅ Security Audit Fixes Applied
  ✅ Paxi Native Integration
  ✅ Industry Standards Compliant
==========================================
✓ Requirements OK

✓ SECURE LP Lock Contract Generated!

Security Improvements:
  ✅ Emergency unlock with 3-day safety delay
  ✅ LP token whitelist (approve/revoke)
  ✅ Lock extension feature
  ✅ Proper event emission for indexing
  ✅ Unlock allowed even when paused
  ✅ Migration support for upgrades
  ✅ Paxi network integration ready
```

#### 2. Build & Test
```bash
cd contracts/prc20-lp-lock-secure

# Run tests
cargo test

# Build for production
cd ../..
./build_lp_lock_secure.sh
```

Output:
```
==========================================
  LP LOCK SECURE v2.0.0 - BUILD
  Production-Ready with Audit Fixes
==========================================
✓ Build tools OK

[1/4] Running tests...
running 0 tests
test result: ok. 0 passed

[2/4] Compiling to WASM...
   Compiling prc20-lp-lock-secure v2.0.0
    Finished release [optimized]

[3/4] Optimizing with wasm-opt...
[wasm-validator] all checks passed

[4/4] Creating artifacts...

==========================================
  ✅ BUILD SUCCESS!
==========================================
Contract:  prc20_lp_lock_secure_optimized.wasm
Location:  artifacts/
Size:      145K
SHA256:    a3f5c8d9e2b1f4a6...

Security Features:
  ✅ Emergency unlock safety delay (3 days)
  ✅ LP token whitelist enforcement
  ✅ Lock extension support
  ✅ Proper event emission
  ✅ Migration support
  ✅ Enhanced reentrancy protection
```

#### 3. Verify Contract
```bash
# Check WASM validity
cosmwasm-check artifacts/prc20_lp_lock_secure_optimized.wasm

# Check size (should be < 800KB)
ls -lh artifacts/prc20_lp_lock_secure_optimized.wasm

# Verify checksum
sha256sum -c artifacts/prc20_lp_lock_secure_optimized.wasm.sha256
```

---

## 🔐 Admin Guide

### Deployment

#### 1. Deploy to Testnet

```bash
# Store WASM
paxid tx wasm store artifacts/prc20_lp_lock_secure_optimized.wasm \
  --from admin \
  --gas auto \
  --gas-adjustment 1.3 \
  --chain-id paxi-testnet-1 \
  --node https://rpc-testnet.paxi.network:443 \
  --broadcast-mode block \
  -y

# Get CODE_ID from output
CODE_ID=123
```

#### 2. Instantiate Contract

```bash
# Instantiate
CODE_ID=10
INIT_MSG='{"admin":"paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz","min_lock_duration":86400,"emergency_unlock_delay":259200}'

paxid tx wasm instantiate $CODE_ID "$INIT_MSG" \
  --from mywallet \
  --label "LP Lock Secure v2.0.0" \
  --admin paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz \
  --gas auto \
  --gas-adjustment 1.3 \
  --fees 3000000upaxi \
  --yes
  
# Get CONTRACT_ADDRESS from output
CONTRACT=paxi1contract...
```
***Cara memastikan transaksi sukses
Setelah execute, cek:***

Salin kode

```bash
paxid q tx AEC916FA3D5DCE32BFB92EA5277D6A76431F7C5CFC7D12527F86A3D8C470BDC6
```
atau cek saldo untuk melihat fee terpotong.
```bash
# Cek saldo wallet kamu (biar tahu fee sudah terpotong)
paxid q bank balances $(paxid keys show mywallet -a)
```


***Cara paling aman cek contract kamu***
Salin kode
```bash
paxid query wasm list-contract-by-code 10
```
Kalau hasilnya muncul alamat contract, berarti deploy berhasil.


#### 3. Initial Configuration

```bash
# Save contract address
echo "export LP_LOCK_CONTRACT=paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e" >> ~/.bashrc
source ~/.bashrc

# Verify deployment
paxid query wasm contract $LP_LOCK_CONTRACT
```

### Post-Deployment Setup

#### 1. Approve LP Tokens

```bash
# Get Paxi LP token addresses
# Example: PAXI-TOKEN LP
LP_TOKEN="paxi12h8e2a7e4de4ksmyvg2tcv0utgkrrezerghyh3kla3czh6axwaaqwfurcf"

LP_LOCK_CONTRACT="paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e"

paxid tx wasm execute $LP_LOCK_CONTRACT \
  '{
    "approve_lp_token": {
      "token": "'"${LP_TOKEN}"'"
    }
  }' \
  --from mywallet \
  --gas auto \
  --gas-adjustment 1.3 \
  --fees 30000upaxi \
  -y
  
paxid query wasm contract-state smart $LP_LOCK_CONTRACT \
  '{
    "approved_tokens": {
      "limit": 10
    }
  }'
```

#### 2. Configure Parameters

```bash
# Update config (optional)
LP_LOCK_CONTRACT="paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e"
paxid tx wasm execute $LP_LOCK_CONTRACT \
  '{
    "update_config": {
      "min_lock_duration": 604800,
      "emergency_unlock_delay": 259200
    }
  }' \
  --from admin \
  --gas auto \
  -y

# Verify config
paxid query wasm contract-state smart $LP_LOCK_CONTRACT \
  '{"config":{}}'
```

### Admin Operations

#### Approve Additional LP Tokens
```bash
LP_LOCK_CONTRACT="paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e"
paxid tx wasm execute $LP_LOCK_CONTRACT \
  '{
    "approve_lp_token": {
      "token": "paxi1newlp..."
    }
  }' \
  --from admin -y
```

#### Revoke LP Token
```bash
LP_LOCK_CONTRACT="paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e"
paxid tx wasm execute $LP_LOCK_CONTRACT \
  '{
    "revoke_lp_token": {
      "token": "paxi1badlp..."
    }
  }' \
  --from admin -y
```

#### Emergency Unlock (With 3-day Delay)
```bash
LP_LOCK_CONTRACT="paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e"
# Only works if current_time >= unlock_time - 3 days
paxid tx wasm execute $LP_LOCK_CONTRACT \
  '{
    "emergency_unlock": {
      "owner": "paxi1user...",
      "lock_id": 1
    }
  }' \
  --from admin -y
```

#### Pause Contract (New Locks Only)
```bash
LP_LOCK_CONTRACT="paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e"
# Pause
paxid tx wasm execute $LP_LOCK_CONTRACT \
  '{"pause":{}}' \
  --from admin -y

# Unpause
paxid tx wasm execute $LP_LOCK_CONTRACT \
  '{"unpause":{}}' \
  --from admin -y
```

---

## 👤 User Guide

### For End Users

#### Step 1: Get LP Tokens from Paxi

```bash
# Add liquidity on Paxi Swap
paxid tx wasm execute paxi1mfru9azs5nua2wxcd4sq64g5nt7nn4n80r745t \
  '{
    "add_liquidity": {
      "assets": [
        {
          "info": {"native_token": {"denom": "upaxi"}},
          "amount": "1000000"
        },
        {
          "info": {"native_token": {"denom": "nml"}},
          "amount": "1000000"
        }
      ],
      "slippage_tolerance": "0.01"
    }
  }' \
  --from user \
  --amount 1000000upaxi \
  --gas auto \
  -y

# You receive LP tokens: paxi1lp...
```

#### Step 2: Lock LP Tokens

```bash
LP_TOKEN="paxi12h8e2a7e4de4ksmyvg2tcv0utgkrrezerghyh3kla3czh6axwaaqwfurcf"

LP_LOCK_CONTRACT="paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e"

# Unlock time 1 jam dari sekarang TIDAK BISA karena min_lock_duration = 86400
# Jadi harus minimal 86400 detik (24 jam)
UNLOCK_TIME=$(($(date +%s) + 86400 + 1000))
# Encode lock message
LOCK_MSG=$(echo '{
  "lock_lp": {
    "unlock_time": '$UNLOCK_TIME'
  }
}' | base64 -w0)

# Lock LP tokens
paxid tx wasm execute $LP_TOKEN \
  '{
    "send": {
      "contract": "'$LP_LOCK_CONTRACT'",
      "amount": "1000000000",
      "msg": "'$LOCK_MSG'"
    }
  }' \
  --from mywallet \
  --gas auto \
  --fees 30000upaxi \
  -y
```

Output will show:
```json
{
  "events": [
    {
      "type": "lp_locked",
      "attributes": [
        {"key": "lock_id", "value": "1"},
        {"key": "owner", "value": "paxi1user..."},
        {"key": "lp_token", "value": "paxi1lp..."},
        {"key": "amount", "value": "1000000"},
        {"key": "unlock_time", "value": "1738886400"}
      ]
    }
  ]
}
```


### ** Apakah Contract Bisa Di-Update? 🔄**

**TERGANTUNG** pada bagaimana Anda deploy contract:

#### **A. Jika Contract Punya Migration Support:**

Dari kode yang Anda upload (line 848-861), contract **SUDAH ADA** migration support:

```rust
#[entry_point]
pub fn migrate(deps: DepsMut, _env: Env, _msg: MigrateMsg) -> Result<Response, ContractError> {
    let version = get_contract_version(deps.storage)?;
    if version.contract != CONTRACT_NAME {
        return Err(ContractError::Unauthorized {});
    }
    
    set_contract_version(deps.storage, CONTRACT_NAME, CONTRACT_VERSION)?;
    
    Ok(Response::new()
        .add_attribute("action", "migrate")
        .add_attribute("from_version", version.version)
        .add_attribute("to_version", CONTRACT_VERSION))
}
```

**✅ Bisa update JIKA:**
1. Contract di-instantiate dengan `--admin <your_address>`
2. Admin address = address Anda

**Cara update:**

```bash
# 1. Build contract versi baru
cd contracts/prc20-lp-lock
cargo build --release --target wasm32-unknown-unknown
docker run --rm -v "$(pwd)":/code cosmwasm/optimizer:0.15.0

# 2. Store new code
paxid tx wasm store artifacts/prc20_lp_lock.wasm \
  --from your-wallet \
  --gas auto -y

# Dapat NEW_CODE_ID

# 3. Migrate contract
paxid tx wasm migrate \
  paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e \
  <NEW_CODE_ID> \
  '{}' \
  --from your-wallet \
  --gas auto -y
```

#### **B. Cek Apakah Anda Admin:**
Check status:
```bash
paxid q wasm contract-state smart paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e '{"config":{}}'

# Response akan tampilkan:
# {
#   "admin": "paxi1...",  ← Cek ini
#   "min_lock_duration": ...,
#   ...
# }
```
#### **C. Cek Contract Info:**
```bash
paxid q wasm contract paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e

# Response:
# contract_info:
#   admin: paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz
#   code_id: "10"
#   created:
#     block_height: "3251721"
#     tx_index: "0"
#   creator: paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz
#   extension: null
#   ibc_port_id: ""
#   label: LP Lock Secure v2.0.0
```

## 🔧 **ACTION ITEMS:**

#### Step 3: Check Lock Status

```bash
# 1. Verify lock berhasil
LP_LOCK_CONTRACT="paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e"
# Query your lock
paxid query wasm contract-state smart $LP_LOCK_CONTRACT \
  '{
    "lock_info": {
      "owner": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
      "lock_id": 1
    }
  }'
```

Response:
```json
{
  "lock": {
    "lock_id": 1,
    "owner": "paxi1user...",
    "lp_token": "paxi1lp...",
    "lp_amount": "1000000",
    "unlock_time": 1738886400,
    "locked_at": 1736294400,
    "is_unlocked": false
  }
}
```

```bash
LP_LOCK_CONTRACT="paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e"
# 2. Check actual LP token balance (bukan position)
paxid q wasm contract-state smart $LP_LOCK_CONTRACT \
  '{"balance":{
    "address":"paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz"
  }}'

# 3. Check if you're admin
paxid q wasm contract paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e
```


#### Step 4: Extend Lock (Optional)

```bash
LP_LOCK_CONTRACT="paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e"
# Extend to 60 days total
NEW_UNLOCK=$(($(date +%s) + 5184000))

paxid tx wasm execute $LP_LOCK_CONTRACT \
  '{
    "extend_lock": {
      "lock_id": 1,
      "new_unlock_time": '$NEW_UNLOCK'
    }
  }' \
  --from user \
  --gas auto \
  -y
```

#### Step 5: Unlock After Time Expires

```bash
LP_LOCK_CONTRACT="paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e"
# Check current time vs unlock time
CURRENT=$(date +%s)
paxid query wasm contract-state smart $LP_LOCK_CONTRACT \
  '{"lock_info":{"owner":"paxi1user...","lock_id":1}}' \
  | jq '.lock.unlock_time'

# If time >= unlock_time, unlock:
paxid tx wasm execute $LP_LOCK_CONTRACT \
  '{
    "unlock_lp": {
      "lock_id": 1
    }
  }' \
  --from user \
  --gas auto \
  -y

# LP tokens returned to your wallet!
```

#### Step 6: View All Your Locks

```bash
LP_LOCK_CONTRACT="paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e"
paxid query wasm contract-state smart $LP_LOCK_CONTRACT \
  '{
    "all_locks": {
      "owner": "paxi1user...",
      "limit": 10
    }
  }'
```

---

## 🔧 Advanced Usage

### Using JavaScript/TypeScript

```typescript
import { SigningCosmWasmClient } from "@cosmjs/cosmwasm-stargate";

// Connect to Paxi
const client = await SigningCosmWasmClient.connectWithSigner(
  "https://rpc.paxi.network",
  wallet
);

// Lock LP tokens
const lockMsg = {
  send: {
    contract: LP_LOCK_CONTRACT,
    amount: "1000000",
    msg: Buffer.from(JSON.stringify({
      lock_lp: {
        unlock_time: Math.floor(Date.now() / 1000) + 2592000
      }
    })).toString('base64')
  }
};

const result = await client.execute(
  userAddress,
  lpTokenAddress,
  lockMsg,
  "auto"
);

console.log("Lock ID:", result.events
  .find(e => e.type === "lp_locked")
  ?.attributes.find(a => a.key === "lock_id")?.value
);

// Query lock
const lockInfo = await client.queryContractSmart(
  LP_LOCK_CONTRACT,
  {
    lock_info: {
      owner: userAddress,
      lock_id: 1
    }
  }
);

// Unlock
const unlockResult = await client.execute(
  userAddress,
  LP_LOCK_CONTRACT,
  {
    unlock_lp: { lock_id: 1 }
  },
  "auto"
);
```

### Batch Operations

```bash
# Lock multiple amounts in one go
for AMOUNT in 100000 200000 300000; do
  UNLOCK_TIME=$(($(date +%s) + 2592000))
  LOCK_MSG=$(echo '{"lock_lp":{"unlock_time":'$UNLOCK_TIME'}}' | base64 -w0)
  
  paxid tx wasm execute $LP_TOKEN \
    '{"send":{"contract":"'$LP_LOCK_CONTRACT'","amount":"'$AMOUNT'","msg":"'$LOCK_MSG'"}}' \
    --from user --gas auto -y
  
  sleep 6
done
```

### Query Statistics

```bash
LP_LOCK_CONTRACT="paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e"
# Total locks in system
paxid query wasm contract-state smart $LP_LOCK_CONTRACT \
  '{"total_locks":{}}'

# Result:
{
  "total_locks": 150,
  "active_locks": 120,
  "unlocked_locks": 30
}

# All approved tokens
paxid query wasm contract-state smart $LP_LOCK_CONTRACT \
  '{"approved_tokens":{"limit":30}}'
```

---

## 🐛 Troubleshooting

### Common Errors

#### Error: "Token not approved"
```
Solution: LP token belum di-approve oleh admin

Fix:
1. Contact admin to approve your LP token
2. Or verify you're using correct LP token address
```

#### Error: "Lock duration too short"
```
Solution: Unlock time terlalu dekat

Fix:
UNLOCK_TIME=$(($(date +%s) + 86400))  # Minimum 1 day
```

#### Error: "Tokens still locked"
```
Solution: Belum waktunya unlock

Check:
paxid query wasm contract-state smart $LP_LOCK_CONTRACT \
  '{"lock_info":{"owner":"'$USER'","lock_id":1}}' \
  | jq '.lock.unlock_time'

Current time: date +%s
```

#### Error: "Contract paused"
```
Solution: Contract di-pause untuk lock baru

Note: Unlock tetap bisa dilakukan!

Unlock:
paxid tx wasm execute $LP_LOCK_CONTRACT \
  '{"unlock_lp":{"lock_id":1}}' --from user -y
```

### Debug Commands

```bash
LP_LOCK_CONTRACT="paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e"
# Check contract info
paxid query wasm contract $LP_LOCK_CONTRACT

# Check contract state
paxid query wasm contract-state all $LP_LOCK_CONTRACT

# Check specific storage
paxid query wasm contract-state raw $LP_LOCK_CONTRACT \
  $(echo -n "config" | xxd -p)

# View transaction details
paxid query tx <TX_HASH>
```

---

## 📊 Monitoring & Analytics

### Track Your Locks

```bash
# Create monitoring script
cat > monitor_locks.sh << 'EOF'
#!/bin/bash
USER="paxi1your..."
CONTRACT="paxi1contract..."

while true; do
  clear
  echo "=== LP Lock Monitor ==="
  date
  echo ""
  
  # Get all locks
  paxid query wasm contract-state smart $CONTRACT \
    '{"all_locks":{"owner":"'$USER'","limit":10}}' \
    | jq -r '.locks[] | "\(.lock_id): \(.lp_amount) locked until \(.unlock_time) [\(if .is_unlocked then "UNLOCKED" else "ACTIVE" end)]"'
  
  sleep 30
done
EOF

chmod +x monitor_locks.sh
./monitor_locks.sh
```

### Event Listener

```typescript
// Subscribe to lock events
const ws = new WebSocket("wss://rpc.paxi.network/websocket");

ws.on('open', () => {
  ws.send(JSON.stringify({
    jsonrpc: "2.0",
    method: "subscribe",
    id: 1,
    params: {
      query: `tm.event='Tx' AND wasm.action='lock_lp'`
    }
  }));
});

ws.on('message', (data) => {
  const event = JSON.parse(data);
  console.log("New LP Lock:", event);
});
```

---

## 📚 Quick Reference

### Common Commands

```bash
LP_TOKEN="paxi1ee6eaha77veuwpzgpe875yrmz2k45zyquqn9sztjv2w5h9gke02q65crh6"

LP_LOCK_CONTRACT="paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e"
# Lock LP
paxid tx wasm execute $LP_TOKEN '{"send":{"contract":"'$LP_LOCK_CONTRACT'","amount":"1000000","msg":"<base64>"}}' --from user -y

# Unlock LP
paxid tx wasm execute $LP_LOCK_CONTRACT '{"unlock_lp":{"lock_id":1}}' --from user -y

# Extend Lock
paxid tx wasm execute $LP_LOCK_CONTRACT '{"extend_lock":{"lock_id":1,"new_unlock_time":<timestamp>}}' --from user -y

# Check Status
paxid query wasm contract-state smart $LP_LOCK_CONTRACT '{"lock_info":{"owner":"<addr>","lock_id":1}}'

# View Config
paxid query wasm contract-state smart $LP_LOCK_CONTRACT '{"config":{}}'
```

### Time Calculations

```bash
# 1 day = 86400 seconds
# 7 days = 604800 seconds  
# 30 days = 2592000 seconds
# 90 days = 7776000 seconds

# Lock for 30 days
UNLOCK=$(($(date +%s) + 2592000))

# Lock until specific date
UNLOCK=$(date -d "2026-12-31" +%s)
```

---

## ✅ Checklist

### Before Mainnet
- [ ] Tested all functions on testnet
- [ ] Verified LP tokens approved
- [ ] Checked min_lock_duration (86400)
- [ ] Verified emergency_delay (259200)
- [ ] Documented approved LP tokens
- [ ] Set up monitoring
- [ ] Backup admin keys
- [ ] Multi-sig admin (recommended)

### Regular Monitoring
- [ ] Check active locks weekly
- [ ] Monitor events
- [ ] Review approved tokens
- [ ] Check for anomalies
- [ ] Update documentation

---

**Need Help?** Check the audit report or security comparison document for more details!