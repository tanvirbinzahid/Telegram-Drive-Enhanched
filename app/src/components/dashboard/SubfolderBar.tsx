import { useState } from 'react';
import { Folder, Plus } from 'lucide-react';
import { TelegramSubfolder } from '../../types';

interface SubfolderBarProps {
    subfolders: TelegramSubfolder[];
    activeSubfolderId: number | null;
    onSelect: (id: number | null) => void;
    onCreate: (name: string) => Promise<void>;
}

export function SubfolderBar({ subfolders, activeSubfolderId, onSelect, onCreate }: SubfolderBarProps) {
    const [showInput, setShowInput] = useState(false);
    const [newName, setNewName] = useState('');

    const submitCreate = async () => {
        const trimmedName = newName.trim();
        if (!trimmedName) return;
        try {
            await onCreate(trimmedName);
            setNewName('');
            setShowInput(false);
        } catch {
            // errors handled upstream
        }
    };

    return (
        <div className="px-6 py-2 border-b border-telegram-border bg-telegram-surface/60">
            <div className="flex items-center gap-2 text-xs text-telegram-subtext mb-2">
                <Folder className="w-3 h-3" />
                <span>Subfolders</span>
            </div>
            <div className="flex flex-wrap items-center gap-2">
                <button
                    onClick={() => onSelect(null)}
                    className={`px-3 py-1 rounded-full text-xs border transition ${activeSubfolderId === null
                        ? 'border-telegram-primary text-telegram-primary bg-telegram-primary/10'
                        : 'border-telegram-border text-telegram-subtext hover:text-telegram-text hover:border-telegram-primary/50'
                        }`}
                >
                    General
                </button>
                {subfolders.map((subfolder) => (
                    <button
                        key={subfolder.id}
                        onClick={() => onSelect(subfolder.id)}
                        className={`px-3 py-1 rounded-full text-xs border transition ${activeSubfolderId === subfolder.id
                            ? 'border-telegram-primary text-telegram-primary bg-telegram-primary/10'
                            : 'border-telegram-border text-telegram-subtext hover:text-telegram-text hover:border-telegram-primary/50'
                            }`}
                        title={subfolder.name}
                    >
                        {subfolder.name}
                    </button>
                ))}
                {showInput ? (
                    <input
                        autoFocus
                        type="text"
                        className="bg-telegram-hover border border-telegram-border rounded-full px-3 py-1 text-xs text-telegram-text focus:outline-none focus:border-telegram-primary/50"
                        placeholder="New subfolder"
                        value={newName}
                        onChange={(e) => setNewName(e.target.value)}
                        onKeyDown={(e) => e.key === 'Enter' && submitCreate()}
                        onBlur={() => {
                            setShowInput(false);
                            setNewName('');
                        }}
                    />
                ) : (
                    <button
                        onClick={() => setShowInput(true)}
                        className="px-3 py-1 rounded-full text-xs border border-dashed border-telegram-border text-telegram-subtext hover:text-telegram-text hover:border-telegram-primary/50 transition flex items-center gap-1"
                    >
                        <Plus className="w-3 h-3" />
                        New subfolder
                    </button>
                )}
            </div>
        </div>
    );
}
