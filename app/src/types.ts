export interface TelegramFile {
    id: number;
    name: string;
    size: number;
    sizeStr: string; // Formatted size
    created_at?: string;
    type?: 'folder' | 'file'; // implied icon_type
    // Add other fields if backend sends them
}

export interface TelegramAccount {
    id: string;
    name: string;
    api_id: number;
    api_hash: string;
    phone?: string;
}

export interface AccountsConfig {
    accounts: TelegramAccount[];
    active_account_id?: string;
}

export interface TelegramFolder {
    id: number;
    name: string;
    parent_id?: number;
}

export interface TelegramSubfolder {
    id: number;
    folder_id: number;
    name: string;
}

export interface QueueItem {
    id: string;
    path: string;
    folderId: number | null;
    subfolderId?: number | null;
    status: 'pending' | 'uploading' | 'success' | 'error' | 'cancelled';
    error?: string;
    progress?: number; // 0-100
    uploadedBytes?: number;
    totalBytes?: number;
    speedBytesPerSec?: number;
}

export interface BandwidthStats {
    up_bytes: number;
    down_bytes: number;
}

export interface DownloadItem {
    id: string;
    messageId: number;
    filename: string;
    folderId: number | null;
    status: 'pending' | 'downloading' | 'success' | 'error' | 'cancelled';
    error?: string;
    progress?: number; // 0-100
    uploadedBytes?: number;
    totalBytes?: number;
    speedBytesPerSec?: number;
}
