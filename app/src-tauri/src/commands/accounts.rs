use tauri::State;
use tauri::Manager;
use crate::TelegramState;
use crate::accounts::AccountsConfig;
use crate::models::{AccountInfo, AccountsConfigResponse};
use std::sync::atomic::Ordering;
use tokio::time::Duration;

/// Load accounts config from persistent storage
pub async fn load_accounts_config(
    app_handle: &tauri::AppHandle,
) -> Result<AccountsConfig, String> {
    let app_data_dir = app_handle.path().app_data_dir()
        .map_err(|e| format!("Failed to get app data dir: {}", e))?;
    
    if !app_data_dir.exists() {
        std::fs::create_dir_all(&app_data_dir)
            .map_err(|e| format!("Failed to create app data dir: {}", e))?;
    }
    
    let config_path = app_data_dir.join("accounts.json");
    
    if config_path.exists() {
        let config_str = std::fs::read_to_string(&config_path)
            .map_err(|e| format!("Failed to read accounts config: {}", e))?;
        serde_json::from_str(&config_str)
            .map_err(|e| format!("Failed to parse accounts config: {}", e))
    } else {
        Ok(AccountsConfig::new())
    }
}

/// Save accounts config to persistent storage
pub async fn save_accounts_config(
    app_handle: &tauri::AppHandle,
    config: &AccountsConfig,
) -> Result<(), String> {
    let app_data_dir = app_handle.path().app_data_dir()
        .map_err(|e| format!("Failed to get app data dir: {}", e))?;
    
    if !app_data_dir.exists() {
        std::fs::create_dir_all(&app_data_dir)
            .map_err(|e| format!("Failed to create app data dir: {}", e))?;
    }
    
    let config_path = app_data_dir.join("accounts.json");
    let config_str = serde_json::to_string_pretty(&config)
        .map_err(|e| format!("Failed to serialize accounts config: {}", e))?;
    
    std::fs::write(&config_path, config_str)
        .map_err(|e| format!("Failed to write accounts config: {}", e))
}

/// Get the session path for an account
pub fn get_account_session_path(
    app_handle: &tauri::AppHandle,
    account_id: &str,
) -> Result<std::path::PathBuf, String> {
    let app_data_dir = app_handle.path().app_data_dir()
        .map_err(|e| format!("Failed to get app data dir: {}", e))?;
    
    if !app_data_dir.exists() {
        std::fs::create_dir_all(&app_data_dir)
            .map_err(|e| format!("Failed to create app data dir: {}", e))?;
    }
    
    Ok(app_data_dir.join(format!("telegram_session_{}.db", account_id)))
}

#[tauri::command]
pub async fn cmd_list_accounts(
    app_handle: tauri::AppHandle,
) -> Result<AccountsConfigResponse, String> {
    let config = load_accounts_config(&app_handle).await?;
    
    let mut accounts: Vec<AccountInfo> = config.accounts.values()
        .map(|acc| AccountInfo {
            id: acc.id.clone(),
            name: acc.name.clone(),
            api_id: acc.api_id,
            api_hash: acc.api_hash.clone(),
            phone: acc.phone.clone(),
        })
        .collect();
    
    // Sort by account name for consistent display
    accounts.sort_by(|a, b| a.name.cmp(&b.name));
    
    Ok(AccountsConfigResponse {
        accounts,
        active_account_id: config.active_account_id,
    })
}

#[tauri::command]
pub async fn cmd_add_account(
    app_handle: tauri::AppHandle,
    name: String,
    api_id: i32,
    api_hash: String,
    phone: Option<String>,
) -> Result<AccountInfo, String> {
    if name.trim().is_empty() {
        return Err("Account name cannot be empty".to_string());
    }
    
    if api_hash.trim().is_empty() {
        return Err("API hash cannot be empty".to_string());
    }
    
    let mut config = load_accounts_config(&app_handle).await?;
    
    let account = crate::accounts::Account::new(name, api_id, api_hash, phone);
    let account_info = AccountInfo {
        id: account.id.clone(),
        name: account.name.clone(),
        api_id: account.api_id,
        api_hash: account.api_hash.clone(),
        phone: account.phone.clone(),
    };
    
    config.add_account(account);
    save_accounts_config(&app_handle, &config).await?;
    
    Ok(account_info)
}

#[tauri::command]
pub async fn cmd_remove_account(
    app_handle: tauri::AppHandle,
    account_id: String,
    state: State<'_, TelegramState>,
) -> Result<bool, String> {
    let mut config = load_accounts_config(&app_handle).await?;
    
    // If removing the active account, disconnect it first
    let active_id = config.active_account_id.as_deref();
    if active_id == Some(&account_id) {
        // Shutdown the network runner
        {
            let mut shutdown_guard = state.runner_shutdown.lock().unwrap();
            if let Some(shutdown_tx) = shutdown_guard.take() {
                log::info!("Signaling runner shutdown for account removal...");
                let _ = shutdown_tx.send(());
            }
        }
        
        // Clear state
        *state.client.lock().await = None;
        *state.login_token.lock().await = None;
        *state.password_token.lock().await = None;
        *state.api_id.lock().await = None;
        *state.account_id.lock().await = None;
        crate::commands::utils::clear_peer_cache(&state.peer_cache).await;
        state.cancelled_transfers.write().await.clear();
    }
    
    // Remove the session file
    let session_path = get_account_session_path(&app_handle, &account_id)?;
    let _ = std::fs::remove_file(&session_path);
    let _ = std::fs::remove_file(format!("{}-wal", session_path.to_string_lossy()));
    let _ = std::fs::remove_file(format!("{}-shm", session_path.to_string_lossy()));
    
    // Remove from config
    config.remove_account(&account_id);
    save_accounts_config(&app_handle, &config).await?;
    
    Ok(true)
}

#[tauri::command]
pub async fn cmd_switch_account(
    app_handle: tauri::AppHandle,
    account_id: String,
    state: State<'_, TelegramState>,
) -> Result<AccountInfo, String> {
    let mut config = load_accounts_config(&app_handle).await?;
    
    // Get the target account
    let target_account = config.get_account(&account_id)
        .ok_or_else(|| format!("Account with ID {} not found", account_id))?
        .clone();
    
    // Shutdown the current runner
    {
        let mut shutdown_guard = state.runner_shutdown.lock().unwrap();
        if let Some(shutdown_tx) = shutdown_guard.take() {
            log::info!("Signaling runner shutdown for account switch...");
            let _ = shutdown_tx.send(());
        }
    }
    
    // Wait a bit for the runner to shut down
    tokio::time::sleep(Duration::from_millis(100)).await;
    
    // Clear state
    *state.client.lock().await = None;
    *state.login_token.lock().await = None;
    *state.password_token.lock().await = None;
    *state.api_id.lock().await = None;
    crate::commands::utils::clear_peer_cache(&state.peer_cache).await;
    state.cancelled_transfers.write().await.clear();
    
    // Update state with new account
    *state.account_id.lock().await = Some(account_id.clone());
    
    // Switch in config
    config.switch_account(&account_id)?;
    save_accounts_config(&app_handle, &config).await?;
    
    Ok(AccountInfo {
        id: target_account.id,
        name: target_account.name,
        api_id: target_account.api_id,
        api_hash: target_account.api_hash,
        phone: target_account.phone,
    })
}

#[tauri::command]
pub async fn cmd_get_active_account(
    app_handle: tauri::AppHandle,
) -> Result<Option<AccountInfo>, String> {
    let config = load_accounts_config(&app_handle).await?;
    
    Ok(config.get_active_account().map(|acc| AccountInfo {
        id: acc.id.clone(),
        name: acc.name.clone(),
        api_id: acc.api_id,
        api_hash: acc.api_hash.clone(),
        phone: acc.phone.clone(),
    }))
}
