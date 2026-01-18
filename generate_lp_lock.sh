#!/bin/bash

# Generate PRC20 LP Lock Smart Contract untuk Paxi Network
# Fixed: Lock dependencies ke versions yang tidak require edition2024

set -e

PROJECT_NAME="prc20-lp-lock"
CONTRACT_NAME="prc20_lp_lock"

echo "🚀 Generating $PROJECT_NAME contract..."

# Create project structure
mkdir -p $PROJECT_NAME/src
cd $PROJECT_NAME

# Generate Cargo.toml dengan dependency versions yang fixed
cat > Cargo.toml << 'EOF'
[package]
name = "prc20_lp_lock"
version = "1.0.0"
authors = ["Paxi Network Community"]
edition = "2021"

[lib]
crate-type = ["cdylib", "rlib"]

[profile.release]
opt-level = 3
debug = false
rpath = false
lto = true
debug-assertions = false
codegen-units = 1
panic = 'abort'
incremental = false
overflow-checks = true

[features]
default = []
library = []

[dependencies]
cosmwasm-std = "1.5.0"
cosmwasm-storage = "1.5.0"
cw-storage-plus = "1.2.0"
cw2 = "1.1.0"
schemars = "0.8.16"
serde = { version = "1.0.195", default-features = false, features = ["derive"] }
thiserror = "1.0.56"

[dev-dependencies]
cosmwasm-schema = "1.5.0"
EOF

# Generate lib.rs
cat > src/lib.rs << 'EOF'
pub mod contract;
pub mod error;
pub mod msg;
pub mod state;

pub use crate::error::ContractError;
EOF

# Generate error.rs
cat > src/error.rs << 'EOF'
use cosmwasm_std::StdError;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ContractError {
    #[error("{0}")]
    Std(#[from] StdError),

    #[error("Unauthorized")]
    Unauthorized {},

    #[error("Lock not found")]
    LockNotFound {},

    #[error("Lock still active")]
    LockStillActive {},

    #[error("Lock already unlocked")]
    AlreadyUnlocked {},

    #[error("Invalid lock time")]
    InvalidLockTime {},

    #[error("Invalid lock height")]
    InvalidLockHeight {},

    #[error("Invalid amount")]
    InvalidAmount {},

    #[error("Overflow in calculation")]
    Overflow {},
}
EOF

# Generate state.rs
cat > src/state.rs << 'EOF'
use cosmwasm_std::Addr;
use cw_storage_plus::{Item, Map};
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct Config {
    pub owner: Addr,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct LockInfo {
    pub owner: Addr,
    pub token_addr: Addr,
    pub amount: u128,
    pub unlock_time: Option<u64>,
    pub unlock_height: Option<u64>,
    pub is_unlocked: bool,
}

pub const CONFIG: Item<Config> = Item::new("config");
pub const LOCK_COUNTER: Item<u64> = Item::new("lock_counter");
pub const LOCKS: Map<(Addr, u64), LockInfo> = Map::new("locks");
pub const TOTAL_LOCKED: Map<Addr, u128> = Map::new("total_locked");
EOF

# Generate msg.rs
cat > src/msg.rs << 'EOF'
use cosmwasm_std::Addr;
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct InstantiateMsg {}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub enum ExecuteMsg {
    LockByTime {
        token_addr: String,
        amount: String,
        unlock_time: u64,
    },
    LockByHeight {
        token_addr: String,
        amount: String,
        unlock_height: u64,
    },
    Unlock {
        lock_id: u64,
    },
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub enum QueryMsg {
    Config {},
    LockInfo { owner: String, lock_id: u64 },
    TotalLocked { token_addr: String },
    AllLocks { owner: String },
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct ConfigResponse {
    pub owner: Addr,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct LockInfoResponse {
    pub owner: Addr,
    pub token_addr: Addr,
    pub amount: String,
    pub unlock_time: Option<u64>,
    pub unlock_height: Option<u64>,
    pub is_unlocked: bool,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct TotalLockedResponse {
    pub token_addr: Addr,
    pub total_amount: String,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct AllLocksResponse {
    pub locks: Vec<(u64, LockInfoResponse)>,
}
EOF

# Generate contract.rs
cat > src/contract.rs << 'EOF'
use cosmwasm_std::{
    entry_point, to_json_binary, Addr, Binary, Deps, DepsMut, Env, MessageInfo, Response,
    StdResult, Uint128, WasmMsg, CosmosMsg,
};
use cw2::set_contract_version;

use crate::error::ContractError;
use crate::msg::{
    ExecuteMsg, InstantiateMsg, QueryMsg, ConfigResponse, LockInfoResponse,
    TotalLockedResponse, AllLocksResponse,
};
use crate::state::{Config, LockInfo, CONFIG, LOCK_COUNTER, LOCKS, TOTAL_LOCKED};

const CONTRACT_NAME: &str = "crates.io:prc20-lp-lock";
const CONTRACT_VERSION: &str = env!("CARGO_PKG_VERSION");

#[entry_point]
pub fn instantiate(
    deps: DepsMut,
    _env: Env,
    info: MessageInfo,
    _msg: InstantiateMsg,
) -> Result<Response, ContractError> {
    set_contract_version(deps.storage, CONTRACT_NAME, CONTRACT_VERSION)?;

    let config = Config {
        owner: info.sender.clone(),
    };
    CONFIG.save(deps.storage, &config)?;
    LOCK_COUNTER.save(deps.storage, &0)?;

    Ok(Response::new()
        .add_attribute("method", "instantiate")
        .add_attribute("owner", info.sender))
}

#[entry_point]
pub fn execute(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    msg: ExecuteMsg,
) -> Result<Response, ContractError> {
    match msg {
        ExecuteMsg::LockByTime {
            token_addr,
            amount,
            unlock_time,
        } => execute_lock_by_time(deps, env, info, token_addr, amount, unlock_time),
        ExecuteMsg::LockByHeight {
            token_addr,
            amount,
            unlock_height,
        } => execute_lock_by_height(deps, env, info, token_addr, amount, unlock_height),
        ExecuteMsg::Unlock { lock_id } => execute_unlock(deps, env, info, lock_id),
    }
}

pub fn execute_lock_by_time(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    token_addr: String,
    amount: String,
    unlock_time: u64,
) -> Result<Response, ContractError> {
    let token_addr = deps.api.addr_validate(&token_addr)?;
    let amount_u128: u128 = amount.parse().map_err(|_| ContractError::InvalidAmount {})?;

    if amount_u128 == 0 {
        return Err(ContractError::InvalidAmount {});
    }

    if unlock_time <= env.block.time.seconds() {
        return Err(ContractError::InvalidLockTime {});
    }

    let mut lock_counter = LOCK_COUNTER.load(deps.storage)?;
    lock_counter = lock_counter.checked_add(1).ok_or(ContractError::Overflow {})?;

    let lock_info = LockInfo {
        owner: info.sender.clone(),
        token_addr: token_addr.clone(),
        amount: amount_u128,
        unlock_time: Some(unlock_time),
        unlock_height: None,
        is_unlocked: false,
    };

    LOCKS.save(deps.storage, (info.sender.clone(), lock_counter), &lock_info)?;
    LOCK_COUNTER.save(deps.storage, &lock_counter)?;

    let current_total = TOTAL_LOCKED
        .may_load(deps.storage, token_addr.clone())?
        .unwrap_or(0);
    let new_total = current_total.checked_add(amount_u128).ok_or(ContractError::Overflow {})?;
    TOTAL_LOCKED.save(deps.storage, token_addr.clone(), &new_total)?;

    let transfer_msg = WasmMsg::Execute {
        contract_addr: token_addr.to_string(),
        msg: to_json_binary(&cw20::Cw20ExecuteMsg::TransferFrom {
            owner: info.sender.to_string(),
            recipient: env.contract.address.to_string(),
            amount: Uint128::from(amount_u128),
        })?,
        funds: vec![],
    };

    Ok(Response::new()
        .add_message(CosmosMsg::Wasm(transfer_msg))
        .add_attribute("method", "lock_by_time")
        .add_attribute("lock_id", lock_counter.to_string())
        .add_attribute("owner", info.sender)
        .add_attribute("amount", amount)
        .add_attribute("unlock_time", unlock_time.to_string()))
}

pub fn execute_lock_by_height(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    token_addr: String,
    amount: String,
    unlock_height: u64,
) -> Result<Response, ContractError> {
    let token_addr = deps.api.addr_validate(&token_addr)?;
    let amount_u128: u128 = amount.parse().map_err(|_| ContractError::InvalidAmount {})?;

    if amount_u128 == 0 {
        return Err(ContractError::InvalidAmount {});
    }

    if unlock_height <= env.block.height {
        return Err(ContractError::InvalidLockHeight {});
    }

    let mut lock_counter = LOCK_COUNTER.load(deps.storage)?;
    lock_counter = lock_counter.checked_add(1).ok_or(ContractError::Overflow {})?;

    let lock_info = LockInfo {
        owner: info.sender.clone(),
        token_addr: token_addr.clone(),
        amount: amount_u128,
        unlock_time: None,
        unlock_height: Some(unlock_height),
        is_unlocked: false,
    };

    LOCKS.save(deps.storage, (info.sender.clone(), lock_counter), &lock_info)?;
    LOCK_COUNTER.save(deps.storage, &lock_counter)?;

    let current_total = TOTAL_LOCKED
        .may_load(deps.storage, token_addr.clone())?
        .unwrap_or(0);
    let new_total = current_total.checked_add(amount_u128).ok_or(ContractError::Overflow {})?;
    TOTAL_LOCKED.save(deps.storage, token_addr.clone(), &new_total)?;

    let transfer_msg = WasmMsg::Execute {
        contract_addr: token_addr.to_string(),
        msg: to_json_binary(&cw20::Cw20ExecuteMsg::TransferFrom {
            owner: info.sender.to_string(),
            recipient: env.contract.address.to_string(),
            amount: Uint128::from(amount_u128),
        })?,
        funds: vec![],
    };

    Ok(Response::new()
        .add_message(CosmosMsg::Wasm(transfer_msg))
        .add_attribute("method", "lock_by_height")
        .add_attribute("lock_id", lock_counter.to_string())
        .add_attribute("owner", info.sender)
        .add_attribute("amount", amount)
        .add_attribute("unlock_height", unlock_height.to_string()))
}

pub fn execute_unlock(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    lock_id: u64,
) -> Result<Response, ContractError> {
    let lock_info = LOCKS
        .may_load(deps.storage, (info.sender.clone(), lock_id))?
        .ok_or(ContractError::LockNotFound {})?;

    if lock_info.owner != info.sender {
        return Err(ContractError::Unauthorized {});
    }

    if lock_info.is_unlocked {
        return Err(ContractError::AlreadyUnlocked {});
    }

    let can_unlock = if let Some(unlock_time) = lock_info.unlock_time {
        env.block.time.seconds() >= unlock_time
    } else if let Some(unlock_height) = lock_info.unlock_height {
        env.block.height >= unlock_height
    } else {
        false
    };

    if !can_unlock {
        return Err(ContractError::LockStillActive {});
    }

    let mut updated_lock = lock_info.clone();
    updated_lock.is_unlocked = true;
    LOCKS.save(deps.storage, (info.sender.clone(), lock_id), &updated_lock)?;

    let current_total = TOTAL_LOCKED
        .load(deps.storage, lock_info.token_addr.clone())?;
    let new_total = current_total.checked_sub(lock_info.amount).ok_or(ContractError::Overflow {})?;
    TOTAL_LOCKED.save(deps.storage, lock_info.token_addr.clone(), &new_total)?;

    let transfer_msg = WasmMsg::Execute {
        contract_addr: lock_info.token_addr.to_string(),
        msg: to_json_binary(&cw20::Cw20ExecuteMsg::Transfer {
            recipient: info.sender.to_string(),
            amount: Uint128::from(lock_info.amount),
        })?,
        funds: vec![],
    };

    Ok(Response::new()
        .add_message(CosmosMsg::Wasm(transfer_msg))
        .add_attribute("method", "unlock")
        .add_attribute("lock_id", lock_id.to_string())
        .add_attribute("owner", info.sender)
        .add_attribute("amount", lock_info.amount.to_string()))
}

#[entry_point]
pub fn query(deps: Deps, _env: Env, msg: QueryMsg) -> StdResult<Binary> {
    match msg {
        QueryMsg::Config {} => to_json_binary(&query_config(deps)?),
        QueryMsg::LockInfo { owner, lock_id } => to_json_binary(&query_lock_info(deps, owner, lock_id)?),
        QueryMsg::TotalLocked { token_addr } => to_json_binary(&query_total_locked(deps, token_addr)?),
        QueryMsg::AllLocks { owner } => to_json_binary(&query_all_locks(deps, owner)?),
    }
}

fn query_config(deps: Deps) -> StdResult<ConfigResponse> {
    let config = CONFIG.load(deps.storage)?;
    Ok(ConfigResponse { owner: config.owner })
}

fn query_lock_info(deps: Deps, owner: String, lock_id: u64) -> StdResult<LockInfoResponse> {
    let owner_addr = deps.api.addr_validate(&owner)?;
    let lock_info = LOCKS.load(deps.storage, (owner_addr, lock_id))?;

    Ok(LockInfoResponse {
        owner: lock_info.owner,
        token_addr: lock_info.token_addr,
        amount: lock_info.amount.to_string(),
        unlock_time: lock_info.unlock_time,
        unlock_height: lock_info.unlock_height,
        is_unlocked: lock_info.is_unlocked,
    })
}

fn query_total_locked(deps: Deps, token_addr: String) -> StdResult<TotalLockedResponse> {
    let token_addr = deps.api.addr_validate(&token_addr)?;
    let total = TOTAL_LOCKED.may_load(deps.storage, token_addr.clone())?.unwrap_or(0);

    Ok(TotalLockedResponse {
        token_addr,
        total_amount: total.to_string(),
    })
}

fn query_all_locks(deps: Deps, owner: String) -> StdResult<AllLocksResponse> {
    let owner_addr = deps.api.addr_validate(&owner)?;
    
    let locks: Vec<(u64, LockInfoResponse)> = LOCKS
        .prefix(owner_addr)
        .range(deps.storage, None, None, cosmwasm_std::Order::Ascending)
        .filter_map(|item| {
            item.ok().map(|(lock_id, lock_info)| {
                (
                    lock_id,
                    LockInfoResponse {
                        owner: lock_info.owner,
                        token_addr: lock_info.token_addr,
                        amount: lock_info.amount.to_string(),
                        unlock_time: lock_info.unlock_time,
                        unlock_height: lock_info.unlock_height,
                        is_unlocked: lock_info.is_unlocked,
                    },
                )
            })
        })
        .collect();

    Ok(AllLocksResponse { locks })
}

mod cw20 {
    use cosmwasm_std::Uint128;
    use schemars::JsonSchema;
    use serde::{Deserialize, Serialize};

    #[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
    #[serde(rename_all = "snake_case")]
    pub enum Cw20ExecuteMsg {
        Transfer { recipient: String, amount: Uint128 },
        TransferFrom { owner: String, recipient: String, amount: Uint128 },
    }
}
EOF

cd ..

echo "✅ $PROJECT_NAME contract generated successfully!"
echo ""
echo "📁 Project structure:"
echo "   $PROJECT_NAME/"
echo "   ├── Cargo.toml (Edition 2021 + Fixed dependencies)"
echo "   └── src/"
echo "       ├── lib.rs"
echo "       ├── contract.rs"
echo "       ├── msg.rs"
echo "       ├── state.rs"
echo "       └── error.rs"
echo ""
echo "🔧 Next steps:"
echo "   1. Review generated files"
echo "   2. Run: ./build_lp_lock.sh"
echo ""