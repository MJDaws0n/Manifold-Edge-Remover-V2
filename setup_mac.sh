#!/bin/bash

# STL Manifold Edge Fixer - Mac Setup Script
# This script sets up a Python virtual environment and installs all dependencies

set -e  # Exit on error

echo "================================================"
echo "STL Manifold Edge Fixer - Mac Setup"
echo "================================================"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed."
    echo "Please install Python 3 from https://www.python.org/downloads/"
    echo "Or use Homebrew: brew install python3"
    exit 1
fi

echo "✓ Python 3 found: $(python3 --version)"
echo ""

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    echo "✓ Virtual environment created"
else
    echo "✓ Virtual environment already exists"
fi

echo ""

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

echo "✓ Virtual environment activated"
echo ""

# Upgrade pip
echo "Upgrading pip..."
python -m pip install --upgrade pip

echo ""

# Install dependencies
echo "Installing dependencies..."
python -m pip install -r requirements.txt

echo ""
echo "================================================"
echo "✓ Setup complete!"
echo "================================================"
echo ""
echo "To run the application:"
echo "  1. Activate the virtual environment:"
echo "     source venv/bin/activate"
echo "  2. Run the application:"
echo "     python stl_fixer.py"
echo ""
echo "Or use the run script:"
echo "  ./run_mac.sh"
echo ""
