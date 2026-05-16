import { useState, useCallback, useEffect } from "react";
import { invoke } from "@tauri-apps/api/core";
import { TelegramAccount, AccountsConfig } from "../types";
import { toast } from "sonner";

export function useAccountManager() {
  const [accounts, setAccounts] = useState<TelegramAccount[]>([]);
  const [activeAccountId, setActiveAccountId] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  // Load all accounts
  const loadAccounts = useCallback(async () => {
    try {
      setLoading(true);
      const config = await invoke<AccountsConfig>("cmd_list_accounts");
      setAccounts(config.accounts || []);
      setActiveAccountId(config.active_account_id || null);
    } catch (err) {
      console.error("Failed to load accounts:", err);
      // If there's an error loading accounts, it's likely the first run
      setAccounts([]);
      setActiveAccountId(null);
    } finally {
      setLoading(false);
    }
  }, []);

  // Add a new account
  const addAccount = useCallback(
    async (
      name: string,
      apiId: number,
      apiHash: string,
      phone?: string
    ): Promise<TelegramAccount | null> => {
      try {
        const newAccount = await invoke<TelegramAccount>("cmd_add_account", {
          name,
          api_id: apiId,
          api_hash: apiHash,
          phone,
        });
        setAccounts((prev) => [...prev, newAccount]);
        toast.success("Account added successfully");
        return newAccount;
      } catch (err) {
        const errorMsg = err instanceof Error ? err.message : String(err);
        toast.error(`Failed to add account: ${errorMsg}`);
        return null;
      }
    },
    []
  );

  // Remove an account
  const removeAccount = useCallback(async (accountId: string): Promise<boolean> => {
    try {
      await invoke<boolean>("cmd_remove_account", { account_id: accountId });
      setAccounts((prev) => prev.filter((acc) => acc.id !== accountId));
      if (activeAccountId === accountId) {
        setActiveAccountId(null);
      }
      toast.success("Account removed successfully");
      return true;
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : String(err);
      toast.error(`Failed to remove account: ${errorMsg}`);
      return false;
    }
  }, [activeAccountId]);

  // Switch to a different account
  const switchAccount = useCallback(
    async (accountId: string): Promise<boolean> => {
      try {
        await invoke<TelegramAccount>("cmd_switch_account", {
          account_id: accountId,
        });
        setActiveAccountId(accountId);
        toast.success("Account switched successfully");
        return true;
      } catch (err) {
        const errorMsg = err instanceof Error ? err.message : String(err);
        toast.error(`Failed to switch account: ${errorMsg}`);
        return false;
      }
    },
    []
  );

  // Get the active account
  const getActiveAccount = useCallback((): TelegramAccount | undefined => {
    return accounts.find((acc) => acc.id === activeAccountId);
  }, [accounts, activeAccountId]);

  // Load accounts on mount
  useEffect(() => {
    loadAccounts();
  }, [loadAccounts]);

  return {
    accounts,
    activeAccountId,
    loading,
    loadAccounts,
    addAccount,
    removeAccount,
    switchAccount,
    getActiveAccount,
  };
}
