@echo off
REM STL Manifold Edge Fixer - Windows Run Script
REM This script runs the application in the virtual environment

REM Get the directory where this script is located
cd /d "%~dp0"

REM Check if virtual environment exists
if not exist "venv\" (
    echo Virtual environment not found. Running setup...
    call setup_windows.bat
)

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Run the application
python stl_fixer.py

pause
