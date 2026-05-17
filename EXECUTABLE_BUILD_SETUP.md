# Telegram Drive - Executable Build Setup

## Executive Summary

This repository now includes comprehensive build tools and documentation to create executables for Windows, macOS, and Linux.

## What's New

### 📄 New Files Added

1. **BUILD_GUIDE.md** - Complete step-by-step build guide with troubleshooting
2. **BUILD_INSTRUCTIONS.md** - Quick reference for all platforms
3. **build.sh** - Automated build script for Linux/macOS
4. **build.bat** - Automated build script for Windows

### 🚀 Quick Start

#### For Windows Users
```bash
# Option 1: Use the automated script
build.bat

# Option 2: Manual build
cd app
npm install
npm run tauri build

# Your .exe will be at: app/src-tauri/target/release/Telegram Drive.exe
```

#### For Linux Users
```bash
# Option 1: Use the automated script
./build.sh

# Option 2: Manual build
cd app
npm install
npm run tauri build

# Your binary will be at: app/src-tauri/target/release/telegram_drive
```

#### For macOS Users
```bash
cd app
npm install
npm run tauri build

# Your app will be at: app/src-tauri/target/release/bundle/macos/Telegram Drive.app
```

## Build Process

### Prerequisites Installation

#### Windows
1. Install Visual Studio Build Tools with C++ support
2. Install Node.js v18+
3. Install Rust from rustup.rs
4. Verify: `node --version`, `cargo --version`
5. `build.bat` will try to load the toolchain automatically when it is installed

#### Linux (Ubuntu/Debian)
```bash
sudo apt update && sudo apt install -y libwebkit2gtk-4.1-dev build-essential curl wget file libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev
```

#### macOS
```bash
xcode-select --install
```

### Build Time

- **First build:** 5-15 minutes (compiles 300+ Rust crates)
- **Subsequent builds:** 1-3 minutes
- **Disk space needed:** 2-3 GB

## Output Locations

### Windows
```
app/src-tauri/target/release/
├── Telegram Drive.exe              (Direct executable)
└── bundle/msi/
    └── Telegram Drive_1.3.2_x64.msi (Windows installer)
```

### macOS
```
app/src-tauri/target/release/
├── bundle/macos/Telegram Drive.app  (Application bundle)
└── bundle/dmg/
    └── Telegram Drive_1.3.2_x64.dmg (DMG for distribution)
```

### Linux
```
app/src-tauri/target/release/
├── telegram_drive                   (Direct executable)
└── bundle/appimage/
    └── Telegram_Drive_1.3.2_x64.AppImage (AppImage for distribution)
```

## Automated Build Scripts

### build.sh (Linux/macOS)
- Checks all prerequisites
- Installs dependencies if needed
- Runs the build
- Shows output locations

### build.bat (Windows)
- Checks all prerequisites  
- Installs dependencies if needed
- Runs the build
- Shows output locations

## Documentation

- **BUILD_GUIDE.md** - Comprehensive guide with troubleshooting (7600+ lines)
- **BUILD_INSTRUCTIONS.md** - Quick reference guide
- **README.md** - Original project documentation

## Key Features

✅ Cross-platform builds (Windows, macOS, Linux)
✅ Automated build scripts with prerequisite checking
✅ Detailed troubleshooting guides
✅ Support for both portable executables and installers
✅ Clear output location information
✅ Time and disk space requirements documented

## System Requirements

### General
- Node.js v18+
- Rust 1.70+ (from rustup)
- 2-3 GB disk space
- 4 GB RAM minimum

### Platform-Specific
- **Windows:** Visual Studio Build Tools with C++ workload, WebView2
- **Linux:** libwebkit2gtk-4.1-dev and other build tools
- **macOS:** Xcode Command Line Tools

## Troubleshooting Quick Links

- "linker 'link.exe' not found" → See BUILD_GUIDE.md
- "libwebkit2gtk not found" → See BUILD_GUIDE.md
- "xcrun: error" → See BUILD_GUIDE.md
- Build hangs → Normal for first build! Wait 10-15 minutes

## Next Steps

1. Choose your platform (Windows/macOS/Linux)
2. Review the appropriate prerequisites section in BUILD_GUIDE.md
3. Run the automated script or manual commands
4. Wait for build to complete (5-15 minutes)
5. Find your executable in the output location
6. Run it and enjoy Telegram Drive!

## Additional Resources

- [Tauri Documentation](https://v2.tauri.app/)
- [Tauri Prerequisites](https://v2.tauri.app/start/prerequisites/)
- [Project Repository](https://github.com/tanvirbinzahid/Telegram-Drive-Enhanched)

---

**Status:** ✅ Ready to build!

For detailed build instructions, see BUILD_GUIDE.md
