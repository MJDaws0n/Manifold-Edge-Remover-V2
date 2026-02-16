#!/bin/bash
set -e

echo "=== Building Manifold Edge Remover (Standalone) ==="
echo ""

# Paths
BINARY=build/darwin_arm64/manifold_edge_remover
WM=lib/mac_silicon_window_manager/window_manager
HTML=application/web/index.html
JS=application/web/app.js
CSS=application/web/style.css
STANDALONE="${BINARY}_standalone"

# Step 1: Compile the window manager (C)
echo "[1/4] Compiling window manager..."
clang -O2 -Wall -Wextra -fobjc-arc -x objective-c \
    lib/mac_silicon_window_manager/unbuilt/app.c \
    -framework Cocoa -framework WebKit \
    -o "$WM"

# Step 2: Compile the Novus application
echo "[2/4] Compiling Novus application..."
./novus application/main.nov

# Step 3: Get file sizes
WM_SIZE=$(stat -f%z "$WM")
HTML_SIZE=$(stat -f%z "$HTML")
JS_SIZE=$(stat -f%z "$JS")
CSS_SIZE=$(stat -f%z "$CSS")

echo "[3/4] Embedding resources..."
echo "  window_manager: $WM_SIZE bytes"
echo "  index.html:     $HTML_SIZE bytes"
echo "  app.js:         $JS_SIZE bytes"
echo "  style.css:      $CSS_SIZE bytes"

# Step 4: Create standalone binary
cp "$BINARY" "$STANDALONE"

# Append embedded files in order
cat "$WM" >> "$STANDALONE"
cat "$HTML" >> "$STANDALONE"
cat "$JS" >> "$STANDALONE"
cat "$CSS" >> "$STANDALONE"

# Append footer: 4 × uint32 LE sizes + "NVWM" magic (20 bytes)
python3 -c "
import struct, sys
sys.stdout.buffer.write(struct.pack('<IIII', $WM_SIZE, $HTML_SIZE, $JS_SIZE, $CSS_SIZE))
sys.stdout.buffer.write(b'NVWM')
" >> "$STANDALONE"

chmod +x "$STANDALONE"

ORIG_SIZE=$(stat -f%z "$BINARY")
FINAL_SIZE=$(stat -f%z "$STANDALONE")

echo "[4/4] Done!"
echo ""
echo "  Dev binary:        $BINARY ($ORIG_SIZE bytes)"
echo "  Standalone binary: $STANDALONE ($FINAL_SIZE bytes)"
echo ""
echo "The standalone binary can be run from anywhere without needing"
echo "the project directory, window_manager, or web files."
