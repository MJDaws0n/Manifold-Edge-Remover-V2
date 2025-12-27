# Example STL Files

This directory contains example STL files for testing the STL Manifold Edge Fixer.

## Creating Test Files

You can create your own test files or use files from:
- Thingiverse (https://www.thingiverse.com/)
- Printables (https://www.printables.com/)
- Your own 3D modeling software

## Testing the Application

1. Run the application using the appropriate script for your OS
2. Select an STL file from this directory (or any other location)
3. The fixed file will be saved with `_FIXED` appended to the filename

## Expected Results

The application will:
- Remove duplicate vertices
- Remove degenerate faces (zero-area faces)
- Remove duplicate faces
- Fill small holes (when possible)
- Fix face normals
- Make the mesh more suitable for 3D printing

Files that are already properly manifold will be processed but may not change significantly.
