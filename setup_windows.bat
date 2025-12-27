@echo off
REM STL Manifold Edge Fixer - Windows Setup Script
REM This script sets up a Python virtual environment and installs all dependencies

echo ================================================
echo STL Manifold Edge Fixer - Windows Setup
echo ================================================
echo.

REM Get the directory where this script is located
cd /d "%~dp0"

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed.
    echo Please install Python 3 from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation.
    pause
    exit /b 1
)

echo [32m✓ Python found[0m
python --version
echo.

REM Create virtual environment if it doesn't exist
if not exist "venv\" (
    echo Creating virtual environment...
    python -m venv venv
    echo [32m✓ Virtual environment created[0m
) else (
    echo [32m✓ Virtual environment already exists[0m
)

echo.

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

echo [32m✓ Virtual environment activated[0m
echo.

REM Upgrade pip
echo Upgrading pip...
python -m pip install --upgrade pip

echo.

REM Install dependencies
echo Installing dependencies...
pip install -r requirements.txt

echo.
echo ================================================
echo [32m✓ Setup complete![0m
echo ================================================
echo.
echo To run the application:
echo   1. Activate the virtual environment:
echo      venv\Scripts\activate.bat
echo   2. Run the application:
echo      python stl_fixer.py
echo.
echo Or use the run script:
echo   run_windows.bat
echo.
pause
