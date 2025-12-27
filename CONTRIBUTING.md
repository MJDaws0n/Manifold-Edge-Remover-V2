# Contributing to STL Manifold Edge Fixer

Thank you for your interest in contributing to the STL Manifold Edge Fixer!

## Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Manifold-Edge-Remover.git
   cd Manifold-Edge-Remover
   ```

3. Set up the development environment:
   - **macOS**: `./setup_mac.sh`
   - **Windows**: `setup_windows.bat`
   - **Linux**: `./setup_linux.sh`

4. Activate the virtual environment:
   - **macOS/Linux**: `source venv/bin/activate`
   - **Windows**: `venv\Scripts\activate.bat`

## Testing Your Changes

1. Test the application:
   ```bash
   python stl_fixer.py
   ```

2. Test with various STL files to ensure robustness

3. Check for syntax errors:
   ```bash
   python -m py_compile stl_fixer.py
   ```

## Code Style

- Follow PEP 8 Python style guidelines
- Use meaningful variable and function names
- Add docstrings to functions and classes
- Keep functions focused and modular

## Submitting Changes

1. Create a new branch for your feature or fix:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and test thoroughly

3. Commit your changes with a clear message:
   ```bash
   git commit -m "Add feature: description of your changes"
   ```

4. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

5. Create a Pull Request on GitHub

## Reporting Issues

When reporting issues, please include:
- Your operating system (macOS, Windows, Linux)
- Python version (`python --version`)
- Steps to reproduce the issue
- Error messages (if any)
- Example STL file (if relevant)

## Areas for Contribution

- Support for additional mesh formats (OBJ, PLY, etc.)
- Advanced mesh repair algorithms
- Better error handling and user feedback
- Performance optimizations
- Improved UI/UX
- Documentation improvements
- Unit tests

## Questions?

Feel free to open an issue for any questions or discussions about contributing.
