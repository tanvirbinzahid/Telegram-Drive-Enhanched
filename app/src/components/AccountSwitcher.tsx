import React, { useState, useRef, useEffect } from "react";
import { ChevronDown, Plus, Trash2 } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import { TelegramAccount } from "../types";

interface AccountSwitcherProps {
  accounts: TelegramAccount[];
  activeAccountId: string | null;
  onSwitch: (accountId: string) => Promise<boolean>;
  onRemove: (accountId: string) => Promise<boolean>;
  onAddNew: () => void;
  disabled?: boolean;
}

export function AccountSwitcher({
  accounts,
  activeAccountId,
  onSwitch,
  onRemove,
  onAddNew,
  disabled = false,
}: AccountSwitcherProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [removingId, setRemovingId] = useState<string | null>(null);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    }

    if (isOpen) {
      document.addEventListener("mousedown", handleClickOutside);
    }
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [isOpen]);

  const activeAccount = accounts.find((acc) => acc.id === activeAccountId);

  const handleRemove = async (accountId: string, e: React.MouseEvent) => {
    e.stopPropagation();
    setRemovingId(accountId);
    const success = await onRemove(accountId);
    if (success) {
      setRemovingId(null);
      setIsOpen(false);
    } else {
      setRemovingId(null);
    }
  };

  const handleSwitch = async (accountId: string) => {
    const success = await onSwitch(accountId);
    if (success) {
      setIsOpen(false);
    }
  };

  const displayName = activeAccount?.name || "No Account";
  const displayPhone = activeAccount?.phone || "";

  return (
    <div className="relative" ref={dropdownRef}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        disabled={disabled || accounts.length === 0}
        className="flex items-center gap-2 px-3 py-2 rounded-lg bg-telegram-secondary hover:bg-telegram-secondary/80 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        title="Switch account"
      >
        <div className="flex flex-col text-left">
          <span className="text-sm font-medium text-white truncate max-w-[120px]">
            {displayName}
          </span>
          {displayPhone && (
            <span className="text-xs text-telegram-subtext truncate">
              {displayPhone}
            </span>
          )}
        </div>
        <ChevronDown
          size={16}
          className={`text-telegram-subtext transition-transform ${
            isOpen ? "rotate-180" : ""
          }`}
        />
      </button>

      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, y: -8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            className="absolute right-0 mt-2 w-64 bg-telegram-secondary rounded-xl shadow-lg border border-telegram-hover z-50"
          >
            <div className="p-2 max-h-80 overflow-y-auto">
              {/* Account List */}
              {accounts.length > 0 && (
                <div className="space-y-1 pb-2 border-b border-telegram-hover">
                  {accounts.map((account) => (
                    <div
                      key={account.id}
                      className={`flex items-center justify-between p-2 rounded-lg transition-colors cursor-pointer ${
                        activeAccountId === account.id
                          ? "bg-telegram-primary/20"
                          : "hover:bg-telegram-hover"
                      }`}
                      onClick={() => handleSwitch(account.id)}
                    >
                      <div className="flex-1 min-w-0">
                        <div className="text-sm font-medium text-white truncate">
                          {account.name}
                        </div>
                        {account.phone && (
                          <div className="text-xs text-telegram-subtext truncate">
                            {account.phone}
                          </div>
                        )}
                      </div>
                      {removingId !== account.id && (
                        <button
                          onClick={(e) => handleRemove(account.id, e)}
                          className="ml-2 p-1 rounded hover:bg-red-500/20 transition-colors"
                          title="Remove account"
                        >
                          <Trash2
                            size={14}
                            className="text-red-400 hover:text-red-300"
                          />
                        </button>
                      )}
                      {removingId === account.id && (
                        <div className="ml-2 text-xs text-telegram-subtext">
                          Removing...
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              )}

              {/* Add New Account Button */}
              <button
                onClick={() => {
                  setIsOpen(false);
                  onAddNew();
                }}
                className="w-full flex items-center gap-2 p-2 text-sm text-telegram-primary hover:bg-telegram-hover rounded-lg transition-colors"
              >
                <Plus size={16} />
                <span>Add New Account</span>
              </button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
