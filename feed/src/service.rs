#![cfg_attr(target_arch = "wasm32", no_main)]

mod state;

use self::state::Feed;
use async_graphql::{EmptySubscription, Object, Request, Response, Schema};
use feed::Operation;
use linera_sdk::{
    base::{Amount, WithServiceAbi},
    Service, ServiceRuntime, ViewStateStorage,
};
use std::sync::Arc;
use thiserror::Error;

pub struct FeedService {
    state: Arc<Feed>,
}

linera_sdk::service!(FeedService);

impl WithServiceAbi for FeedService {
    type Abi = feed::FeedAbi;
}

impl Service for FeedService {
    type Error = ServiceError;
    type Storage = ViewStateStorage<Self>;
    type State = Feed;

    async fn new(state: Self::State, _runtime: ServiceRuntime<Self>) -> Result<Self, Self::Error> {
        Ok(FeedService {
            state: Arc::new(state),
        })
    }

    async fn handle_query(&self, request: Request) -> Result<Response, Self::Error> {
        // TODO: we need to filter content according to requester and review state here
        let schema: Schema<Arc<Feed>, MutationRoot, EmptySubscription> =
            Schema::build(self.state.clone(), MutationRoot {}, EmptySubscription).finish();
        let response = schema.execute(request).await;
        Ok(response)
    }
}

struct MutationRoot;

#[Object]
impl MutationRoot {
    async fn like(&self, ccid: String) -> Vec<u8> {
        cid::Cid::try_from(ccid.clone()).expect("Invalid content cid");
        bcs::to_bytes(&Operation::Like { cid: ccid }).unwrap()
    }

    async fn dislike(&self, ccid: String) -> Vec<u8> {
        cid::Cid::try_from(ccid.clone()).expect("Invalid content cid");
        bcs::to_bytes(&Operation::Dislike { cid: ccid }).unwrap()
    }

    async fn tip(&self, ccid: String, amount: Amount) -> Vec<u8> {
        cid::Cid::try_from(ccid.clone()).expect("Invalid content cid");
        bcs::to_bytes(&Operation::Tip { cid: ccid, amount }).unwrap()
    }

    async fn request_subscribe(&self) -> Vec<u8> {
        bcs::to_bytes(&Operation::RequestSubscribe).unwrap()
    }
}

/// An error that can occur while querying the service.
#[derive(Debug, Error)]
pub enum ServiceError {
    /// Query not supported by the application.
    #[error("Queries not supported by application")]
    QueriesNotSupported,

    /// Invalid query argument; could not deserialize request.
    #[error("Invalid query argument; could not deserialize request")]
    InvalidQuery(#[from] serde_json::Error),
    // Add error variants here.
}
