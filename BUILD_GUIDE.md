# Building Telegram Drive Executable - Quick Start Guide

## TL;DR - Quick Build Commands

### Windows
```bash
# From repository root
cd app
npm install
npm run tauri build

# Your .exe will be at: app/src-tauri/target/release/Telegram Drive.exe
```

Or simply double-click: `build.bat`

### Linux
```bash
# Install system dependencies first (Ubuntu/Debian):
sudo apt install libwebkit2gtk-4.1-dev build-essential curl wget file libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev

# Then build:
./build.sh
```

Or run from root:
```bash
./build.sh
```

### macOS
```bash
# From repository root
cd app
npm install
npm run tauri build

# Your app will be at: app/src-tauri/target/release/bundle/macos/Telegram Drive.app
```

---

## Complete Setup Guide

### Prerequisites by Platform

#### Windows 10/11
- [ ] **Visual Studio Build Tools** with C++ support ([download](https://visualstudio.microsoft.com/visual-cpp-build-tools/))
  - During installation, check: "Desktop development with C++"
  - Alternatively: Full Visual Studio with C++ workload
- [ ] **Node.js** v18+ ([download](https://nodejs.org/))
  - Verify: `node --version`
- [ ] **Rust** via rustup ([download](https://rustup.rs/))
  - Verify: `rustc --version` and `cargo --version`
- [ ] **WebView2 Runtime** (usually pre-installed on Windows 10/11)
  - If not: [Download WebView2 Runtime](https://developer.microsoft.com/en-us/microsoft-edge/webview2/#download-section)

#### Ubuntu/Debian
```bash
# All prerequisites in one command:
sudo apt update && \
sudo apt install -y \
    libwebkit2gtk-4.1-dev \
    build-essential \
    curl \
    wget \
    file \
    libxdo-dev \
    libssl-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev

# Also install Node.js and Rust:
# Node: https://nodejs.org/
# Rust: https://rustup.rs/
```

#### Fedora/RedHat
```bash
sudo dnf install -y \
    webkit2-devel \
    gcc \
    gcc-c++ \
    make \
    openssl-devel \
    curl \
    wget \
    file \
    libxdo-devel \
    libappindicator-devel \
    librsvg2-devel
```

#### macOS
```bash
# Install Xcode Command Line Tools:
xcode-select --install

# Or if already installed, update:
xcode-select --install

# Install Node.js and Rust:
# Node: https://nodejs.org/
# Rust: https://rustup.rs/
```

---

## Build Steps

### Step 1: Clone Repository (if not already done)
```bash
git clone https://github.com/tanvirbinzahid/Telegram-Drive-Enhanched.git
cd Telegram-Drive-Enhanched
```

### Step 2: Navigate to App Directory
```bash
cd app
```

### Step 3: Install Dependencies
```bash
npm install
```
This installs Node.js dependencies. Takes 1-2 minutes.

### Step 4: Build the Application
```bash
npm run tauri build
```

⏱️ **Time estimate:**
- First build: 5-15 minutes (compiles 300+ Rust crates)
- Subsequent builds: 1-3 minutes

---

## Build Output Locations

### Windows
```
app/src-tauri/target/release/
├── Telegram Drive.exe              ← Run this directly
└── bundle/msi/
    └── Telegram Drive_1.3.2_x64.msi ← Or install from this
```

### macOS
```
app/src-tauri/target/release/
├── bundle/macos/Telegram Drive.app
│   └── Contents/MacOS/Telegram Drive  ← Executable inside
└── bundle/dmg/Telegram Drive_1.3.2_x64.dmg  ← For distribution
```

### Linux
```
app/src-tauri/target/release/
├── telegram_drive                   ← Run this directly
└── bundle/appimage/
    └── Telegram_Drive_1.3.2_x64.AppImage ← Or use this for distribution
```

---

## Automated Build Scripts

### Using build.sh (Linux/macOS)
```bash
# From repository root:
./build.sh

# Or with bash explicitly:
bash build.sh
```

The script will:
- ✓ Check all prerequisites
- ✓ Install npm dependencies if needed
- ✓ Run the build
- ✓ Show output location when done

### Using build.bat (Windows)
```bash
# Simply double-click: build.bat
# Or run from command prompt:
build.bat
```

The script will:
- ✓ Check all prerequisites
- ✓ Install npm dependencies if needed
- ✓ Run the build
- ✓ Show output location when done

---

## Troubleshooting

### "linker 'link.exe' not found" (Windows)
**Solution:**
1. Install Visual Studio Build Tools
2. Select "Desktop development with C++" during installation
3. Restart terminal/IDE
4. Try `build.bat` again so it can auto-load the toolchain if installed
5. If needed, open "Developer Command Prompt for Visual Studio" and run the build there

### "command not found: cargo" (Any platform)
**Solution:**
- Ensure Rust is installed: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- Restart terminal
- Run: `cargo --version` to verify

### "libwebkit2gtk-4.1-dev not found" (Linux)
**Solution:**
```bash
sudo apt update
sudo apt install libwebkit2gtk-4.1-dev build-essential curl wget file libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev
```

### "xcrun: error" (macOS)
**Solution:**
```bash
xcode-select --install
# Or reset:
xcode-select --reset
```

### Build hangs or seems stuck
**Reason:** This is normal! First build compiles 300+ Rust crates and can take 10-15 minutes.

**Solution:** Wait patiently or check system resources. You should see progress messages in the terminal.

### "npm: command not found"
**Solution:** Install Node.js from https://nodejs.org/ (v18 or later)

---

## Development vs Release Build

### Development Build (Live Reload)
```bash
# From app directory:
npm run tauri dev
```
- Hot reload enabled
- Larger file size
- Slower performance
- Good for development

### Release Build (Optimized)
```bash
# From app directory:
npm run tauri build
```
- Optimized performance
- Smaller file size
- Ready for distribution
- What you want for an executable

---

## Additional Commands

```bash
# Start dev server only (frontend)
npm run dev

# Build frontend only
npm run build

# Preview built frontend
npm run preview

# Run Tauri CLI commands
npm run tauri -- [command]

# Get help
npm run tauri -- --help
```

---

## System Resources Needed

- **Disk Space:** 2-3 GB for dependencies and build artifacts
- **RAM:** 4 GB minimum recommended
- **Network:** Fast internet for initial dependency download (300+ crates)
- **Time:** 5-15 minutes for first build

---

## After Build - Using Your Executable

### Windows
- Double-click `Telegram Drive.exe` to run
- Or install from `Telegram Drive_1.3.2_x64.msi` for system integration

### macOS
- Drag `Telegram Drive.app` to Applications folder
- Or double-click the DMG file to mount and install

### Linux
- Run: `./telegram_drive` from terminal
- Or double-click the AppImage file
- Or install system package from generated bundle

---

## Getting Help

- 📖 [Tauri Documentation](https://v2.tauri.app/)
- 🔧 [Tauri Prerequisites Guide](https://v2.tauri.app/start/prerequisites/)
- 🏗️ [Tauri Build Guide](https://v2.tauri.app/build/)
- 💬 [GitHub Issues](https://github.com/tanvirbinzahid/Telegram-Drive-Enhanched/issues)
- 📝 [Original README](README.md)

---

## Important Notes

1. **API Credentials Required**
   - You need your own Telegram API ID and API Hash
   - Get them at: https://my.telegram.org/apps
   - Enter these when you first run the app

2. **Privacy & Security**
   - Credentials are stored locally only
   - No external servers are used
   - Your data stays on your computer and Telegram's servers

3. **First Run**
   - Initial build compiles 300+ Rust dependencies
   - This is normal and takes 5-15 minutes
   - Subsequent builds are much faster (1-3 minutes)

4. **Platform-Specific Notes**
   - Windows: Requires Visual Studio Build Tools C++ workload
   - macOS: Intel and Apple Silicon (M1/M2/etc) both supported
   - Linux: Many distributions supported, see prerequisites

---

**Happy building! 🚀**

Need help? Check the troubleshooting section or open an issue on GitHub.
