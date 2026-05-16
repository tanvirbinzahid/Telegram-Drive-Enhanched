@echo off
REM Build script for Telegram Drive (Windows)
REM This script automates the build process for the Telegram Drive application

setlocal enabledelayedexpansion

REM Color codes (using Windows 10+ features)
set "success=[OK]"
set "error=[ERROR]"
set "warning=[WARNING]"

REM Print colored output
echo.
echo ========================================
echo  Telegram Drive - Build Script (Windows)
echo ========================================
echo.

REM Check prerequisites
echo Checking Prerequisites...

REM Check Node.js
where node >nul 2>nul
if !errorlevel! neq 0 (
    echo %error% Node.js is not installed.
    echo Please install Node.js v18 or later from https://nodejs.org/
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('node -v') do set NODE_VERSION=%%i
echo %success% Node.js: %NODE_VERSION%

REM Check npm
where npm >nul 2>nul
if !errorlevel! neq 0 (
    echo %error% npm is not installed.
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('npm -v') do set NPM_VERSION=%%i
echo %success% npm: %NPM_VERSION%

REM Check Rust
where cargo >nul 2>nul
if !errorlevel! neq 0 (
    echo %error% Rust/Cargo is not installed.
    echo Please install from https://rustup.rs/
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('rustc --version') do set RUST_VERSION=%%i
echo %success% Rust: %RUST_VERSION%

REM Check Visual Studio Build Tools
where cl.exe >nul 2>nul
if !errorlevel! neq 0 (
    echo %warning% Visual Studio Build Tools C++ compiler not found in PATH.
    echo Please ensure Visual Studio Build Tools are installed with C++ support.
    echo You may need to run this from "Developer Command Prompt for Visual Studio"
    pause
)

REM Change to app directory
cd /d "%~dp0app"
if !errorlevel! neq 0 (
    echo %error% Failed to change to app directory
    pause
    exit /b 1
)

echo.
echo Installing Dependencies...
if not exist "node_modules" (
    echo %success% Running 'npm install'...
    call npm install
    if !errorlevel! neq 0 (
        echo %error% npm install failed
        pause
        exit /b 1
    )
) else (
    echo %success% Node modules already installed, skipping npm install
)

echo.
echo ========================================
echo  Building Application
echo ========================================
echo %warning% This may take 5-15 minutes on first build...
echo %warning% (Compiling 300+ Rust crates)
echo.

call npm run tauri build
if !errorlevel! neq 0 (
    echo %error% Build failed
    pause
    exit /b 1
)

echo.
echo ========================================
echo  Build Complete!
echo ========================================
echo.
echo %success% Windows Executable: %~dp0app\src-tauri\target\release\Telegram Drive.exe
if exist "src-tauri\target\release\bundle\msi\*.msi" (
    echo %success% Windows Installer: %~dp0app\src-tauri\target\release\bundle\msi\
)
echo.
echo %success% Build successful! Your executable is ready to use.
echo.
pause
