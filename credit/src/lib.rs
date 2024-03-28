use async_graphql::{Request, Response, SimpleObject};
use linera_sdk::base::{Amount, ApplicationId, ContractAbi, Owner, ServiceAbi, Timestamp};
use serde::{Deserialize, Serialize};

pub struct CreditAbi;

impl ContractAbi for CreditAbi {
    type Parameters = ();
    type InitializationArgument = InitializationArgument;
    type Operation = Operation;
    type Response = ();
}

impl ServiceAbi for CreditAbi {
    type Parameters = ();
    type Query = Request;
    type QueryResponse = Response;
}

#[derive(Debug, Deserialize, Serialize, Clone, SimpleObject)]
pub struct AgeAmount {
    pub amount: Amount,
    pub expired: Timestamp,
}

#[derive(Debug, Deserialize, Serialize, Clone, SimpleObject)]
pub struct AgeAmounts {
    pub amounts: Vec<AgeAmount>,
}

impl AgeAmounts {
    pub fn sum(&self) -> Amount {
        let mut _sum = Amount::ZERO;
        self.amounts
            .iter()
            .for_each(|a| _sum = _sum.try_add(a.amount).unwrap());
        _sum
    }
}

#[derive(Clone, Debug, Deserialize, Eq, Ord, PartialEq, PartialOrd, Serialize)]
pub struct InitializationArgument {
    pub initial_supply: Amount,
    pub amount_alive_ms: u64,
}

#[derive(Debug, Deserialize, Serialize)]
pub enum Operation {
    Liquidate,
    Transfer {
        from: Owner,
        to: Owner,
        amount: Amount,
    },
    TransferExt {
        to: Owner,
        amount: Amount,
    },
    SetRewardCallers {
        application_ids: Vec<ApplicationId>,
    },
    SetTransferCallers {
        application_ids: Vec<ApplicationId>,
    },
    RequestSubscribe,
}

#[derive(Debug, Deserialize, Serialize)]
pub enum ApplicationCall {
    Reward {
        owner: Owner,
        amount: Amount,
    },
    Transfer {
        from: Owner,
        to: Owner,
        amount: Amount,
    },
}

#[derive(Debug, PartialEq, Serialize, Deserialize)]
pub enum Message {
    InitializationArgument {
        argument: InitializationArgument,
    },
    Liquidate,
    Reward {
        owner: Owner,
        amount: Amount,
    },
    Transfer {
        from: Owner,
        to: Owner,
        amount: Amount,
    },
    TransferExt {
        to: Owner,
        amount: Amount,
    },
    SetRewardCallers {
        application_ids: Vec<ApplicationId>,
    },
    SetTransferCallers {
        application_ids: Vec<ApplicationId>,
    },
    RequestSubscribe,
}
