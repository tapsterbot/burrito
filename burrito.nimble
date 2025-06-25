# Burrito - Nim Package

version       = "0.3.0"
author        = "Jason R. Huggins"
description   = "Burrito: Nim wrapper for QuickJS and MicroPython"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 2.2.4"

# Tasks

task example_js, "Run the QuickJS basic example":
  exec "nim c -r --hints:off examples/qjs/basic_example.nim"
  echo ""

task ejs, "Alias for QuickJS example":
  exec "nimble example_js"

task example, "Alias for QuickJS example":
  exec "nimble example_js"

task e, "Alias for QuickJS example":
  exec "nimble example_js"

task examples_js, "Run all QuickJS examples":
  exec "nim c -r --hints:off examples/qjs/basic_example.nim"
  exec "nim c -r --hints:off examples/qjs/call_nim_from_js.nim"
  exec "nim c -r --hints:off examples/qjs/advanced_native_bridging.nim"
  exec "nim c -r --hints:off examples/qjs/comprehensive_features.nim"
  exec "nim c -r --hints:off examples/qjs/idiomatic_patterns.nim"
  exec "nim c -r --hints:off examples/qjs/type_system.nim"
  exec "nim c -r --hints:off examples/qjs/module_example.nim"
  exec "nim c -r --hints:off examples/qjs/bytecode_basic.nim"
  exec "nim c -r --hints:off examples/qjs/bytecode_comprehensive.nim"
  echo ""

task esjs, "Alias for run all QuickJS examples":
  exec "nimble examples_js"

task examples, "Alias for run all QuickJS example":
  exec "nimble examples_js"

task es, "Alias for run all QuickJS example":
  exec "nimble examples_js"


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

task cn, "Alias for clean_nim":
  exec "nimble clean_nim"

task clean_nim, "Clean compiled Nim binaries":
  echo "🧹 Cleaning compiled Nim binaries..."
  if dirExists("build"):
    rmDir("build")
  echo "✅ Nim binaries cleaned"

task clean_all, "Clean build artifacts":
  echo "🧹 Cleaning build artifacts..."
  if dirExists("quickjs"):
    echo "🧹 Cleaning QuickJS build artifacts..."
    exec "cd quickjs && make clean"
  echo "🧹 Removing compiled Nim binaries..."
  if dirExists("build"):
    rmDir("build")
  echo "✅ Clean completed"

task test_report, "Run all tests and print a summary":
  exec "mkdir -p build/logs"
  exec "rm -f ./build/logs/nimtest.log"
  if not fileExists("build/qjs/src/repl_bytecode.nim"):
    exec "nimble compile_repl_bytecode"
  exec """
    nim c -r --hints:off tests/qjs/test_basic.nim 2>&1 | tee -a build/logs/nimtest.log
    nim c -r --hints:off tests/qjs/test_repl.nim 2>&1 | tee -a build/logs/nimtest.log
    nim c -r --hints:off tests/mpy/test_repl.nim 2>&1 | tee -a build/logs/nimtest.log
    echo '====================='
    echo 'Test summary:'
    total=$(grep -E '\[(OK|FAILED)\]' build/logs/nimtest.log | wc -l)
    passed=$(grep '\[OK\]' build/logs/nimtest.log | wc -l)
    failed=$(grep '\[FAILED\]' build/logs/nimtest.log | wc -l)
    echo "Total tests: $total"
    echo "Passed:      $passed"
    echo "Failed:      $failed"
    echo ""
    echo ""
    #if [ "$failed" -gt 0 ]; then exit 1; fi
  """

task tr, "Alias for test_report":
  exec "nimble test_report"

task repl_js, "Run QuickJS repl":
  exec "nim c -r --hints:off examples/qjs/repl_with_nim_functions.nim"
  echo ""

task rjs, "Alias for QuickJS repl":
  exec "nimble repl --silent"

task compile_repl_bytecode, "Compile repl.js to bytecode":
  if not fileExists("quickjs/qjsc"):
    echo "❌ qjsc compiler not found. Run 'nimble build_quickjs' first."
    quit(1)
  if not fileExists("quickjs/repl.js"):
    echo "❌ repl.js not found in quickjs directory."
    quit(1)
  echo "🔨 Compiling repl.js to bytecode..."
  exec "cd quickjs && ./qjsc -c -o repl_bytecode.c -m repl.js"
  echo "✅ Bytecode generated in quickjs/repl_bytecode.c"
  echo "🔨 Converting C bytecode to Nim..."
  if not dirExists("build/qjs/src"):
    mkDir("build/qjs/src")
  exec "nim c -r --hints:off --outdir:build/tools/bin --nimcache:build/tools/nimcache tools/c_bytecode_to_nim.nim quickjs/repl_bytecode.c build/qjs/src/repl_bytecode.nim"
  echo "✅ Nim bytecode generated in build/qjs/src/repl_bytecode.nim"

task docs, "Generate API documentation":
  echo "📚 Generating API documentation..."
  exec "nim doc --outdir:docs --git.url:https://github.com/tapsterbot/burrito --git.commit:main --git.devel:main src/burrito.nim"
  exec "nim doc --outdir:docs --git.url:https://github.com/tapsterbot/burrito --git.commit:main --git.devel:main src/burrito/qjs.nim"
  exec "nim doc --outdir:docs --git.url:https://github.com/tapsterbot/burrito --git.commit:main --git.devel:main src/burrito/mpy.nim"
  echo "✅ Documentation generated in docs/burrito.html"

task serve_docs, "Generate API documentation":
  exec "python3 -m http.server --directory docs"

task sd, "Alias for serve_docs":
  exec "nimble serve_docs --silent"

# MicroPython tasks

task get_micropython, "Download MicroPython source":
  if dirExists("micropython"):
    echo "⚠️  MicroPython directory already exists. To re-download, first remove it:"
    echo "   nimble delete_micropython"
    echo "   (or manually: rm -rf ./micropython)"
    quit(1)
  echo "📥 Downloading MicroPython source..."
  exec "git clone https://github.com/micropython/micropython.git"
  echo "✅ MicroPython source downloaded"

task build_micropython, "Build MicroPython embedding library":
  if not dirExists("micropython"):
    echo "❌ MicroPython source not found. Run 'nimble get_micropython' first."
    quit(1)
  echo "🔨 Building MicroPython embedding library..."
  exec "cd micropython/examples/embedding && make -f micropython_embed.mk"
  echo "✅ MicroPython embedding library built successfully"

# Removed: build_micropython_unix_repl task (no longer needed with embedding API)

task delete_micropython, "Remove MicroPython source directory":
  if dirExists("micropython"):
    echo "🗑️  Removing MicroPython source directory..."
    rmDir("micropython")
    echo "✅ MicroPython directory removed"
  else:
    echo "ℹ️  No MicroPython directory found"

task example_mpy,"Run the MicroPython basic example":
  # First ensure embedding library is built
  if not fileExists("micropython/examples/embedding/libmicropython_embed.a"):
    echo "Building MicroPython embedding library first..."
    exec "nimble build_micropython"

  # Run the basic example
  exec "nim c -r --hints:off examples/mpy/basic_example.nim"
  echo ""

task repl_mpy, "Run MicroPython REPL":
  # First ensure embedding library is built
  if not fileExists("micropython/examples/embedding/libmicropython_embed.a"):
    echo "Building MicroPython embedding library first..."
    exec "nimble build_micropython"

  # Run the REPL
  exec "nim c -r --hints:off examples/mpy/repl_mpy.nim"

task empy, "Alias for MicroPython example":
  exec "nimble example_mpy"

task rmpy, "Alias for MicroPython REPL":
  exec "nimble repl_mpy"

task dual_engines, "Run dual engines example (JS + Python)":
  # Build QuickJS if needed
  if not fileExists("quickjs/libquickjs.a"):
    echo "Building QuickJS first..."
    exec "nimble build_quickjs"

  # Build MicroPython embedding library if needed
  if not fileExists("micropython/examples/embedding/libmicropython_embed.a"):
    echo "Building MicroPython embedding library first..."
    exec "nimble build_micropython"

  exec "nim c -r --hints:off examples/multi/dual_engines.nim"

task repl_nim, "Run INim REPL":
  let pwd = getCurrentDir()
  let cmd = """
    inim \
        -d:--path:src \
        -d:"--cincludes:\"$(pwd)/micropython/examples/embedding/micropython_embed\"" \
        -d:"--cincludes:\"$(pwd)/micropython/examples/embedding/micropython_embed/port\"" \
        -d:"--cincludes:\"$(pwd)/micropython/examples/embedding\"" \
        -d:"--passL:\"$(pwd)/micropython/examples/embedding/libmicropython_embed.a\"" \
        -d:"--passL:-lm"
  """
  exec cmd

task rnim, "Alias for Run INim REPL":
  exec "nimble repl_nim --silent"

task inim, "Alias for Run INim REPL":
  exec "nimble repl_nim --silent"

task i, "Alias for Run INim REPL":
  exec "nimble repl_nim --silent"
