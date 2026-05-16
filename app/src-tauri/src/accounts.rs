use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use std::collections::HashMap;

/// Represents a Telegram account
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct Account {
    pub id: String,
    pub name: String,
    pub api_id: i32,
    pub api_hash: String,
    pub phone: Option<String>,
}

impl Account {
    /// Generate a new account with a unique ID
    pub fn new(name: String, api_id: i32, api_hash: String, phone: Option<String>) -> Self {
        let id = uuid::Uuid::new_v4().to_string();
        Account {
            id,
            name,
            api_id,
            api_hash,
            phone,
        }
    }

    /// Get the session file path for this account
    pub fn session_path(&self, app_data_dir: &PathBuf) -> PathBuf {
        app_data_dir.join(format!("telegram_session_{}.db", self.id))
    }
}

/// Configuration for multi-account management
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AccountsConfig {
    /// List of all accounts
    pub accounts: HashMap<String, Account>,
    /// ID of the currently active account (None if no account is active)
    pub active_account_id: Option<String>,
}

impl Default for AccountsConfig {
    fn default() -> Self {
        AccountsConfig {
            accounts: HashMap::new(),
            active_account_id: None,
        }
    }
}

impl AccountsConfig {
    /// Create an empty config
    pub fn new() -> Self {
        Self::default()
    }

    /// Get the active account, if any
    pub fn get_active_account(&self) -> Option<&Account> {
        self.active_account_id
            .as_ref()
            .and_then(|id| self.accounts.get(id))
    }

    /// Get a mutable reference to the active account, if any
    pub fn get_active_account_mut(&mut self) -> Option<&mut Account> {
        let id = self.active_account_id.clone();
        id.and_then(|id| self.accounts.get_mut(&id))
    }

    /// Add a new account
    pub fn add_account(&mut self, account: Account) {
        self.accounts.insert(account.id.clone(), account);
    }

    /// Remove an account by ID
    pub fn remove_account(&mut self, account_id: &str) {
        self.accounts.remove(account_id);
        // If we removed the active account, clear it
        if self.active_account_id.as_deref() == Some(account_id) {
            self.active_account_id = None;
        }
    }

    /// Switch to a different account
    pub fn switch_account(&mut self, account_id: &str) -> Result<(), String> {
        if !self.accounts.contains_key(account_id) {
            return Err(format!("Account with ID {} not found", account_id));
        }
        self.active_account_id = Some(account_id.to_string());
        Ok(())
    }

    /// List all account IDs
    pub fn list_account_ids(&self) -> Vec<String> {
        self.accounts.keys().cloned().collect()
    }

    /// Get an account by ID
    pub fn get_account(&self, account_id: &str) -> Option<&Account> {
        self.accounts.get(account_id)
    }

    /// Check if an account exists
    pub fn has_account(&self, account_id: &str) -> bool {
        self.accounts.contains_key(account_id)
    }

    /// Migrate from legacy single-account format
    /// Takes api_id and api_hash from old config and creates an account
    pub fn migrate_from_legacy(api_id: i32, api_hash: String) -> Self {
        let account = Account::new(
            "Default Account".to_string(),
            api_id,
            api_hash,
            None,
        );
        let account_id = account.id.clone();
        
        let mut config = AccountsConfig::new();
        config.add_account(account);
        config.active_account_id = Some(account_id);
        config
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_account_creation() {
        let account = Account::new(
            "Test Account".to_string(),
            12345,
            "test_hash".to_string(),
            Some("+1234567890".to_string()),
        );
        assert_eq!(account.name, "Test Account");
        assert_eq!(account.api_id, 12345);
        assert_eq!(account.api_hash, "test_hash");
        assert_eq!(account.phone, Some("+1234567890".to_string()));
    }

    #[test]
    fn test_accounts_config_operations() {
        let mut config = AccountsConfig::new();
        assert_eq!(config.get_active_account(), None);

        let account1 = Account::new(
            "Account 1".to_string(),
            111,
            "hash1".to_string(),
            None,
        );
        let account_id = account1.id.clone();
        config.add_account(account1);

        assert_eq!(config.list_account_ids().len(), 1);
        assert_eq!(config.get_account(&account_id).unwrap().name, "Account 1");

        config.switch_account(&account_id).unwrap();
        assert_eq!(config.get_active_account().unwrap().name, "Account 1");
    }

    #[test]
    fn test_migrate_from_legacy() {
        let config = AccountsConfig::migrate_from_legacy(12345, "test_hash".to_string());
        assert_eq!(config.accounts.len(), 1);
        assert!(config.active_account_id.is_some());
        
        let active = config.get_active_account().unwrap();
        assert_eq!(active.api_id, 12345);
        assert_eq!(active.api_hash, "test_hash");
    }
}
