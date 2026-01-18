#!/usr/bin/env bash
# generate_lp_lock.sh - CONSISTENT VERSION
# Uses same naming convention as vesting: prc20-lp-lock

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${BLUE}=========================================="
echo "  LP LOCK CONTRACT GENERATOR"
echo "  For Paxi Native Swap LP Tokens"
echo "==========================================${NC}"

if ! command -v cargo &> /dev/null; then
    echo -e "${RED}✗ Rust not found!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Requirements OK${NC}"
echo ""

# CONSISTENT: Use same naming as vesting
PROJECT_DIR="contracts/prc20-lp-lock"
mkdir -p "$PROJECT_DIR/src"
cd "$PROJECT_DIR"

cat > Cargo.toml << 'EOF'
[package]
name = "prc20-lp-lock"
version = "1.0.0"
edition = "2021"

[lib]
crate-type = ["cdylib", "rlib"]

[dependencies]
cosmwasm-std = "1.5.0"
cosmwasm-schema = "1.5.0"
cw-storage-plus = "1.2.0"
cw2 = "1.1.0"
cw20 = "1.1.0"
schemars = "0.8.16"
serde = { version = "1.0", default-features = false, features = ["derive"] }
thiserror = "1.0"
base64ct = "=1.6.0"

[profile.release]
opt-level = 3
debug = false
lto = true
codegen-units = 1
panic = 'abort'
overflow-checks = true
EOF

cat > src/lib.rs << 'EOF'
pub mod contract;
pub mod error;
pub mod msg;
pub mod state;

pub use crate::error::ContractError;
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
    
    #[error("Tokens still locked until {unlock_time}")]
    TokensStillLocked { unlock_time: u64 },
    
    #[error("Already unlocked")]
    AlreadyUnlocked {},
    
    #[error("Lock duration must be at least {min} seconds")]
    LockDurationTooShort { min: u64 },
    
    #[error("Amount must be greater than zero")]
    InvalidAmount {},
    
    #[error("Contract paused")]
    ContractPaused {},
    
    #[error("Overflow error")]
    Overflow {},
    
    #[error("Reentrancy detected")]
    ReentrancyDetected {},
}
EOF

cat > src/msg.rs << 'EOF'
use cosmwasm_schema::{cw_serde, QueryResponses};
use cosmwasm_std::{Addr, Uint128};

#[cw_serde]
pub struct InstantiateMsg {
    pub admin: String,
    pub min_lock_duration: Option<u64>,
}

#[cw_serde]
pub enum ExecuteMsg {
    Receive(cw20::Cw20ReceiveMsg),
    UnlockLp { lock_id: u64 },
    EmergencyUnlock { owner: String, lock_id: u64 },
    Pause {},
    Unpause {},
    UpdateConfig {
        admin: Option<String>,
        min_lock_duration: Option<u64>,
    },
}

#[cw_serde]
pub enum ReceiveMsg {
    LockLp { unlock_time: u64 },
}

#[cw_serde]
#[derive(QueryResponses)]
pub enum QueryMsg {
    #[returns(ConfigResponse)]
    Config {},
    #[returns(LockInfoResponse)]
    LockInfo { owner: String, lock_id: u64 },
    #[returns(AllLocksResponse)]
    AllLocks {
        owner: String,
        start_after: Option<u64>,
        limit: Option<u32>,
    },
    #[returns(TotalLocksResponse)]
    TotalLocks {},
}

#[cw_serde]
pub struct ConfigResponse {
    pub admin: Addr,
    pub min_lock_duration: u64,
    pub paused: bool,
    pub lock_counter: u64,
}

#[cw_serde]
pub struct LockInfo {
    pub lock_id: u64,
    pub owner: Addr,
    pub lp_token: Addr,
    pub lp_amount: Uint128,
    pub unlock_time: u64,
    pub locked_at: u64,
    pub is_unlocked: bool,
}

#[cw_serde]
pub struct LockInfoResponse {
    pub lock: LockInfo,
}

#[cw_serde]
pub struct AllLocksResponse {
    pub locks: Vec<LockInfo>,
}

#[cw_serde]
pub struct TotalLocksResponse {
    pub total_locks: u64,
    pub active_locks: u64,
    pub unlocked_locks: u64,
}
EOF

cat > src/state.rs << 'EOF'
use cosmwasm_std::{Addr, Uint128};
use cw_storage_plus::{Item, Map};
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct Config {
    pub admin: Addr,
    pub min_lock_duration: u64,
    pub paused: bool,
    pub lock_counter: u64,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct Lock {
    pub lock_id: u64,
    pub owner: Addr,
    pub lp_token: Addr,
    pub lp_amount: Uint128,
    pub unlock_time: u64,
    pub locked_at: u64,
    pub is_unlocked: bool,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct ReentrancyGuard {
    pub locked: bool,
}

pub const CONFIG: Item<Config> = Item::new("config");
pub const LOCKS: Map<(Addr, u64), Lock> = Map::new("locks");
pub const REENTRANCY_GUARD: Item<ReentrancyGuard> = Item::new("reentrancy_guard");
EOF

cat > src/contract.rs << 'EOF'
use cosmwasm_std::{
    entry_point, from_json, to_json_binary, Addr, Binary, Deps, DepsMut, 
    Env, MessageInfo, Order, Response, StdResult, Uint128, WasmMsg,
};
use cw_storage_plus::Bound;
use cw2::set_contract_version;
use cw20::Cw20ReceiveMsg;

use crate::error::ContractError;
use crate::msg::{
    AllLocksResponse, ConfigResponse, ExecuteMsg, InstantiateMsg, LockInfo,
    LockInfoResponse, QueryMsg, ReceiveMsg, TotalLocksResponse,
};
use crate::state::{Config, Lock, ReentrancyGuard, CONFIG, LOCKS, REENTRANCY_GUARD};

const CONTRACT_NAME: &str = "paxi:lp-lock";
const CONTRACT_VERSION: &str = env!("CARGO_PKG_VERSION");

#[entry_point]
pub fn instantiate(
    deps: DepsMut,
    _env: Env,
    _info: MessageInfo,
    msg: InstantiateMsg,
) -> Result<Response, ContractError> {
    set_contract_version(deps.storage, CONTRACT_NAME, CONTRACT_VERSION)?;
    
    let admin = deps.api.addr_validate(&msg.admin)?;
    
    let config = Config {
        admin: admin.clone(),
        min_lock_duration: msg.min_lock_duration.unwrap_or(86400),
        paused: false,
        lock_counter: 0,
    };
    
    CONFIG.save(deps.storage, &config)?;
    REENTRANCY_GUARD.save(deps.storage, &ReentrancyGuard { locked: false })?;
    
    Ok(Response::new()
        .add_attribute("action", "instantiate")
        .add_attribute("admin", admin)
        .add_attribute("contract_version", CONTRACT_VERSION))
}

#[entry_point]
pub fn execute(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    msg: ExecuteMsg,
) -> Result<Response, ContractError> {
    match msg {
        ExecuteMsg::Receive(receive_msg) => execute_receive(deps, env, info, receive_msg),
        ExecuteMsg::UnlockLp { lock_id } => execute_unlock_lp(deps, env, info, lock_id),
        ExecuteMsg::EmergencyUnlock { owner, lock_id } => {
            execute_emergency_unlock(deps, env, info, owner, lock_id)
        }
        ExecuteMsg::Pause {} => execute_pause(deps, info),
        ExecuteMsg::Unpause {} => execute_unpause(deps, info),
        ExecuteMsg::UpdateConfig { admin, min_lock_duration } => {
            execute_update_config(deps, info, admin, min_lock_duration)
        }
    }
}

fn execute_receive(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    receive_msg: Cw20ReceiveMsg,
) -> Result<Response, ContractError> {
    let mut guard = REENTRANCY_GUARD.load(deps.storage)?;
    if guard.locked {
        return Err(ContractError::ReentrancyDetected {});
    }
    guard.locked = true;
    REENTRANCY_GUARD.save(deps.storage, &guard)?;
    
    let config = CONFIG.load(deps.storage)?;
    
    if config.paused {
        return Err(ContractError::ContractPaused {});
    }
    
    let lp_token = info.sender;
    let owner = deps.api.addr_validate(&receive_msg.sender)?;
    let amount = receive_msg.amount;
    
    if amount.is_zero() {
        return Err(ContractError::InvalidAmount {});
    }
    
    let msg: ReceiveMsg = from_json(&receive_msg.msg)?;
    
    match msg {
        ReceiveMsg::LockLp { unlock_time } => {
            let lock_duration = unlock_time.saturating_sub(env.block.time.seconds());
            if lock_duration < config.min_lock_duration {
                return Err(ContractError::LockDurationTooShort {
                    min: config.min_lock_duration,
                });
            }
            
            let mut updated_config = config;
            updated_config.lock_counter = updated_config
                .lock_counter
                .checked_add(1)
                .ok_or(ContractError::Overflow {})?;
            let lock_id = updated_config.lock_counter;
            
            let lock = Lock {
                lock_id,
                owner: owner.clone(),
                lp_token: lp_token.clone(),
                lp_amount: amount,
                unlock_time,
                locked_at: env.block.time.seconds(),
                is_unlocked: false,
            };
            
            LOCKS.save(deps.storage, (owner.clone(), lock_id), &lock)?;
            CONFIG.save(deps.storage, &updated_config)?;
            
            guard.locked = false;
            REENTRANCY_GUARD.save(deps.storage, &guard)?;
            
            Ok(Response::new()
                .add_attribute("action", "lock_lp")
                .add_attribute("lock_id", lock_id.to_string())
                .add_attribute("owner", owner)
                .add_attribute("lp_token", lp_token)
                .add_attribute("lp_amount", amount)
                .add_attribute("unlock_time", unlock_time.to_string()))
        }
    }
}

fn execute_unlock_lp(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    lock_id: u64,
) -> Result<Response, ContractError> {
    let mut guard = REENTRANCY_GUARD.load(deps.storage)?;
    if guard.locked {
        return Err(ContractError::ReentrancyDetected {});
    }
    guard.locked = true;
    REENTRANCY_GUARD.save(deps.storage, &guard)?;
    
    let mut lock = LOCKS
        .may_load(deps.storage, (info.sender.clone(), lock_id))?
        .ok_or(ContractError::LockNotFound {})?;
    
    if lock.is_unlocked {
        return Err(ContractError::AlreadyUnlocked {});
    }
    
    if env.block.time.seconds() < lock.unlock_time {
        return Err(ContractError::TokensStillLocked {
            unlock_time: lock.unlock_time,
        });
    }
    
    lock.is_unlocked = true;
    LOCKS.save(deps.storage, (info.sender.clone(), lock_id), &lock)?;
    
    let transfer_msg = WasmMsg::Execute {
        contract_addr: lock.lp_token.to_string(),
        msg: to_json_binary(&cw20::Cw20ExecuteMsg::Transfer {
            recipient: info.sender.to_string(),
            amount: lock.lp_amount,
        })?,
        funds: vec![],
    };
    
    guard.locked = false;
    REENTRANCY_GUARD.save(deps.storage, &guard)?;
    
    Ok(Response::new()
        .add_message(transfer_msg)
        .add_attribute("action", "unlock_lp")
        .add_attribute("lock_id", lock_id.to_string())
        .add_attribute("owner", info.sender)
        .add_attribute("lp_amount", lock.lp_amount))
}

fn execute_emergency_unlock(
    deps: DepsMut,
    _env: Env,
    info: MessageInfo,
    owner: String,
    lock_id: u64,
) -> Result<Response, ContractError> {
    let config = CONFIG.load(deps.storage)?;
    
    if info.sender != config.admin {
        return Err(ContractError::Unauthorized {});
    }
    
    let owner_addr = deps.api.addr_validate(&owner)?;
    let mut lock = LOCKS
        .may_load(deps.storage, (owner_addr.clone(), lock_id))?
        .ok_or(ContractError::LockNotFound {})?;
    
    if lock.is_unlocked {
        return Err(ContractError::AlreadyUnlocked {});
    }
    
    lock.is_unlocked = true;
    LOCKS.save(deps.storage, (owner_addr.clone(), lock_id), &lock)?;
    
    let transfer_msg = WasmMsg::Execute {
        contract_addr: lock.lp_token.to_string(),
        msg: to_json_binary(&cw20::Cw20ExecuteMsg::Transfer {
            recipient: owner_addr.to_string(),
            amount: lock.lp_amount,
        })?,
        funds: vec![],
    };
    
    Ok(Response::new()
        .add_message(transfer_msg)
        .add_attribute("action", "emergency_unlock")
        .add_attribute("admin", info.sender)
        .add_attribute("owner", owner_addr)
        .add_attribute("lock_id", lock_id.to_string()))
}

fn execute_pause(deps: DepsMut, info: MessageInfo) -> Result<Response, ContractError> {
    let mut config = CONFIG.load(deps.storage)?;
    
    if info.sender != config.admin {
        return Err(ContractError::Unauthorized {});
    }
    
    config.paused = true;
    CONFIG.save(deps.storage, &config)?;
    
    Ok(Response::new()
        .add_attribute("action", "pause")
        .add_attribute("admin", info.sender))
}

fn execute_unpause(deps: DepsMut, info: MessageInfo) -> Result<Response, ContractError> {
    let mut config = CONFIG.load(deps.storage)?;
    
    if info.sender != config.admin {
        return Err(ContractError::Unauthorized {});
    }
    
    config.paused = false;
    CONFIG.save(deps.storage, &config)?;
    
    Ok(Response::new()
        .add_attribute("action", "unpause")
        .add_attribute("admin", info.sender))
}

fn execute_update_config(
    deps: DepsMut,
    info: MessageInfo,
    admin: Option<String>,
    min_lock_duration: Option<u64>,
) -> Result<Response, ContractError> {
    let mut config = CONFIG.load(deps.storage)?;
    
    if info.sender != config.admin {
        return Err(ContractError::Unauthorized {});
    }
    
    if let Some(new_admin) = admin {
        config.admin = deps.api.addr_validate(&new_admin)?;
    }
    
    if let Some(duration) = min_lock_duration {
        config.min_lock_duration = duration;
    }
    
    CONFIG.save(deps.storage, &config)?;
    
    Ok(Response::new()
        .add_attribute("action", "update_config")
        .add_attribute("admin", config.admin))
}

#[entry_point]
pub fn query(deps: Deps, _env: Env, msg: QueryMsg) -> StdResult<Binary> {
    match msg {
        QueryMsg::Config {} => to_json_binary(&query_config(deps)?),
        QueryMsg::LockInfo { owner, lock_id } => {
            to_json_binary(&query_lock_info(deps, owner, lock_id)?)
        }
        QueryMsg::AllLocks { owner, start_after, limit } => {
            to_json_binary(&query_all_locks(deps, owner, start_after, limit)?)
        }
        QueryMsg::TotalLocks {} => to_json_binary(&query_total_locks(deps)?),
    }
}

fn query_config(deps: Deps) -> StdResult<ConfigResponse> {
    let config = CONFIG.load(deps.storage)?;
    Ok(ConfigResponse {
        admin: config.admin,
        min_lock_duration: config.min_lock_duration,
        paused: config.paused,
        lock_counter: config.lock_counter,
    })
}

fn query_lock_info(deps: Deps, owner: String, lock_id: u64) -> StdResult<LockInfoResponse> {
    let owner_addr = deps.api.addr_validate(&owner)?;
    let lock = LOCKS.load(deps.storage, (owner_addr, lock_id))?;
    
    Ok(LockInfoResponse {
        lock: LockInfo {
            lock_id: lock.lock_id,
            owner: lock.owner,
            lp_token: lock.lp_token,
            lp_amount: lock.lp_amount,
            unlock_time: lock.unlock_time,
            locked_at: lock.locked_at,
            is_unlocked: lock.is_unlocked,
        },
    })
}

fn query_all_locks(
    deps: Deps,
    owner: String,
    start_after: Option<u64>,
    limit: Option<u32>,
) -> StdResult<AllLocksResponse> {
    let owner_addr = deps.api.addr_validate(&owner)?;
    let limit = limit.unwrap_or(10).min(30) as usize;
    let start = start_after.map(Bound::exclusive);
    
    let locks: Vec<LockInfo> = LOCKS
        .prefix(owner_addr)
        .range(deps.storage, start, None, Order::Ascending)
        .take(limit)
        .map(|item| {
            let (_, lock) = item?;
            Ok(LockInfo {
                lock_id: lock.lock_id,
                owner: lock.owner,
                lp_token: lock.lp_token,
                lp_amount: lock.lp_amount,
                unlock_time: lock.unlock_time,
                locked_at: lock.locked_at,
                is_unlocked: lock.is_unlocked,
            })
        })
        .collect::<StdResult<Vec<_>>>()?;
    
    Ok(AllLocksResponse { locks })
}

fn query_total_locks(deps: Deps) -> StdResult<TotalLocksResponse> {
    let config = CONFIG.load(deps.storage)?;
    
    let mut active_locks = 0u64;
    let mut unlocked_locks = 0u64;
    
    for item in LOCKS.range(deps.storage, None, None, Order::Ascending) {
        let (_, lock) = item?;
        if lock.is_unlocked {
            unlocked_locks += 1;
        } else {
            active_locks += 1;
        }
    }
    
    Ok(TotalLocksResponse {
        total_locks: config.lock_counter,
        active_locks,
        unlocked_locks,
    })
}
EOF

cd ../..

echo ""
echo -e "${GREEN}✓ LP Lock Contract Generated!${NC}"
echo ""
echo -e "${CYAN}Next: ./build_lp_lock.sh${NC}"