#!/bin/bash
# Build script for Telegram Drive
# This script automates the build process for the Telegram Drive application

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_section() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_section "Checking Prerequisites"
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js v18 or later."
        exit 1
    fi
    NODE_VERSION=$(node -v)
    print_status "Node.js: $NODE_VERSION"
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed."
        exit 1
    fi
    NPM_VERSION=$(npm -v)
    print_status "npm: $NPM_VERSION"
    
    # Check Rust
    if ! command -v cargo &> /dev/null; then
        print_error "Rust/Cargo is not installed. Please install from https://rustup.rs/"
        exit 1
    fi
    RUST_VERSION=$(rustc --version)
    print_status "Rust: $RUST_VERSION"
    
    # Platform-specific checks
    OS=$(uname -s)
    case "$OS" in
        Linux*)
            print_status "Platform: Linux"
            if ! pkg-config --exists gtk+-3.0 webkit2gtk-4.1 2>/dev/null; then
                print_warning "Some Linux dependencies may be missing."
                print_warning "Run: sudo apt install libwebkit2gtk-4.1-dev build-essential curl wget file libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev"
            fi
            ;;
        Darwin*)
            print_status "Platform: macOS"
            if ! xcode-select -p &> /dev/null; then
                print_error "Xcode Command Line Tools not found."
                print_error "Run: xcode-select --install"
                exit 1
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            print_status "Platform: Windows"
            print_warning "For Windows builds, ensure Visual Studio Build Tools are installed."
            ;;
        *)
            print_warning "Unknown platform: $OS"
            ;;
    esac
}

# Install dependencies
install_dependencies() {
    print_section "Installing Dependencies"
    
    cd "$SCRIPT_DIR/app"
    
    if [ ! -d "node_modules" ]; then
        print_status "Running 'npm install'..."
        npm install
    else
        print_status "Node modules already installed, skipping npm install."
    fi
}

# Build the application
build_app() {
    print_section "Building Application"
    
    cd "$SCRIPT_DIR/app"
    
    print_status "Running 'npm run tauri build'..."
    print_warning "This may take 5-15 minutes on first build (compiling 300+ Rust crates)..."
    
    npm run tauri build
}

# Show build output location
show_results() {
    print_section "Build Complete!"
    
    cd "$SCRIPT_DIR/app"
    
    OS=$(uname -s)
    case "$OS" in
        Linux*)
            print_status "Executable: $SCRIPT_DIR/app/src-tauri/target/release/telegram_drive"
            if [ -f "src-tauri/target/release/bundle/appimage/"*.AppImage ]; then
                print_status "AppImage: $(ls -1 src-tauri/target/release/bundle/appimage/*.AppImage 2>/dev/null | head -1)"
            fi
            ;;
        Darwin*)
            print_status "macOS App: $SCRIPT_DIR/app/src-tauri/target/release/bundle/macos/Telegram Drive.app"
            if [ -f "src-tauri/target/release/bundle/dmg/"*.dmg ]; then
                print_status "DMG: $(ls -1 src-tauri/target/release/bundle/dmg/*.dmg 2>/dev/null | head -1)"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            print_status "Windows Executable: $SCRIPT_DIR/app/src-tauri/target/release/Telegram Drive.exe"
            if [ -f "src-tauri/target/release/bundle/msi/"*.msi ]; then
                print_status "Windows Installer: $(ls -1 src-tauri/target/release/bundle/msi/*.msi 2>/dev/null | head -1)"
            fi
            ;;
    esac
    
    echo ""
    print_status "✨ Build successful! Your executable is ready to use."
}

# Main script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_section "Telegram Drive - Build Script"
echo ""
echo "This script will build the Telegram Drive application."
echo "Location: $SCRIPT_DIR"
echo ""

# Run build steps
check_prerequisites
install_dependencies
build_app
show_results

echo ""
print_status "Done! Enjoy Telegram Drive! 🚀"
