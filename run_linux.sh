#!/bin/bash

# STL Manifold Edge Fixer - Linux Run Script
# This script runs the application in the virtual environment

set -e  # Exit on error

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Virtual environment not found. Running setup..."
    ./setup_linux.sh
fi

# Activate virtual environment
source venv/bin/activate

# Run the application
python stl_fixer.py
