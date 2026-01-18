#!/bin/bash

# Generate PRC20 Vesting Smart Contract untuk Paxi Network
# Fixed: Lock dependencies ke versions yang tidak require edition2024

set -e

PROJECT_NAME="prc20-vesting"
CONTRACT_NAME="prc20_vesting"

echo "🚀 Generating $PROJECT_NAME contract..."

# Create project structure
mkdir -p $PROJECT_NAME/src
cd $PROJECT_NAME

# Generate Cargo.toml dengan dependency versions yang fixed
cat > Cargo.toml << 'EOF'
[package]
name = "prc20_vesting"
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

    #[error("Vesting not found")]
    VestingNotFound {},

    #[error("Vesting already exists")]
    VestingExists {},

    #[error("No tokens available to claim")]
    NothingToClaim {},

    #[error("Invalid vesting parameters")]
    InvalidParams {},

    #[error("Cliff duration must be less than total duration")]
    InvalidCliffDuration {},

    #[error("Division by zero")]
    DivisionByZero {},

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
    pub token_addr: Addr,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct VestingSchedule {
    pub beneficiary: Addr,
    pub total_amount: u128,
    pub claimed_amount: u128,
    pub start_time: u64,
    pub cliff_duration: u64,
    pub vesting_duration: u64,
    pub revoked: bool,
}

pub const CONFIG: Item<Config> = Item::new("config");
pub const VESTING: Map<Addr, VestingSchedule> = Map::new("vesting");
EOF

# Generate msg.rs  
cat > src/msg.rs << 'EOF'
use cosmwasm_std::Addr;
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct InstantiateMsg {
    pub token_addr: String,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub enum ExecuteMsg {
    CreateVesting {
        beneficiary: String,
        total_amount: String,
        start_time: u64,
        cliff_duration: u64,
        vesting_duration: u64,
    },
    Claim {},
    RevokeVesting {
        beneficiary: String,
    },
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub enum QueryMsg {
    Config {},
    VestingInfo { beneficiary: String },
    ClaimableAmount { beneficiary: String },
    AllVesting {},
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct ConfigResponse {
    pub owner: Addr,
    pub token_addr: Addr,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct VestingInfoResponse {
    pub beneficiary: Addr,
    pub total_amount: String,
    pub claimed_amount: String,
    pub start_time: u64,
    pub cliff_duration: u64,
    pub vesting_duration: u64,
    pub revoked: bool,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct ClaimableAmountResponse {
    pub amount: String,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct AllVestingResponse {
    pub vesting_schedules: Vec<VestingInfoResponse>,
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
    ExecuteMsg, InstantiateMsg, QueryMsg, ConfigResponse, VestingInfoResponse,
    ClaimableAmountResponse, AllVestingResponse,
};
use crate::state::{Config, VestingSchedule, CONFIG, VESTING};

const CONTRACT_NAME: &str = "crates.io:prc20-vesting";
const CONTRACT_VERSION: &str = env!("CARGO_PKG_VERSION");

#[entry_point]
pub fn instantiate(
    deps: DepsMut,
    _env: Env,
    info: MessageInfo,
    msg: InstantiateMsg,
) -> Result<Response, ContractError> {
    set_contract_version(deps.storage, CONTRACT_NAME, CONTRACT_VERSION)?;

    let token_addr = deps.api.addr_validate(&msg.token_addr)?;

    let config = Config {
        owner: info.sender.clone(),
        token_addr,
    };
    CONFIG.save(deps.storage, &config)?;

    Ok(Response::new()
        .add_attribute("method", "instantiate")
        .add_attribute("owner", info.sender)
        .add_attribute("token_addr", msg.token_addr))
}

#[entry_point]
pub fn execute(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    msg: ExecuteMsg,
) -> Result<Response, ContractError> {
    match msg {
        ExecuteMsg::CreateVesting {
            beneficiary,
            total_amount,
            start_time,
            cliff_duration,
            vesting_duration,
        } => execute_create_vesting(
            deps,
            env,
            info,
            beneficiary,
            total_amount,
            start_time,
            cliff_duration,
            vesting_duration,
        ),
        ExecuteMsg::Claim {} => execute_claim(deps, env, info),
        ExecuteMsg::RevokeVesting { beneficiary } => {
            execute_revoke_vesting(deps, env, info, beneficiary)
        }
    }
}

pub fn execute_create_vesting(
    deps: DepsMut,
    _env: Env,
    info: MessageInfo,
    beneficiary: String,
    total_amount: String,
    start_time: u64,
    cliff_duration: u64,
    vesting_duration: u64,
) -> Result<Response, ContractError> {
    let config = CONFIG.load(deps.storage)?;
    
    if info.sender != config.owner {
        return Err(ContractError::Unauthorized {});
    }

    let beneficiary_addr = deps.api.addr_validate(&beneficiary)?;
    let total_amount_u128: u128 = total_amount
        .parse()
        .map_err(|_| ContractError::InvalidParams {})?;

    if total_amount_u128 == 0 {
        return Err(ContractError::InvalidParams {});
    }

    if cliff_duration > vesting_duration {
        return Err(ContractError::InvalidCliffDuration {});
    }

    if VESTING.may_load(deps.storage, beneficiary_addr.clone())?.is_some() {
        return Err(ContractError::VestingExists {});
    }

    let vesting_schedule = VestingSchedule {
        beneficiary: beneficiary_addr.clone(),
        total_amount: total_amount_u128,
        claimed_amount: 0,
        start_time,
        cliff_duration,
        vesting_duration,
        revoked: false,
    };

    VESTING.save(deps.storage, beneficiary_addr.clone(), &vesting_schedule)?;

    Ok(Response::new()
        .add_attribute("method", "create_vesting")
        .add_attribute("beneficiary", beneficiary)
        .add_attribute("total_amount", total_amount)
        .add_attribute("start_time", start_time.to_string()))
}

pub fn execute_claim(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
) -> Result<Response, ContractError> {
    let mut vesting = VESTING
        .may_load(deps.storage, info.sender.clone())?
        .ok_or(ContractError::VestingNotFound {})?;

    if vesting.revoked {
        return Err(ContractError::VestingNotFound {});
    }

    let claimable = calculate_claimable(&vesting, env.block.time.seconds())?;

    if claimable == 0 {
        return Err(ContractError::NothingToClaim {});
    }

    vesting.claimed_amount = vesting.claimed_amount
        .checked_add(claimable)
        .ok_or(ContractError::Overflow {})?;

    VESTING.save(deps.storage, info.sender.clone(), &vesting)?;

    let config = CONFIG.load(deps.storage)?;

    let transfer_msg = WasmMsg::Execute {
        contract_addr: config.token_addr.to_string(),
        msg: to_json_binary(&cw20::Cw20ExecuteMsg::Transfer {
            recipient: info.sender.to_string(),
            amount: Uint128::from(claimable),
        })?,
        funds: vec![],
    };

    Ok(Response::new()
        .add_message(CosmosMsg::Wasm(transfer_msg))
        .add_attribute("method", "claim")
        .add_attribute("beneficiary", info.sender)
        .add_attribute("amount", claimable.to_string()))
}

pub fn execute_revoke_vesting(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    beneficiary: String,
) -> Result<Response, ContractError> {
    let config = CONFIG.load(deps.storage)?;
    
    if info.sender != config.owner {
        return Err(ContractError::Unauthorized {});
    }

    let beneficiary_addr = deps.api.addr_validate(&beneficiary)?;
    let mut vesting = VESTING
        .may_load(deps.storage, beneficiary_addr.clone())?
        .ok_or(ContractError::VestingNotFound {})?;

    if vesting.revoked {
        return Err(ContractError::VestingNotFound {});
    }

    let claimable = calculate_claimable(&vesting, env.block.time.seconds())?;
    
    vesting.revoked = true;
    VESTING.save(deps.storage, beneficiary_addr, &vesting)?;

    let unvested = vesting.total_amount
        .checked_sub(vesting.claimed_amount)
        .and_then(|v| v.checked_sub(claimable))
        .ok_or(ContractError::Overflow {})?;

    let transfer_msg = WasmMsg::Execute {
        contract_addr: config.token_addr.to_string(),
        msg: to_json_binary(&cw20::Cw20ExecuteMsg::Transfer {
            recipient: config.owner.to_string(),
            amount: Uint128::from(unvested),
        })?,
        funds: vec![],
    };

    Ok(Response::new()
        .add_message(CosmosMsg::Wasm(transfer_msg))
        .add_attribute("method", "revoke_vesting")
        .add_attribute("beneficiary", beneficiary)
        .add_attribute("unvested_amount", unvested.to_string()))
}

fn calculate_claimable(vesting: &VestingSchedule, current_time: u64) -> Result<u128, ContractError> {
    if current_time < vesting.start_time {
        return Ok(0);
    }

    let elapsed = current_time
        .checked_sub(vesting.start_time)
        .ok_or(ContractError::Overflow {})?;

    if elapsed < vesting.cliff_duration {
        return Ok(0);
    }

    if vesting.vesting_duration == 0 {
        return Err(ContractError::DivisionByZero {});
    }

    let vested = if elapsed >= vesting.vesting_duration {
        vesting.total_amount
    } else {
        let vested_amount = (vesting.total_amount as u128)
            .checked_mul(elapsed as u128)
            .and_then(|v| v.checked_div(vesting.vesting_duration as u128))
            .ok_or(ContractError::Overflow {})?;
        vested_amount
    };

    let claimable = vested
        .checked_sub(vesting.claimed_amount)
        .ok_or(ContractError::Overflow {})?;

    Ok(claimable)
}

#[entry_point]
pub fn query(deps: Deps, env: Env, msg: QueryMsg) -> StdResult<Binary> {
    match msg {
        QueryMsg::Config {} => to_json_binary(&query_config(deps)?),
        QueryMsg::VestingInfo { beneficiary } => {
            to_json_binary(&query_vesting_info(deps, beneficiary)?)
        }
        QueryMsg::ClaimableAmount { beneficiary } => {
            to_json_binary(&query_claimable_amount(deps, env, beneficiary)?)
        }
        QueryMsg::AllVesting {} => to_json_binary(&query_all_vesting(deps)?),
    }
}

fn query_config(deps: Deps) -> StdResult<ConfigResponse> {
    let config = CONFIG.load(deps.storage)?;
    Ok(ConfigResponse {
        owner: config.owner,
        token_addr: config.token_addr,
    })
}

fn query_vesting_info(deps: Deps, beneficiary: String) -> StdResult<VestingInfoResponse> {
    let beneficiary_addr = deps.api.addr_validate(&beneficiary)?;
    let vesting = VESTING.load(deps.storage, beneficiary_addr)?;

    Ok(VestingInfoResponse {
        beneficiary: vesting.beneficiary,
        total_amount: vesting.total_amount.to_string(),
        claimed_amount: vesting.claimed_amount.to_string(),
        start_time: vesting.start_time,
        cliff_duration: vesting.cliff_duration,
        vesting_duration: vesting.vesting_duration,
        revoked: vesting.revoked,
    })
}

fn query_claimable_amount(
    deps: Deps,
    env: Env,
    beneficiary: String,
) -> StdResult<ClaimableAmountResponse> {
    let beneficiary_addr = deps.api.addr_validate(&beneficiary)?;
    let vesting = VESTING.load(deps.storage, beneficiary_addr)?;

    let claimable = calculate_claimable(&vesting, env.block.time.seconds())
        .map_err(|e| cosmwasm_std::StdError::generic_err(e.to_string()))?;

    Ok(ClaimableAmountResponse {
        amount: claimable.to_string(),
    })
}

fn query_all_vesting(deps: Deps) -> StdResult<AllVestingResponse> {
    let vesting_schedules: Vec<VestingInfoResponse> = VESTING
        .range(deps.storage, None, None, cosmwasm_std::Order::Ascending)
        .filter_map(|item| {
            item.ok().map(|(_, vesting)| VestingInfoResponse {
                beneficiary: vesting.beneficiary,
                total_amount: vesting.total_amount.to_string(),
                claimed_amount: vesting.claimed_amount.to_string(),
                start_time: vesting.start_time,
                cliff_duration: vesting.cliff_duration,
                vesting_duration: vesting.vesting_duration,
                revoked: vesting.revoked,
            })
        })
        .collect();

    Ok(AllVestingResponse { vesting_schedules })
}

mod cw20 {
    use cosmwasm_std::Uint128;
    use schemars::JsonSchema;
    use serde::{Deserialize, Serialize};

    #[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
    #[serde(rename_all = "snake_case")]
    pub enum Cw20ExecuteMsg {
        Transfer { recipient: String, amount: Uint128 },
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
echo "   2. Run: ./build_vesting.sh"
echo ""