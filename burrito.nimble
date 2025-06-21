# Package

version       = "0.2.0"
author        = "Jason R. Huggins"
description   = "Burrito: Nim wrapper for QuickJS"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 2.2.4"

# Tasks

task example, "Run the basic example":
  exec "nim c -r --hints:off examples/basic_example.nim"
  echo ""

task examples, "Run all examples":
  exec "nim c -r --hints:off examples/basic_example.nim"
  exec "nim c -r --hints:off examples/call_nim_from_js.nim"
  exec "nim c -r --hints:off examples/advanced_native_bridging.nim"
  exec "nim c -r --hints:off examples/comprehensive_features.nim"
  exec "nim c -r --hints:off examples/idiomatic_patterns.nim"
  exec "nim c -r --hints:off examples/type_system.nim"
  echo ""

task get_quickjs, "Download and extract latest QuickJS source":
  if dirExists("quickjs"):
    echo "⚠️  QuickJS directory already exists. To re-download, first remove it:"
    echo "   nimble delete_quickjs"
    echo "   (or manually: rm -rf ./quickjs)"
    quit(1)
  echo "📥 Downloading QuickJS source..."
  exec "curl -L https://bellard.org/quickjs/quickjs-2025-04-26.tar.xz | tar -xJ"
  exec "mv quickjs-2025-04-26 quickjs"
  echo "✅ QuickJS source downloaded and extracted to quickjs/"

task build_quickjs, "Build the QuickJS library":
  if not dirExists("quickjs"):
    echo "❌ QuickJS source not found. Run 'nimble get_quickjs' first."
    quit(1)
  echo "🔨 Building QuickJS library..."
  exec "cd quickjs && make"
  echo "✅ QuickJS library built successfully"

task delete_quickjs, "Remove QuickJS source directory":
  if dirExists("quickjs"):
    echo "🗑️  Removing QuickJS source directory..."
    rmDir("quickjs")
    echo "✅ QuickJS directory removed"
  else:
    echo "ℹ️  No QuickJS directory found"

task clean_nim, "Clean compiled Nim binaries":
  echo "🧹 Cleaning compiled Nim binaries..."
  exec "rm -f src/burrito examples/basic_example examples/call_nim_from_js examples/advanced_native_bridging examples/comprehensive_features examples/idiomatic_patterns examples/type_system"
  echo "✅ Nim binaries cleaned"

task clean_all, "Clean build artifacts":
  echo "🧹 Cleaning build artifacts..."
  if dirExists("quickjs"):
    echo "🧹 Cleaning QuickJS build artifacts..."
    exec "cd quickjs && make clean"
  echo "🧹 Removing compiled Nim binaries..."
  exec "rm -f src/burrito examples/basic_example examples/call_nim_from_js examples/advanced_native_bridging examples/comprehensive_features examples/idiomatic_patterns examples/type_system"
  echo "✅ Clean completed"

task test, "Run tests and examples":
  exec "nimble examples"
