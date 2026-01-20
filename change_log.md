# Dokumentasi Perbedaan LP Lock Contract V1 vs V2

## Status Deployment
- **Versi 1**: Belum deployed
- **Versi 2**: **DEPLOYED** di blockchain Paxi
  - Contract Address: `paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e`
  - Lock Counter: 3 (sudah ada 3 lock aktif)
  - Admin: `paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz`

---

## Ringkasan Perubahan

Versi 1 adalah versi simplified dari Versi 2. Menghilangkan whitelist token, emergency delay, dan beberapa fitur keamanan untuk kemudahan penggunaan.

---

## Tabel Perubahan Execute Messages

| Execute Message | V2 (Production) | V1 (Simplified) | Perubahan |
|----------------|-----------------|-----------------|-----------|
| `receive` (CW20) | ✅ | ✅ | V1 hapus pengecekan whitelist |
| `unlock_lp` | ✅ | ✅ | Sama |
| `emergency_unlock` | ✅ | ✅ | V1 hapus delay 3 hari |
| `pause` | ✅ | ✅ | Sama |
| `unpause` | ✅ | ✅ | Sama |
| `update_config` | ✅ | ✅ | V1 hapus parameter emergency_delay |
| `extend_lock` | ✅ | ❌ | **DIHAPUS** di V1 |
| `approve_lp_token` | ✅ | ❌ | **DIHAPUS** di V1 |
| `revoke_lp_token` | ✅ | ❌ | **DIHAPUS** di V1 |

---

## Tabel Perubahan Query Messages

| Query Message | V2 (Production) | V1 (Simplified) | Perubahan |
|--------------|-----------------|-----------------|-----------|
| `config` | ✅ | ✅ | Response structure berbeda |
| `lock_info` | ✅ | ✅ | Sama |
| `all_locks` | ✅ | ✅ | Sama |
| `total_locks` | ✅ | ✅ | Sama |
| `approved_tokens` | ✅ | ❌ | **DIHAPUS** di V1 |

---

## Detail Perubahan Krusial

### 1. Instantiate Message

**Versi 2 (Production):**
```json
{
  "admin": "paxi1...",
  "min_lock_duration": 86400,
  "emergency_unlock_delay": 259200
}
```

**Versi 1 (Simplified):**
```json
{
  "admin": "paxi1...",
  "min_lock_duration": 86400
}
```

**Perbedaan:** Parameter `emergency_unlock_delay` dihapus di V1.

---

### 2. Config Query Response

**Versi 2 (Production):**
```json
{
  "admin": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
  "min_lock_duration": 86400,
  "emergency_unlock_delay": 259200,
  "paused": false,
  "lock_counter": 3
}
```

**Versi 1 (Simplified):**
```json
{
  "admin": "paxi1abc...",
  "min_lock_duration": 86400,
  "paused": false,
  "lock_counter": 5
}
```

**Breaking Change:** Field `emergency_unlock_delay` tidak ada di V1.

---

### 3. Lock LP Flow

**Versi 2 (Production - Current):**
```bash
# Admin WAJIB approve token dulu
paxid tx wasm execute paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e '{
  "approve_lp_token": {
    "token": "<LP_TOKEN>"
  }
}' --from paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz

# Baru user bisa lock
paxid tx wasm execute <LP_TOKEN> '{
  "send": {
    "contract": "paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e",
    "amount": "1000000",
    "msg": "base64_encoded_lock_msg"
  }
}'
```

**Versi 1 (Simplified):**
```bash
# User kirim LP token langsung berhasil (TIDAK perlu approve)
paxid tx wasm execute <LP_TOKEN> '{
  "send": {
    "contract": "<LOCK_CONTRACT>",
    "amount": "1000000",
    "msg": "base64_encoded_lock_msg"
  }
}'
```

**Breaking Change:** V1 menerima semua CW20 token tanpa validasi.

---

### 4. Emergency Unlock

**Versi 2 (Production):**
```bash
# Admin hanya bisa unlock jika sudah mencapai:
# unlock_time - 259200 detik (3 hari sebelum unlock)

paxid tx wasm execute paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e '{
  "emergency_unlock": {
    "owner": "paxi1user...",
    "lock_id": 1
  }
}' --from paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz

# Jika belum 3 hari sebelum unlock_time: Error EmergencyTooEarly
```

**Versi 1 (Simplified):**
```bash
# Admin bisa unlock KAPAN SAJA tanpa delay
paxid tx wasm execute <LOCK_CONTRACT> '{
  "emergency_unlock": {
    "owner": "paxi1user...",
    "lock_id": 1
  }
}' --from admin
```

**Breaking Change:** V1 menghilangkan safety delay emergency unlock.

---

### 5. Update Config

**Versi 2 (Production):**
```json
{
  "update_config": {
    "admin": "paxi1new...",
    "min_lock_duration": 172800,
    "emergency_unlock_delay": 432000
  }
}
```

**Versi 1 (Simplified):**
```json
{
  "update_config": {
    "admin": "paxi1new...",
    "min_lock_duration": 172800
  }
}
```

---

## Fitur yang Dihapus di V1

### 1. Extend Lock (Dihapus)
**V2 punya:**
```json
{
  "extend_lock": {
    "lock_id": 1,
    "new_unlock_time": 1735689600
  }
}
```

**V1:** Fitur ini tidak ada. User harus unlock kemudian lock ulang.

---

### 2. Approve/Revoke LP Token (Dihapus)

**V2 punya:**
```json
{
  "approve_lp_token": {
    "token": "paxi1lp..."
  }
}
```
```json
{
  "revoke_lp_token": {
    "token": "paxi1lp..."
  }
}
```

**V1:** Whitelist system dihapus sepenuhnya.

---

### 3. Query Approved Tokens (Dihapus)

**V2 punya:**
```json
{
  "approved_tokens": {
    "start_after": "paxi1abc...",
    "limit": 30
  }
}
```

**V1:** Query ini tidak ada.

---

## Error Messages yang Dihapus di V1

| Error (V2) | Status di V1 |
|------------|--------------|
| `TokenNotApproved` | ❌ Dihapus (terima semua token) |
| `EmergencyTooEarly` | ❌ Dihapus (no delay) |
| `InvalidExtension` | ❌ Dihapus (no extend feature) |
| `InvalidPaxiLpToken` | ❌ Dihapus |

V1 hanya punya error dasar: Unauthorized, LockNotFound, TokensStillLocked, AlreadyUnlocked, LockDurationTooShort, InvalidAmount, ContractPaused, Overflow, ReentrancyDetected.

---

## Perubahan Event Structure

**Versi 2 (Production):**
```rust
Response::new()
    .add_event(Event::new("lp_locked")
        .add_attribute("lock_id", "1")
        .add_attribute("owner", "paxi1...")
        .add_attribute("lp_token", "paxi1lp...")
        .add_attribute("amount", "1000000")
        .add_attribute("unlock_time", "1735689600"))
    .add_attribute("action", "lock_lp")
```

**Versi 1 (Simplified):**
```rust
Response::new()
    .add_attribute("action", "lock_lp")
    .add_attribute("lock_id", "1")
    .add_attribute("owner", "paxi1...")
    .add_attribute("lp_token", "paxi1lp...")
    .add_attribute("lp_amount", "1000000")
    .add_attribute("unlock_time", "1735689600")
```

**Breaking Change:** V1 kembali ke simple attributes tanpa structured events.

---

## File Structure Changes

**Versi 2 (Production):**
```
src/
├── contract.rs
├── error.rs
├── events.rs    
├── lib.rs
├── msg.rs
├── paxi.rs      
└── state.rs
```

**Versi 1 (Simplified):**
```
src/
├── contract.rs
├── error.rs
├── lib.rs
├── msg.rs
└── state.rs
```

**File dihapus:**
- `events.rs`: Event helper functions
- `paxi.rs`: Paxi network integration

---

## State Storage Changes

### APPROVED_LP_TOKENS (Ada di V2, dihapus di V1)

**V2:**
```rust
pub const APPROVED_LP_TOKENS: Map<Addr, bool> = Map::new("approved_lp_tokens");
```

**V1:** Storage ini tidak ada.

---

## Migration Support

**Versi 2 (Production):** Ada migrate entry point
```rust
#[entry_point]
pub fn migrate(deps: DepsMut, _env: Env, _msg: MigrateMsg) 
    -> Result<Response, ContractError>
```

**Versi 1 (Simplified):** Tidak ada migrate entry point

---

## Cara Cek Versi Contract di Blockchain

### 1. Query Contract Info
```bash
paxid query wasm contract paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e
```

Output:
```json
{
  "address": "paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e",
  "contract_info": {
    "code_id": "XXX",
    "creator": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
    "admin": "paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz",
    "label": "...",
    "created": {...}
  }
}
```

---

### 2. Query Contract Version (cw2)
```bash
paxid query wasm contract-state smart paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e \
  '{"contract_info":{}}'
```

Output expected (jika implement cw2):
```json
{
  "contract": "paxi:lp-lock",
  "version": "2.0.0"
}
```

---

### 3. Test Config Query (CONFIRMED V2)

```bash
paxid q wasm contract-state smart paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e '{"config":{}}'
```

Output:
```yaml
data:
  admin: paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz
  emergency_unlock_delay: 259200  # ← HANYA ADA DI V2
  lock_counter: 3
  min_lock_duration: 86400
  paused: false
```

**Konfirmasi:** Contract yang deployed adalah **VERSI 2**.

---

### 4. Test Approved Tokens Query

```bash
paxid query wasm contract-state smart paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e \
  '{"approved_tokens":{"limit":10}}'
```

**Expected V2:** Return list tokens  
**Expected V1:** Error query not found

---

### 5. Download & Compare WASM
```bash
# Get code_id dari contract info
CODE_ID=$(paxid query wasm contract paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e | jq -r '.contract_info.code_id')

# Download wasm
paxid query wasm code $CODE_ID download.wasm

# Hash check
sha256sum download.wasm

# Compare dengan build V2
cd contracts/prc20-lp-lock
cargo build --release --target wasm32-unknown-unknown
sha256sum target/wasm32-unknown-unknown/release/prc20_lp_lock.wasm
```

---

## Compatibility Matrix

| Komponen | V2 → V1 Compatible | Notes |
|----------|-------------------|-------|
| User Lock LP | ✅ | V1 lebih permisif (terima semua token) |
| User Unlock LP | ✅ | API sama |
| Query Lock Info | ✅ | Response sama |
| Query All Locks | ✅ | Response sama |
| Query Config | ❌ | V1 tidak punya emergency_unlock_delay |
| Emergency Unlock | ⚠️ | V1 langsung unlock tanpa delay |
| Extend Lock | ❌ | V1 tidak punya fitur ini |
| Approve Token | ❌ | V1 tidak punya whitelist |
| Frontend Integration | ⚠️ | Perlu conditional check |
| Indexer/Explorer | ❌ | Event structure berbeda |

---

## Production Contract Status (V2)

```bash
# Query locks yang sudah ada
paxid q wasm contract-state smart paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e '{"total_locks":{}}'
```

**Current State:**
- Total locks created: 3
- Admin: paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz
- Min lock duration: 86400 seconds (1 hari)
- Emergency unlock delay: 259200 seconds (3 hari)
- Status: Active (not paused)

---

## Checklist Jika Deploy V1

Jika ingin deploy V1 sebagai contract terpisah:

- [ ] Build V1 contract
- [ ] Deploy V1 contract (code_id baru)
- [ ] Instantiate V1 tanpa emergency_unlock_delay
- [ ] **Tidak perlu** approve LP tokens (terima semua)
- [ ] Test lock flow (harusnya lebih simple)
- [ ] Test emergency unlock (langsung bisa tanpa delay)
- [ ] Dokumentasi perbedaan dengan V2 production
- [ ] Inform users: V1 = simplified, V2 = secure

**Catatan:** V2 sudah production dengan 3 locks aktif. Deploy V1 berarti ada 2 contract berbeda di network.

---

## Version Detection Script

```bash
#!/bin/bash

check_version() {
    local CONTRACT=$1
    
    echo "Checking contract: $CONTRACT"
    echo "================================"
    
    # Test config query
    CONFIG=$(paxid q wasm contract-state smart $CONTRACT '{"config":{}}' 2>&1)
    
    if echo "$CONFIG" | grep -q "emergency_unlock_delay"; then
        echo "✅ Version: V2 (Production/Secure)"
        echo "Features:"
        echo "  - Whitelist LP tokens"
        echo "  - Emergency delay: 3 days"
        echo "  - Extend lock support"
        echo "  - Migration support"
        
        # Extract details
        echo ""
        echo "$CONFIG" | grep -E "admin|emergency_unlock_delay|lock_counter|min_lock_duration|paused"
        
        # Test approved tokens
        echo ""
        echo "Testing approved_tokens query..."
        paxid q wasm contract-state smart $CONTRACT '{"approved_tokens":{"limit":3}}' 2>&1 | head -5
        
    else
        echo "✅ Version: V1 (Simplified)"
        echo "Features:"
        echo "  - Accept all CW20 tokens"
        echo "  - Instant emergency unlock"
        echo "  - No extend lock"
        echo "  - No migration"
        
        echo ""
        echo "$CONFIG"
    fi
}

# Check production contract
check_version "paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e"
```

**Hasil untuk contract production:**
```
✅ Version: V2 (Production/Secure)
Features:
  - Whitelist LP tokens
  - Emergency delay: 3 days
  - Extend lock support
  - Migration support

  admin: paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz
  emergency_unlock_delay: 259200
  lock_counter: 3
  min_lock_duration: 86400
  paused: false
```

---

# Analisis Fitur Admin vs User

## Fitur yang HANYA Admin yang Bisa Lakukan

### Versi 2 (Production - Deployed)

| Fitur | Kode Validasi | Bisa Dipakai User? |
|-------|---------------|-------------------|
| **approve_lp_token** | `if info.sender != config.admin` | ❌ TIDAK |
| **revoke_lp_token** | `if info.sender != config.admin` | ❌ TIDAK |
| **emergency_unlock** | `if info.sender != config.admin` | ❌ TIDAK |
| **pause** | `if info.sender != config.admin` | ❌ TIDAK |
| **unpause** | `if info.sender != config.admin` | ❌ TIDAK |
| **update_config** | `if info.sender != config.admin` | ❌ TIDAK |

**Kode Validasi di Contract:**
```rust
fn execute_approve_token(
    deps: DepsMut,
    info: MessageInfo,
    token: String,
) -> Result<Response, ContractError> {
    let config = CONFIG.load(deps.storage)?;
    
    if info.sender != config.admin {  // ← VALIDASI ADMIN
        return Err(ContractError::Unauthorized {});
    }
    // ...
}
```

---

### Versi 1 (Simplified - Belum Deployed)

| Fitur | Kode Validasi | Bisa Dipakai User? |
|-------|---------------|-------------------|
| **emergency_unlock** | `if info.sender != config.admin` | ❌ TIDAK |
| **pause** | `if info.sender != config.admin` | ❌ TIDAK |
| **unpause** | `if info.sender != config.admin` | ❌ TIDAK |
| **update_config** | `if info.sender != config.admin` | ❌ TIDAK |

---

## Fitur yang Bisa Dipakai User (Non-Admin)

### Versi 2 (Production)

| Fitur | Validasi | Siapa yang Bisa? |
|-------|----------|------------------|
| **lock_lp** (via receive) | Token harus approved | ✅ SEMUA USER |
| **unlock_lp** | Harus pemilik lock | ✅ PEMILIK LOCK |
| **extend_lock** | Harus pemilik lock | ✅ PEMILIK LOCK |
| **Query semua** | Tidak ada validasi | ✅ SEMUA ORANG |

**Kode Validasi Ownership:**
```rust
fn execute_unlock_lp(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    lock_id: u64,
) -> Result<Response, ContractError> {
    let mut lock = LOCKS
        .may_load(deps.storage, (info.sender.clone(), lock_id))?  // ← info.sender = user
        .ok_or(ContractError::LockNotFound {})?;
    
    // User hanya bisa unlock miliknya sendiri
    // Karena key storage: (owner_address, lock_id)
}
```

---

### Versi 1 (Simplified)

| Fitur | Validasi | Siapa yang Bisa? |
|-------|----------|------------------|
| **lock_lp** (via receive) | Terima semua token | ✅ SEMUA USER |
| **unlock_lp** | Harus pemilik lock | ✅ PEMILIK LOCK |
| **Query semua** | Tidak ada validasi | ✅ SEMUA ORANG |

---

## Apakah Admin Bisa Pakai Fitur User?

**JAWABAN: YA**

Admin adalah address biasa di blockchain, jadi admin **BISA**:

```bash
# Admin bisa lock LP seperti user biasa
paxid tx wasm execute <LP_TOKEN> '{
  "send": {
    "contract": "paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e",
    "amount": "1000000",
    "msg": "..."
  }
}' --from paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz  # ← admin address

# Admin bisa unlock LP miliknya sendiri
paxid tx wasm execute paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e '{
  "unlock_lp": {
    "lock_id": 1
  }
}' --from paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz

# Admin bisa extend lock miliknya
paxid tx wasm execute paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e '{
  "extend_lock": {
    "lock_id": 1,
    "new_unlock_time": 1735689600
  }
}' --from paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz
```

**Tidak ada kode yang melarang admin menggunakan fitur user.**

---

## Batasan Admin

### Yang TIDAK Bisa Dilakukan Admin:

❌ **Unlock LP milik user lain** (kecuali pakai emergency_unlock dengan delay)
```rust
// Ini GAGAL - admin tidak bisa unlock LP milik user123
let lock = LOCKS
    .may_load(deps.storage, (user123_address, lock_id))?  // ← Key pakai user123, bukan admin
    .ok_or(ContractError::LockNotFound {})?;
```

❌ **Extend lock milik user lain**
```rust
// Sama seperti unlock, key storage pakai owner address
```

❌ **Transfer ownership lock** (tidak ada fitur ini)

❌ **Pause lalu curi token** (pause hanya block lock baru, unlock tetap bisa)

---

## Emergency Unlock: Satu-satunya Cara Admin Akses Lock User

### Versi 2 (Production):
```bash
paxid tx wasm execute paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e '{
  "emergency_unlock": {
    "owner": "paxi1user123...",
    "lock_id": 5
  }
}' --from paxi15ntap5eh9yv79re3l3eeyps99d53m4dxfnj6dz
```

**Batasan:**
- Hanya bisa dilakukan **3 hari sebelum unlock_time**
- Token tetap dikirim ke **owner asli**, bukan admin

```rust
// Token dikirim ke owner, BUKAN admin
let transfer_msg = WasmMsg::Execute {
    contract_addr: updated_lock.lp_token.to_string(),
    msg: to_json_binary(&cw20::Cw20ExecuteMsg::Transfer {
        recipient: owner_addr.to_string(),  // ← owner asli
        amount: updated_lock.lp_amount,
    })?,
    funds: vec![],
};
```

### Versi 1 (Simplified):
```bash
# Admin bisa emergency unlock KAPAN SAJA tanpa delay
```

**Batasan:**
- Token tetap ke owner asli

---

## Ringkasan Matrix

| Aksi | Admin | User Biasa | Notes |
|------|-------|------------|-------|
| Lock LP sendiri | ✅ | ✅ | Sama |
| Unlock LP sendiri | ✅ | ✅ | Sama |
| Extend lock sendiri | ✅ (V2) | ✅ (V2) | Sama |
| Unlock LP user lain | ⚠️ Emergency (delay 3d) | ❌ | Token ke owner asli |
| Extend lock user lain | ❌ | ❌ | Tidak ada cara |
| Approve LP token | ✅ | ❌ | Admin only |
| Revoke LP token | ✅ | ❌ | Admin only |
| Pause contract | ✅ | ❌ | Admin only |
| Unpause contract | ✅ | ❌ | Admin only |
| Update config | ✅ | ❌ | Admin only |
| Query anything | ✅ | ✅ | Public |

---

## Test Apakah User Bisa Pakai Fitur Admin

```bash
# User coba approve token (HARUS GAGAL)
paxid tx wasm execute paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e '{
  "approve_lp_token": {
    "token": "paxi1sometoken..."
  }
}' --from paxi1user123...  # ← bukan admin

# Expected error: "Unauthorized"
```

```bash
# User coba pause (HARUS GAGAL)
paxid tx wasm execute paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e '{
  "pause": {}
}' --from paxi1user123...

# Expected error: "Unauthorized"
```

```bash
# User coba emergency unlock lock user lain (HARUS GAGAL)
paxid tx wasm execute paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e '{
  "emergency_unlock": {
    "owner": "paxi1victim...",
    "lock_id": 1
  }
}' --from paxi1user123...

# Expected error: "Unauthorized"
```

---

## Kesimpulan

### User TIDAK Bisa:
- ❌ Approve/revoke LP tokens
- ❌ Pause/unpause contract
- ❌ Emergency unlock lock milik orang lain
- ❌ Update config
- ❌ Unlock/extend lock milik orang lain

### Admin BISA:
- ✅ Semua fitur admin
- ✅ Semua fitur user (lock/unlock/extend milik sendiri)
- ⚠️ Emergency unlock lock user (dengan batasan delay 3 hari di V2)

### Proteksi User:
- Lock user **aman** dari admin hingga 3 hari sebelum unlock_time (V2)
- Lock user **tidak aman** kapan saja (V1 - admin bisa unlock kapan saja)
- Token **selalu** dikirim ke owner asli, tidak pernah ke admin

---

**Catatan Keamanan:**

V2 (Production) lebih aman karena:
1. Emergency unlock ada delay 3 hari
2. Whitelist token mencegah scam token
3. Pause hanya block lock baru, tidak freeze unlock

V1 (Simplified) kurang aman karena:
1. Emergency unlock tanpa delay (admin power terlalu besar)
2. Terima semua token (risiko scam token)


**Dokumen dibuat:** 2026-01-20  
**Versi dokumen:** 1.0  
**Contract Production:** paxi1nrwymv8r6hg2quv4h2uc76p02puy43cwdcu8aeuf5wqmgndl9jxqjpyd8e (V2)