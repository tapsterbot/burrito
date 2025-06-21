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
  echo ""

task build_lib, "Build the QuickJS library":
  exec "cd quickjs && make"

task clean, "Clean build artifacts":
  exec "cd quickjs && make clean"
  exec "rm -f src/burrito examples/basic_example examples/call_nim_from_js examples/advanced_native_bridging"

task test, "Run tests and examples":
  exec "nimble examples"
