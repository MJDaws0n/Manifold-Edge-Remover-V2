#!/bin/bash

# STL Manifold Edge Fixer - Mac Run Script
# This script runs the application in the virtual environment

set -e  # Exit on error

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if virtual environment exists
PYTHON_APP="$SCRIPT_DIR/app/bin/python"
PYTHON_VENV="$SCRIPT_DIR/venv/bin/python"

if [ -x "$PYTHON_APP" ]; then
    # Prefer the repo's embedded env if present
    "$PYTHON_APP" "$SCRIPT_DIR/stl_fixer.py"
    exit $?
fi

if [ ! -d "venv" ]; then
    echo "Virtual environment not found. Running setup..."
    ./setup_mac.sh
fi

"$PYTHON_VENV" "$SCRIPT_DIR/stl_fixer.py"
