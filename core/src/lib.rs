//! EEZE Chain core: everything a node needs to agree with every other node.
//! No networking in here, just the rules.

pub mod abi;
pub mod api;
pub mod chain;
pub mod state;
pub mod types;
pub mod vm;

pub use chain::{Added, Chain};
pub use state::{Genesis, Receipt, State};
pub use types::*;
