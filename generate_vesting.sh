#!/usr/bin/env bash
# generate_vesting.sh - FIXED VERSION v3 (Audit)
# Fixes: Pagination for Scalability

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${BLUE}=========================================="
echo "  VESTING CONTRACT GENERATOR (FIXED v3)"
echo "  + Audit Fixes: Pagination & Safety"
echo "==========================================${NC}"

if ! command -v cargo &> /dev/null; then
    echo -e "${RED}✗ Rust tidak ditemukan!${NC}"
    exit 1
fi

mkdir -p contracts/prc20-vesting/src
cd contracts/prc20-vesting

# FIXED Cargo.toml - pin base64ct to 1.6.0
cat > Cargo.toml << 'EOF'
[package]
name = "prc20-vesting"
version = "1.0.1"
edition = "2021"

[lib]
crate-type = ["cdylib", "rlib"]

[dependencies]
cosmwasm-std = "1.5.0"
cosmwasm-schema = "1.5.0"
cw-storage-plus = "1.2.0"
cw2 = "1.1.0"
schemars = "0.8.16"
serde = { version = "1.0.193", default-features = false, features = ["derive"] }
thiserror = "1.0.50"
base64ct = "=1.6.0"

[dev-dependencies]
cw-multi-test = "0.20.0"

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
pub struct InstantiateMsg {
    pub token_addr: String,
}

#[cw_serde]
pub enum ExecuteMsg {
    CreateVesting {
        beneficiary: String,
        total_amount: Uint128,
        start_time: u64,
        cliff_duration: u64,
        vesting_duration: u64,
    },
    Claim {},
    RevokeVesting { beneficiary: String },
}

#[cw_serde]
#[derive(QueryResponses)]
pub enum QueryMsg {
    #[returns(VestingInfoResponse)]
    VestingInfo { beneficiary: String },
    #[returns(ClaimableAmountResponse)]
    ClaimableAmount { beneficiary: String },
    #[returns(AllVestingResponse)]
    AllVesting { 
        start_after: Option<String>,
        limit: Option<u32>,
    },
    #[returns(ConfigResponse)]
    Config {},
}

#[cw_serde]
pub struct VestingSchedule {
    pub beneficiary: Addr,
    pub total_amount: Uint128,
    pub claimed_amount: Uint128,
    pub start_time: u64,
    pub cliff_time: u64,
    pub end_time: u64,
    pub revoked: bool,
}

#[cw_serde]
pub struct VestingInfoResponse {
    pub schedule: VestingSchedule,
}

#[cw_serde]
pub struct ClaimableAmountResponse {
    pub claimable: Uint128,
}

#[cw_serde]
pub struct AllVestingResponse {
    pub schedules: Vec<VestingSchedule>,
}

#[cw_serde]
pub struct ConfigResponse {
    pub token_addr: String,
    pub owner: String,
}
EOF

cat > src/state.rs << 'EOF'
use cosmwasm_std::{Addr, Uint128};
use cw_storage_plus::{Item, Map};
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct Config {
    pub token_addr: Addr,
    pub owner: Addr,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct Vesting {
    pub beneficiary: Addr,
    pub total_amount: Uint128,
    pub claimed_amount: Uint128,
    pub start_time: u64,
    pub cliff_time: u64,
    pub end_time: u64,
    pub revoked: bool,
}

pub const CONFIG: Item<Config> = Item::new("config");
pub const VESTING_SCHEDULES: Map<Addr, Vesting> = Map::new("vesting_schedules");
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
    
    #[error("Vesting not found")]
    VestingNotFound {},
    
    #[error("Vesting already exists")]
    VestingAlreadyExists {},
    
    #[error("Invalid cliff time")]
    InvalidCliffTime {},
    
    #[error("Invalid vesting duration")]
    InvalidVestingDuration {},
    
    #[error("Amount must be greater than zero")]
    InvalidAmount {},
    
    #[error("No tokens to claim")]
    NoTokensToClaim {},
    
    #[error("Cliff not ended")]
    CliffNotEnded {},
    
    #[error("Vesting revoked")]
    VestingRevoked {},
    
    #[error("Overflow error")]
    Overflow {},
}
EOF

cat > src/contract.rs << 'EOF'
use cosmwasm_std::{
    entry_point, to_json_binary, Binary, Deps, DepsMut, Env, MessageInfo, 
    Response, StdResult, Uint128, WasmMsg, Order
};
use cw_storage_plus::Bound;
use cw2::set_contract_version;
use crate::error::ContractError;
use crate::msg::{ExecuteMsg, InstantiateMsg, QueryMsg, VestingInfoResponse, 
    ClaimableAmountResponse, AllVestingResponse, VestingSchedule, ConfigResponse};
use crate::state::{CONFIG, VESTING_SCHEDULES, Config, Vesting};

const CONTRACT_NAME: &str = "paxi:prc20-vesting";
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
        token_addr,
        owner: info.sender.clone(),
    };
    CONFIG.save(deps.storage, &config)?;
    Ok(Response::new()
        .add_attribute("action", "instantiate")
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

fn execute_create_vesting(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    beneficiary: String,
    total_amount: Uint128,
    start_time: u64,
    cliff_duration: u64,
    vesting_duration: u64,
) -> Result<Response, ContractError> {
    let config = CONFIG.load(deps.storage)?;
    
    if info.sender != config.owner {
        return Err(ContractError::Unauthorized {});
    }
    
    if total_amount.is_zero() {
        return Err(ContractError::InvalidAmount {});
    }
    
    if vesting_duration == 0 {
        return Err(ContractError::InvalidVestingDuration {});
    }
    
    let beneficiary = deps.api.addr_validate(&beneficiary)?;
    
    if VESTING_SCHEDULES.has(deps.storage, beneficiary.clone()) {
        return Err(ContractError::VestingAlreadyExists {});
    }
    
    let cliff_time = start_time
        .checked_add(cliff_duration)
        .ok_or(ContractError::Overflow {})?;
    let end_time = start_time
        .checked_add(vesting_duration)
        .ok_or(ContractError::Overflow {})?;
    
    if cliff_time > end_time {
        return Err(ContractError::InvalidCliffTime {});
    }
    
    let vesting = Vesting {
        beneficiary: beneficiary.clone(),
        total_amount,
        claimed_amount: Uint128::zero(),
        start_time,
        cliff_time,
        end_time,
        revoked: false,
    };

    VESTING_SCHEDULES.save(deps.storage, beneficiary.clone(), &vesting)?;
    
    let transfer_msg = WasmMsg::Execute {
        contract_addr: config.token_addr.to_string(),
        msg: to_json_binary(&Prc20ExecuteMsg::TransferFrom {
            owner: info.sender.to_string(),
            recipient: env.contract.address.to_string(),
            amount: total_amount,
        })?,
        funds: vec![],
    };
    
    Ok(Response::new()
        .add_message(transfer_msg)
        .add_attribute("action", "create_vesting")
        .add_attribute("beneficiary", beneficiary)
        .add_attribute("total_amount", total_amount))
}

fn execute_claim(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
) -> Result<Response, ContractError> {
    let mut vesting = VESTING_SCHEDULES
        .may_load(deps.storage, info.sender.clone())?
        .ok_or(ContractError::VestingNotFound {})?;
    
    if vesting.revoked {
        return Err(ContractError::VestingRevoked {});
    }
    
    let current_time = env.block.time.seconds();
    
    if current_time < vesting.cliff_time {
        return Err(ContractError::CliffNotEnded {});
    }
    
    let vested_amount = calculate_vested_amount(&vesting, current_time);
    let claimable = vested_amount
        .checked_sub(vesting.claimed_amount)
        .map_err(|_| ContractError::Overflow {})?;
    
    if claimable.is_zero() {
        return Err(ContractError::NoTokensToClaim {});
    }
    
    vesting.claimed_amount = vesting.claimed_amount
        .checked_add(claimable)
        .map_err(|_| ContractError::Overflow {})?;
    VESTING_SCHEDULES.save(deps.storage, info.sender.clone(), &vesting)?;
    
    let config = CONFIG.load(deps.storage)?;
    let transfer_msg = WasmMsg::Execute {
        contract_addr: config.token_addr.to_string(),
        msg: to_json_binary(&Prc20ExecuteMsg::Transfer {
            recipient: info.sender.to_string(),
            amount: claimable,
        })?,
        funds: vec![],
    };
    
    Ok(Response::new()
        .add_message(transfer_msg)
        .add_attribute("action", "claim")
        .add_attribute("amount", claimable))
}

fn execute_revoke_vesting(
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
    let mut vesting = VESTING_SCHEDULES
        .may_load(deps.storage, beneficiary_addr.clone())?
        .ok_or(ContractError::VestingNotFound {})?;
    
    if vesting.revoked {
        return Err(ContractError::VestingRevoked {});
    }
    
    let current_time = env.block.time.seconds();
    let vested_amount = calculate_vested_amount(&vesting, current_time);
    let unvested = vesting.total_amount
        .checked_sub(vested_amount)
        .map_err(|_| ContractError::Overflow {})?;
    
    vesting.revoked = true;
    VESTING_SCHEDULES.save(deps.storage, beneficiary_addr.clone(), &vesting)?;
    
    let mut messages = vec![];
    if !unvested.is_zero() {
        messages.push(WasmMsg::Execute {
            contract_addr: config.token_addr.to_string(),
            msg: to_json_binary(&Prc20ExecuteMsg::Transfer {
                recipient: config.owner.to_string(),
                amount: unvested,
            })?,
            funds: vec![],
        });
    }
    
    Ok(Response::new()
        .add_messages(messages)
        .add_attribute("action", "revoke_vesting")
        .add_attribute("beneficiary", beneficiary)
        .add_attribute("unvested_returned", unvested))
}

fn calculate_vested_amount(vesting: &Vesting, current_time: u64) -> Uint128 {
    if current_time < vesting.cliff_time {
        return Uint128::zero();
    }
    
    if current_time >= vesting.end_time {
        return vesting.total_amount;
    }
    
    let elapsed = current_time.saturating_sub(vesting.start_time);
    let total_duration = vesting.end_time.saturating_sub(vesting.start_time);
    
    if total_duration == 0 {
        return vesting.total_amount;
    }
    
    vesting.total_amount.multiply_ratio(elapsed, total_duration)
}

#[entry_point]
pub fn query(deps: Deps, _env: Env, msg: QueryMsg) -> StdResult<Binary> {
    match msg {
        QueryMsg::VestingInfo { beneficiary } => {
            to_json_binary(&query_vesting_info(deps, beneficiary)?)
        }
        QueryMsg::ClaimableAmount { beneficiary } => {
            to_json_binary(&query_claimable_amount(deps, _env, beneficiary)?)
        }
        QueryMsg::AllVesting { start_after, limit } => {
            to_json_binary(&query_all_vesting(deps, start_after, limit)?)
        }
        QueryMsg::Config {} => {
            to_json_binary(&query_config(deps)?)
        }
    }
}

fn query_config(deps: Deps) -> StdResult<ConfigResponse> {
    let config = CONFIG.load(deps.storage)?;
    Ok(ConfigResponse {
        token_addr: config.token_addr.to_string(),
        owner: config.owner.to_string(),
    })
}

fn query_vesting_info(deps: Deps, beneficiary: String) -> StdResult<VestingInfoResponse> {
    let beneficiary = deps.api.addr_validate(&beneficiary)?;
    let vesting = VESTING_SCHEDULES.load(deps.storage, beneficiary)?;
    Ok(VestingInfoResponse {
        schedule: VestingSchedule {
            beneficiary: vesting.beneficiary,
            total_amount: vesting.total_amount,
            claimed_amount: vesting.claimed_amount,
            start_time: vesting.start_time,
            cliff_time: vesting.cliff_time,
            end_time: vesting.end_time,
            revoked: vesting.revoked,
        },
    })
}

fn query_claimable_amount(
    deps: Deps,
    env: Env,
    beneficiary: String,
) -> StdResult<ClaimableAmountResponse> {
    let beneficiary = deps.api.addr_validate(&beneficiary)?;
    let vesting = VESTING_SCHEDULES.load(deps.storage, beneficiary)?;
    
    if vesting.revoked {
        return Ok(ClaimableAmountResponse { claimable: Uint128::zero() });
    }
    
    let current_time = env.block.time.seconds();
    let vested_amount = calculate_vested_amount(&vesting, current_time);
    let claimable = vested_amount.saturating_sub(vesting.claimed_amount);
    Ok(ClaimableAmountResponse { claimable })
}

fn query_all_vesting(deps: Deps, start_after: Option<String>, limit: Option<u32>) -> StdResult<AllVestingResponse> {
    let limit = limit.unwrap_or(10).min(30) as usize;
    let start_bound = match start_after {
        Some(s) => Some(Bound::exclusive(deps.api.addr_validate(&s)?)),
        None => None,
    };

    let schedules: Vec<VestingSchedule> = VESTING_SCHEDULES
        .range(deps.storage, start_bound, None, Order::Ascending)
        .take(limit)
        .map(|item| {
            let (_, vesting) = item?;
            Ok(VestingSchedule {
                beneficiary: vesting.beneficiary,
                total_amount: vesting.total_amount,
                claimed_amount: vesting.claimed_amount,
                start_time: vesting.start_time,
                cliff_time: vesting.cliff_time,
                end_time: vesting.end_time,
                revoked: vesting.revoked,
            })
        })
        .collect::<StdResult<Vec<_>>>()?;
    Ok(AllVestingResponse { schedules })
}

#[cosmwasm_schema::cw_serde]
enum Prc20ExecuteMsg {
    Transfer { recipient: String, amount: Uint128 },
    TransferFrom { owner: String, recipient: String, amount: Uint128 },
}
EOF

cd ../..

echo ""
echo -e "${GREEN}✓ Vesting Contract Generated! (FIXED v3 Audit)${NC}"
echo -e "${CYAN}Updates:${NC}"
echo -e "  • Pagination added to AllVesting query"
echo -e "  • Scalability improved"
echo ""
echo -e "${YELLOW}Next: ./build_vesting.sh${NC}"