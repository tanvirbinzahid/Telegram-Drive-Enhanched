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

REM Check or initialize Visual Studio Build Tools
call :setup_msvc_environment
if !errorlevel! neq 0 (
    echo %error% Visual Studio Build Tools with C++ support are required.
    echo Please install them from https://visualstudio.microsoft.com/visual-cpp-build-tools/
    echo or run this script from "Developer Command Prompt for Visual Studio".
    pause
    exit /b 1
)
echo %success% Visual Studio C++ toolchain ready.

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
goto :eof

:setup_msvc_environment
where cl.exe >nul 2>nul
if not errorlevel 1 (
    where link.exe >nul 2>nul
    if not errorlevel 1 exit /b 0
)

call :load_vsdevcmd
if errorlevel 1 exit /b 1

where cl.exe >nul 2>nul
if errorlevel 1 exit /b 1

where link.exe >nul 2>nul
if errorlevel 1 exit /b 1

exit /b 0

:load_vsdevcmd
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set "VSINSTALL="

if not exist "%VSWHERE%" exit /b 1

for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSINSTALL=%%i"

if not defined VSINSTALL exit /b 1

if exist "%VSINSTALL%\Common7\Tools\VsDevCmd.bat" (
    call "%VSINSTALL%\Common7\Tools\VsDevCmd.bat" -arch=x64 -host_arch=x64 >nul
    if errorlevel 1 exit /b 1
    exit /b 0
)

if exist "%VSINSTALL%\VC\Auxiliary\Build\vcvars64.bat" (
    call "%VSINSTALL%\VC\Auxiliary\Build\vcvars64.bat" >nul
    if errorlevel 1 exit /b 1
    exit /b 0
)

exit /b 1
