#![cfg_attr(target_arch = "wasm32", no_main)]

mod state;

use self::state::Application;
use async_trait::async_trait;
use linera_sdk::{base::WithServiceAbi, QueryContext, Service, ViewStateStorage};
use std::sync::Arc;
use thiserror::Error;

linera_sdk::service!(Application);

impl WithServiceAbi for Application {
    type Abi = activity::ApplicationAbi;
}

#[async_trait]
impl Service for Application {
    type Error = ServiceError;
    type Storage = ViewStateStorage<Self>;

    async fn handle_query(
        self: Arc<Self>,
        _context: &QueryContext,
        _query: Self::Query,
    ) -> Result<(), Self::Error> {
        Err(ServiceError::QueriesNotSupported)
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
