# Package

version       = "0.1.0"
author        = "Jason R. Huggins"
description   = "Burrito: Lightweight Nim wrapper for QuickJS JavaScript engine"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 2.2.4"

# Tasks

task example, "Run the basic example":
  exec "nim c -r examples/basic_example.nim"

task build_lib, "Build the QuickJS library":
  exec "cd quickjs && make"
