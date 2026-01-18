#!/data/data/com.termux/files/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${BLUE}=========================================="
echo "  LP LOCK CONTRACT GENERATOR"
echo "==========================================${NC}"

# Cek Rust
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}✗ Rust tidak ditemukan!${NC}"
    echo "Install: pkg install rust -y"
    exit 1
fi

# Cek wasm target
if ! rustc --print target-list | grep -q "wasm32-unknown-unknown"; then
    echo -e "${RED}✗ wasm32-unknown-unknown tidak tersedia!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Requirements OK${NC}"
echo ""

# Create project
mkdir -p prc20-lp-lock/src
cd prc20-lp-lock

cat > Cargo.toml << 'EOF'
[package]
name = "prc20-lp-lock"
version = "1.0.0"
edition = "2021"

[lib]
crate-type = ["cdylib", "rlib"]

[dependencies]
cosmwasm-std = "2.2.0"
cosmwasm-schema = "2.2.0"
cw-storage-plus = "2.0.0"
cw2 = "2.0.0"
schemars = "0.8"
serde = { version = "1.0", default-features = false, features = ["derive"] }
thiserror = "2.0"

[dev-dependencies]
cw-multi-test = "2.2.0"
EOF

cat > src/lib.rs << 'EOF'
pub mod contract;
pub mod error;
pub mod msg;
pub mod state;

pub use crate::error::ContractError;
EOF

cat > src/msg.rs << 'EOF'
use cosmwasm_schema::{cw_serde, QueryResponses};
use cosmwasm_std::{Addr, Uint128};

#[cw_serde]
pub struct InstantiateMsg {}

#[cw_serde]
pub enum ExecuteMsg {
    LockByHeight {
        token_addr: String,
        amount: Uint128,
        unlock_height: u64,
    },
    LockByTime {
        token_addr: String,
        amount: Uint128,
        unlock_time: u64,
    },
    Unlock { lock_id: u64 },
}

#[cw_serde]
#[derive(QueryResponses)]
pub enum QueryMsg {
    #[returns(TotalLockedResponse)]
    TotalLocked { token_addr: String },
    #[returns(LockInfoResponse)]
    LockInfo { owner: String, lock_id: u64 },
    #[returns(AllLocksResponse)]
    AllLocks { owner: String },
}

#[cw_serde]
pub struct TotalLockedResponse {
    pub token_addr: String,
    pub total_locked: Uint128,
}

#[cw_serde]
pub struct LockInfo {
    pub lock_id: u64,
    pub owner: Addr,
    pub token_addr: Addr,
    pub amount: Uint128,
    pub unlock_condition: UnlockCondition,
    pub is_unlocked: bool,
}

#[cw_serde]
pub enum UnlockCondition {
    Height { height: u64 },
    Time { timestamp: u64 },
}

#[cw_serde]
pub struct LockInfoResponse {
    pub lock: LockInfo,
}

#[cw_serde]
pub struct AllLocksResponse {
    pub locks: Vec<LockInfo>,
}
EOF

cat > src/state.rs << 'EOF'
use cosmwasm_std::{Addr, Uint128};
use cw_storage_plus::{Item, Map};
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};
use crate::msg::UnlockCondition;

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct Lock {
    pub lock_id: u64,
    pub owner: Addr,
    pub token_addr: Addr,
    pub amount: Uint128,
    pub unlock_condition: UnlockCondition,
    pub is_unlocked: bool,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct Config {
    pub lock_counter: u64,
}

pub const CONFIG: Item<Config> = Item::new("config");
pub const LOCKS: Map<(Addr, u64), Lock> = Map::new("locks");
pub const TOTAL_LOCKED: Map<Addr, Uint128> = Map::new("total_locked");
EOF

cat > src/error.rs << 'EOF'
use cosmwasm_std::StdError;
use thiserror::Error;

#[derive(Error, Debug, PartialEq)]
pub enum ContractError {
    #[error("{0}")]
    Std(#[from] StdError),
    #[error("Unauthorized")]
    Unauthorized {},
    #[error("Lock not found")]
    LockNotFound {},
    #[error("Tokens still locked")]
    TokensStillLocked {},
    #[error("Already unlocked")]
    AlreadyUnlocked {},
    #[error("Invalid unlock height")]
    InvalidUnlockHeight {},
    #[error("Invalid unlock time")]
    InvalidUnlockTime {},
    #[error("Amount must be greater than zero")]
    InvalidAmount {},
}
EOF

cat > src/contract.rs << 'EOF'
use cosmwasm_std::{
    entry_point, to_json_binary, Binary, Deps, DepsMut, Env, MessageInfo, 
    Response, StdResult, Uint128, WasmMsg, Order
};
use cw2::set_contract_version;
use crate::error::ContractError;
use crate::msg::{ExecuteMsg, InstantiateMsg, QueryMsg, LockInfo, LockInfoResponse, 
    AllLocksResponse, TotalLockedResponse, UnlockCondition};
use crate::state::{CONFIG, LOCKS, TOTAL_LOCKED, Config, Lock};

const CONTRACT_NAME: &str = "paxi:prc20-lp-lock";
const CONTRACT_VERSION: &str = env!("CARGO_PKG_VERSION");

#[entry_point]
pub fn instantiate(
    deps: DepsMut,
    _env: Env,
    _info: MessageInfo,
    _msg: InstantiateMsg,
) -> Result<Response, ContractError> {
    set_contract_version(deps.storage, CONTRACT_NAME, CONTRACT_VERSION)?;
    let config = Config { lock_counter: 0 };
    CONFIG.save(deps.storage, &config)?;
    Ok(Response::new()
        .add_attribute("action", "instantiate")
        .add_attribute("contract", CONTRACT_NAME))
}

#[entry_point]
pub fn execute(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    msg: ExecuteMsg,
) -> Result<Response, ContractError> {
    match msg {
        ExecuteMsg::LockByHeight { token_addr, amount, unlock_height } => {
            execute_lock_by_height(deps, env, info, token_addr, amount, unlock_height)
        }
        ExecuteMsg::LockByTime { token_addr, amount, unlock_time } => {
            execute_lock_by_time(deps, env, info, token_addr, amount, unlock_time)
        }
        ExecuteMsg::Unlock { lock_id } => {
            execute_unlock(deps, env, info, lock_id)
        }
    }
}

fn execute_lock_by_height(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    token_addr: String,
    amount: Uint128,
    unlock_height: u64,
) -> Result<Response, ContractError> {
    // Validasi amount
    if amount.is_zero() {
        return Err(ContractError::InvalidAmount {});
    }
    
    // Validasi unlock_height harus di masa depan
    if unlock_height <= env.block.height {
        return Err(ContractError::InvalidUnlockHeight {});
    }
    
    let token_addr = deps.api.addr_validate(&token_addr)?;
    
    // Increment lock counter dengan protection overflow
    let mut config = CONFIG.load(deps.storage)?;
    config.lock_counter = config.lock_counter.checked_add(1)
        .ok_or(ContractError::Std(cosmwasm_std::StdError::generic_err("Lock counter overflow")))?;
    let lock_id = config.lock_counter;
    
    let lock = Lock {
        lock_id,
        owner: info.sender.clone(),
        token_addr: token_addr.clone(),
        amount,
        unlock_condition: UnlockCondition::Height { height: unlock_height },
        is_unlocked: false,
    };
    
    LOCKS.save(deps.storage, (info.sender.clone(), lock_id), &lock)?;
    CONFIG.save(deps.storage, &config)?;
    
    // Update total locked dengan safe math
    let current_total = TOTAL_LOCKED
        .may_load(deps.storage, token_addr.clone())?
        .unwrap_or_default();
    let new_total = current_total.checked_add(amount)?;
    TOTAL_LOCKED.save(deps.storage, token_addr.clone(), &new_total)?;
    
    let transfer_msg = WasmMsg::Execute {
        contract_addr: token_addr.to_string(),
        msg: to_json_binary(&Prc20ExecuteMsg::TransferFrom {
            owner: info.sender.to_string(),
            recipient: env.contract.address.to_string(),
            amount,
        })?,
        funds: vec![],
    };
    
    Ok(Response::new()
        .add_message(transfer_msg)
        .add_attribute("action", "lock_by_height")
        .add_attribute("lock_id", lock_id.to_string())
        .add_attribute("owner", info.sender)
        .add_attribute("token", token_addr)
        .add_attribute("amount", amount)
        .add_attribute("unlock_height", unlock_height.to_string()))
}

fn execute_lock_by_time(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    token_addr: String,
    amount: Uint128,
    unlock_time: u64,
) -> Result<Response, ContractError> {
    if amount.is_zero() {
        return Err(ContractError::InvalidAmount {});
    }
    
    if unlock_time <= env.block.time.seconds() {
        return Err(ContractError::InvalidUnlockTime {});
    }
    
    let token_addr = deps.api.addr_validate(&token_addr)?;
    
    let mut config = CONFIG.load(deps.storage)?;
    config.lock_counter = config.lock_counter.checked_add(1)
        .ok_or(ContractError::Std(cosmwasm_std::StdError::generic_err("Lock counter overflow")))?;
    let lock_id = config.lock_counter;
    
    let lock = Lock {
        lock_id,
        owner: info.sender.clone(),
        token_addr: token_addr.clone(),
        amount,
        unlock_condition: UnlockCondition::Time { timestamp: unlock_time },
        is_unlocked: false,
    };
    
    LOCKS.save(deps.storage, (info.sender.clone(), lock_id), &lock)?;
    CONFIG.save(deps.storage, &config)?;
    
    let current_total = TOTAL_LOCKED
        .may_load(deps.storage, token_addr.clone())?
        .unwrap_or_default();
    let new_total = current_total.checked_add(amount)?;
    TOTAL_LOCKED.save(deps.storage, token_addr.clone(), &new_total)?;
    
    let transfer_msg = WasmMsg::Execute {
        contract_addr: token_addr.to_string(),
        msg: to_json_binary(&Prc20ExecuteMsg::TransferFrom {
            owner: info.sender.to_string(),
            recipient: env.contract.address.to_string(),
            amount,
        })?,
        funds: vec![],
    };
    
    Ok(Response::new()
        .add_message(transfer_msg)
        .add_attribute("action", "lock_by_time")
        .add_attribute("lock_id", lock_id.to_string())
        .add_attribute("owner", info.sender)
        .add_attribute("token", token_addr)
        .add_attribute("amount", amount)
        .add_attribute("unlock_time", unlock_time.to_string()))
}

fn execute_unlock(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    lock_id: u64,
) -> Result<Response, ContractError> {
    let mut lock = LOCKS
        .may_load(deps.storage, (info.sender.clone(), lock_id))?
        .ok_or(ContractError::LockNotFound {})?;
    
    // Check ownership sudah implicit di LOCKS key (info.sender, lock_id)
    
    if lock.is_unlocked {
        return Err(ContractError::AlreadyUnlocked {});
    }
    
    let can_unlock = match lock.unlock_condition {
        UnlockCondition::Height { height } => env.block.height >= height,
        UnlockCondition::Time { timestamp } => env.block.time.seconds() >= timestamp,
    };
    
    if !can_unlock {
        return Err(ContractError::TokensStillLocked {});
    }
    
    // Mark as unlocked BEFORE transfer untuk prevent reentrancy
    lock.is_unlocked = true;
    LOCKS.save(deps.storage, (info.sender.clone(), lock_id), &lock)?;
    
    // Update total locked dengan safe math
    let current_total = TOTAL_LOCKED.load(deps.storage, lock.token_addr.clone())?;
    let new_total = current_total.checked_sub(lock.amount)?;
    TOTAL_LOCKED.save(deps.storage, lock.token_addr.clone(), &new_total)?;
    
    let transfer_msg = WasmMsg::Execute {
        contract_addr: lock.token_addr.to_string(),
        msg: to_json_binary(&Prc20ExecuteMsg::Transfer {
            recipient: info.sender.to_string(),
            amount: lock.amount,
        })?,
        funds: vec![],
    };
    
    Ok(Response::new()
        .add_message(transfer_msg)
        .add_attribute("action", "unlock")
        .add_attribute("lock_id", lock_id.to_string())
        .add_attribute("owner", info.sender)
        .add_attribute("amount", lock.amount))
}

#[entry_point]
pub fn query(deps: Deps, _env: Env, msg: QueryMsg) -> StdResult<Binary> {
    match msg {
        QueryMsg::TotalLocked { token_addr } => {
            to_json_binary(&query_total_locked(deps, token_addr)?)
        }
        QueryMsg::LockInfo { owner, lock_id } => {
            to_json_binary(&query_lock_info(deps, owner, lock_id)?)
        }
        QueryMsg::AllLocks { owner } => {
            to_json_binary(&query_all_locks(deps, owner)?)
        }
    }
}

fn query_total_locked(deps: Deps, token_addr: String) -> StdResult<TotalLockedResponse> {
    let token_addr = deps.api.addr_validate(&token_addr)?;
    let total_locked = TOTAL_LOCKED
        .may_load(deps.storage, token_addr.clone())?
        .unwrap_or_default();
    Ok(TotalLockedResponse {
        token_addr: token_addr.to_string(),
        total_locked,
    })
}

fn query_lock_info(deps: Deps, owner: String, lock_id: u64) -> StdResult<LockInfoResponse> {
    let owner = deps.api.addr_validate(&owner)?;
    let lock = LOCKS.load(deps.storage, (owner, lock_id))?;
    Ok(LockInfoResponse {
        lock: LockInfo {
            lock_id: lock.lock_id,
            owner: lock.owner,
            token_addr: lock.token_addr,
            amount: lock.amount,
            unlock_condition: lock.unlock_condition,
            is_unlocked: lock.is_unlocked,
        },
    })
}

fn query_all_locks(deps: Deps, owner: String) -> StdResult<AllLocksResponse> {
    let owner = deps.api.addr_validate(&owner)?;
    let locks: Vec<LockInfo> = LOCKS
        .prefix(owner.clone())
        .range(deps.storage, None, None, Order::Ascending)
        .map(|item| {
            let (_, lock) = item?;
            Ok(LockInfo {
                lock_id: lock.lock_id,
                owner: lock.owner,
                token_addr: lock.token_addr,
                amount: lock.amount,
                unlock_condition: lock.unlock_condition,
                is_unlocked: lock.is_unlocked,
            })
        })
        .collect::<StdResult<Vec<_>>>()?;
    Ok(AllLocksResponse { locks })
}

#[cosmwasm_schema::cw_serde]
enum Prc20ExecuteMsg {
    Transfer { recipient: String, amount: Uint128 },
    TransferFrom { owner: String, recipient: String, amount: Uint128 },
}
EOF

cd ..

cat > build_lp_lock.sh << 'BUILDEOF'
#!/data/data/com.termux/files/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Building LP Lock Contract...${NC}"

cd prc20-lp-lock

echo -e "${YELLOW}[1/3] Compiling...${NC}"
cargo build --release --target wasm32-unknown-unknown

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

if ! command -v wasm-opt &> /dev/null; then
    echo -e "${YELLOW}wasm-opt not found. Install: pkg install binaryen${NC}"
    exit 1
fi

echo -e "${YELLOW}[2/3] Optimizing...${NC}"
wasm-opt -Oz \
    target/wasm32-unknown-unknown/release/prc20_lp_lock.wasm \
    -o prc20_lp_lock_optimized.wasm

echo -e "${YELLOW}[3/3] Finalizing...${NC}"
cd ..
mkdir -p artifacts
cp prc20-lp-lock/prc20_lp_lock_optimized.wasm artifacts/

SIZE=$(du -h artifacts/prc20_lp_lock_optimized.wasm | cut -f1)
echo -e "${GREEN}✓ Build complete: ${SIZE}${NC}"
echo -e "${GREEN}→ artifacts/prc20_lp_lock_optimized.wasm${NC}"
BUILDEOF

chmod +x build_lp_lock.sh

echo -e "${GREEN}✓ LP Lock contract generated${NC}"
echo ""
echo "Next: ./build_lp_lock.sh"
