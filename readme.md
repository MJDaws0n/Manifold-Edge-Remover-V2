# Manifold Edge Remover

A native macOS (Apple Silicon) application that fixes non-manifold edges in binary STL files, making them watertight and ready for 3D printing. Written entirely in [Novus](https://github.com/MJDaws0n) with a WebKit-based GUI.

## Download from the releases tags
Download latest version from [here](https://github.com/MJDaws0n/Manifold-Edge-Remover-V2/releases).

Move to applications folder and run this to mark it as safe:
```sh
cd Applications
xattr -dr com.apple.quarantine ManifoldsEdgeRemover.app
```

## Features

- **Native ARM64 binary** — no Python, no runtime dependencies, just a single executable
- **GUI and CLI modes** — select files visually or process from the terminal
- **Standalone build** — the window manager and web UI are embedded into the binary; distribute a single file
- **Fixes non-manifold meshes** — removes duplicate faces, caps boundary loops, and produces watertight output
- **Safe** — saves fixed files with a `_FIXED` suffix, never modifies the original
- **Fast** — uses memory-mapped I/O and hash tables; processes 600K+ triangle models in seconds

## What It Fixes

| Issue | How it's fixed |
|-------|---------------|
| Non-manifold edges (shared by >2 faces) | Excess duplicate faces removed |
| Duplicate faces | Detected via vertex-index matching and removed |
| Boundary edges (holes) | Boundary loops traced and fan-triangulated (capped) |

The output is a watertight binary STL ready for slicers like Bambu Studio, PrusaSlicer, Cura, etc.

## Quick Start

### Prerequisites

- macOS on Apple Silicon (M1/M2/M3/M4)
- The [Novus compiler](https://github.com/MJDaws0n) (`./novus`) in the project root
- Xcode Command Line Tools (for `clang`): `xcode-select --install`

### Build

**Standalone binary** (single file, can be run from anywhere):

```bash
./build.sh
```

This produces two binaries in `build/darwin_arm64/`:
- `manifold_edge_remover` — dev binary (~170KB, needs the project directory)
- `manifold_edge_remover_standalone` — standalone binary (~260KB, fully self-contained)

**Dev build only** (if you just want to iterate on the Novus code):

```bash
./novus application/main.nov
```

If you've changed the window manager C code, recompile it first:

```bash
clang -O2 -Wall -Wextra -fobjc-arc -x objective-c \
    lib/mac_silicon_window_manager/unbuilt/app.c \
    -framework Cocoa -framework WebKit \
    -o lib/mac_silicon_window_manager/window_manager
```

### Run

**GUI mode** (opens a native macOS window):

```bash
./build/darwin_arm64/manifold_edge_remover
```

**CLI mode**:

```bash
./build/darwin_arm64/manifold_edge_remover --file path/to/model.stl
```

Output is saved as `model_FIXED.stl` alongside the original.

## How It Works

### Architecture

```
application/main.nov          Main app — STL processing + GUI event loop
application/web/               HTML/CSS/JS for the GUI (served over localhost)
lib/
  standard_lib.nov             String utilities (int_to_str, str_to_i32, etc.)
  standard_lib_macos_silicon.nov  ARM64 syscall wrappers (print, exit, fork, etc.)
  mac_silicon_window_manager.nov  Novus bindings for the window manager protocol
  mac_silicon_window_manager/
    unbuilt/app.c              Window manager source (Cocoa + WebKit + HTTP server)
    window_manager             Compiled window manager binary
  memory.nov                   Memory ops, C-string conversion, byte copying
  file_io.nov                  File I/O, mmap, pipes, path manipulation
  process.nov                  Subprocess execution, output capture, file picker
  maths.nov                    Math utilities (abs, min, max)
build.sh                       Builds standalone binary with embedded resources
```

### STL Processing Pipeline

1. **Memory-map** the input STL file
2. **Parse vertices** into a hash table to deduplicate (quantised to integer coords)
3. **Filter faces** — detect and remove exact duplicate triangles
4. **Edge analysis** — build an edge hash table, count how many faces share each edge
5. **Boundary capping** — trace boundary edge loops (edges with only 1 face) and fill them with fan triangulation
6. **Write output** — write a valid binary STL with the corrected face set

### Window Manager

The GUI uses a custom C-based window manager (`lib/mac_silicon_window_manager/unbuilt/app.c`) that:
- Creates a native `NSWindow` with a `WKWebView`
- Runs a built-in HTTP server to serve the web UI files
- Communicates with the Novus app over a UNIX domain socket (`/tmp/novus_wm.sock`)
- Supports a line-based protocol: `TITLE`, `SERVE`, `NAVIGATE`, `JSEVAL`, `SHOW`, `HIDE`, `QUIT`
- Bridges JavaScript ↔ Novus via `novusSend()` / `novusOnMessage()` and `JSMSG` socket messages

### Standalone Binary

The `build.sh` script creates a self-contained executable by appending resources to the binary:

```
[novus binary][window_manager][index.html][app.js][style.css][4×uint32 sizes][NVWM magic]
```

At runtime, the app checks for the `NVWM` magic at the end of its own executable. If found, it extracts the embedded files to `/tmp/novus_mer/` and uses those instead of the project directory.

## Project Structure for Development

```
.
├── application/
│   ├── main.nov               # Main application (1024 lines)
│   └── web/
│       ├── index.html          # GUI markup
│       ├── app.js              # GUI logic (novusSend/novusOnMessage bridge)
│       └── style.css           # macOS-style dark theme
├── lib/
│   ├── standard_lib.nov        # String utilities
│   ├── standard_lib_macos_silicon.nov  # Syscall wrappers
│   ├── mac_silicon_window_manager.nov  # WM protocol bindings
│   ├── mac_silicon_window_manager/
│   │   ├── unbuilt/app.c       # WM source (Obj-C, 783 lines)
│   │   └── window_manager      # Compiled WM binary
│   ├── memory.nov              # Memory/byte operations
│   ├── file_io.nov             # File I/O + path ops
│   ├── process.nov             # Subprocess + file picker
│   └── maths.nov               # Math helpers
├── build.sh                    # Standalone build script
├── novus                       # Novus compiler binary
└── readme.md
```

### Development Workflow

1. Edit `.nov` files or web files
2. Run `./novus application/main.nov` to compile (~0.5s)
3. Run `./build/darwin_arm64/manifold_edge_remover` to test
4. When ready to distribute, run `./build.sh` for the standalone binary

### Key Novus Patterns

- **Syscalls**: All OS interaction is via raw ARM64 syscalls (no libc). Example: `mov(x16, 0x2000005); syscall();` for `open()`
- **Strings as byte buffers**: Novus strings support `s[i]` byte indexing and are used as raw memory buffers for syscall structs
- **Hash tables**: Vertex and edge deduplication use open-addressing hash tables stored in `[]i32` arrays
- **Memory mapping**: STL files are `mmap`'d for zero-copy parsing via `file_mmap_read()`
- **No heap allocator**: All memory is managed through Novus arrays and string buffers

## License

Made by [MJDawson](https://mjdawson.net) — [github.com/mjdaws0n](https://github.com/mjdaws0n)
