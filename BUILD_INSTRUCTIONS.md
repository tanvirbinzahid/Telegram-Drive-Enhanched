# Building Telegram Drive Executable

This guide explains how to build the Telegram Drive application for different platforms.

## Quick Start

### For Windows (.exe) - Build on Windows Machine

```bash
# 1. Prerequisites (one-time setup)
# - Install Visual Studio Build Tools (C++ Desktop Development)
# - Install Node.js v18+
# - Install Rust via rustup.rs
# - Verify WebView2 is installed (usually pre-installed on Windows 10/11)

# 2. Clone and setup
git clone https://github.com/tanvirbinzahid/Telegram-Drive-Enhanched.git
cd Telegram-Drive-Enhanched/app

# 3. Install dependencies
npm install

# 4. Build the application
npm run tauri build

# Output will be in:
# - app/src-tauri/target/release/Telegram Drive.exe (Portable)
# - app/src-tauri/target/release/bundle/msi/ (Installer)
```

### For Linux - Build on Linux Machine

```bash
# 1. Install dependencies (Ubuntu/Debian example)
sudo apt update
sudo apt install libwebkit2gtk-4.1-dev build-essential curl wget file libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev

# 2. Ensure Node.js and Rust are installed
node --version  # Should be v18+
cargo --version # Should be recent

# 3. Clone and setup
git clone https://github.com/tanvirbinzahid/Telegram-Drive-Enhanched.git
cd Telegram-Drive-Enhanched/app

# 4. Install Node dependencies
npm install

# 5. Build
npm run tauri build

# Output will be in:
# - app/src-tauri/target/release/telegram_drive (Binary)
# - app/src-tauri/target/release/bundle/appimage/ (AppImage)
```

### For macOS - Build on Mac

```bash
# 1. Install Xcode Command Line Tools (one-time)
xcode-select --install

# 2. Ensure Node.js and Rust are installed
node --version  # Should be v18+
cargo --version # Should be recent

# 3. Clone and setup
git clone https://github.com/tanvirbinzahid/Telegram-Drive-Enhanched.git
cd Telegram-Drive-Enhanched/app

# 4. Install Node dependencies
npm install

# 5. Build
npm run tauri build

# Output will be in:
# - app/src-tauri/target/release/bundle/macos/Telegram Drive.app
# - app/src-tauri/target/release/bundle/dmg/Telegram Drive.dmg
```

## System Requirements by Platform

### Windows
- OS: Windows 10 or later
- Node.js: v18 or later
- Rust: 1.70 or later (via rustup)
- Visual Studio Build Tools with C++ workload
- WebView2 Runtime (usually pre-installed)
- Disk space: ~2-3GB for build artifacts
- Time: 5-15 minutes (first build), 1-3 minutes (subsequent)

### Linux
- OS: Ubuntu 20.04+, Debian 11+, Fedora 34+, or similar
- Node.js: v18 or later
- Rust: 1.70 or later (via rustup)
- Development tools: libwebkit2gtk-4.1-dev, build-essential, etc.
- Disk space: ~2-3GB for build artifacts
- Time: 5-15 minutes (first build), 1-3 minutes (subsequent)

### macOS
- OS: macOS 10.13 (High Sierra) or later
- Node.js: v18 or later
- Rust: 1.70 or later (via rustup)
- Xcode Command Line Tools
- Architecture: Intel (x86_64) or Apple Silicon (aarch64)
- Disk space: ~2-3GB for build artifacts
- Time: 5-15 minutes (first build), 1-3 minutes (subsequent)

## Build Artifacts

After running `npm run tauri build`, you'll find outputs in:

```
app/src-tauri/target/release/
├── Telegram Drive.exe              # Windows executable
├── Telegram Drive_1.3.2_x64.msi   # Windows installer
├── telegram_drive                   # Linux binary
├── bundle/
│   ├── appimage/                   # Linux AppImage
│   ├── msi/                        # Windows MSI installer
│   ├── macos/                      # macOS app bundle
│   └── dmg/                        # macOS DMG image
```

## Troubleshooting

### Windows: "linker 'link.exe' not found"
- Install Visual Studio Build Tools with C++ Desktop Development workload
- Make sure you selected the correct workload during installation
- Run `build.bat` again after installing; it now tries to load the Visual Studio toolchain automatically

### Linux: "libwebkit2gtk-4.1-dev not found"
- Run: `sudo apt install libwebkit2gtk-4.1-dev build-essential curl wget file libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev`

### macOS: "xcrun: error"
- Run: `xcode-select --install`
- Or: `xcode-select --reset`

### Any platform: "npm install fails"
- Delete `package-lock.json` and `node_modules/`
- Run: `npm cache clean --force`
- Run: `npm install` again

### Slow first build
- This is normal! The build compiles 300+ Rust crates
- Subsequent builds are much faster (only rebuilds changed files)
- First build: 5-15 minutes
- Subsequent builds: 1-3 minutes

## Development Commands

```bash
# Development server (live reload)
npm run tauri dev

# Build frontend only (no app bundle)
npm run build

# Preview built frontend
npm run preview

# Tauri CLI help
npm run tauri -- --help
```

## Additional Resources

- [Tauri Documentation](https://v2.tauri.app/)
- [Tauri Prerequisites Guide](https://v2.tauri.app/start/prerequisites/)
- [Tauri Build Guide](https://v2.tauri.app/build/)
- [Repository](https://github.com/tanvirbinzahid/Telegram-Drive-Enhanched)

## Notes

- First build takes longer due to Rust crate compilation
- You need your own Telegram API credentials (api_id and api_hash) to use the app
- The built executable will not include your Telegram credentials for security
- All data stays local - no external servers are used
