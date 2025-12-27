@echo off
REM STL Manifold Edge Fixer - Windows Run Script
REM This script runs the application in the virtual environment

REM Get the directory where this script is located
cd /d "%~dp0"

REM Check if virtual environment exists
set "PYTHON_APP=%~dp0app\Scripts\python.exe"
if exist "%PYTHON_APP%" (
    "%PYTHON_APP%" "%~dp0stl_fixer.py"
    pause
    exit /b %errorlevel%
)

REM Fall back to venv/ (created by setup script)
if not exist "venv\" (
    echo Virtual environment not found. Running setup...
    call setup_windows.bat
)

"%~dp0venv\Scripts\python.exe" "%~dp0stl_fixer.py"

pause
