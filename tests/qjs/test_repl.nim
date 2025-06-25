## REPL Integration Tests
##
## Tests the interactive REPL functionality using expect

import unittest
import std/[os, osproc, strutils]

suite "REPL Tests":
  test "REPL basic functionality":
    # Check if expect is available
    let (expectOutput, expectCode) = execCmdEx("which expect")
    if expectCode != 0:
      skip()
    elif not fileExists("tests/qjs/test_repl.exp"):
      skip()
    else:
      # Compile repl_qjs if it doesn't exist
      if not fileExists("build/qjs/bin/repl_qjs"):
        echo "Compiling QuickJS repl for testing..."
        let (compileOutput, compileCode) = execCmdEx("nim c --hints:off examples/qjs/repl_qjs.nim")
        if compileCode != 0:
          echo "Failed to compile repl: ", compileOutput
          fail()
        else:
          # Run the expect test only if compilation succeeded
          let (output, exitCode) = execCmdEx("tests/qjs/test_repl.exp")
          check exitCode == 0
          check "All tests passed!" in output
          check "REPL exited cleanly with Ctrl+D" in output
      else:
        # Binary exists, run the expect test
        let (output, exitCode) = execCmdEx("tests/qjs/test_repl.exp")
        check exitCode == 0
        check "All tests passed!" in output
        check "REPL exited cleanly with Ctrl+D" in output

  test "REPL with custom functions":
    # Check if expect is available
    let (expectOutput, expectCode) = execCmdEx("which expect")
    if expectCode != 0:
      skip()
    else:
      # Compile repl_with_nim_functions if it doesn't exist
      if not fileExists("build/qjs/bin/repl_with_nim_functions"):
        echo "Compiling repl_with_nim_functions for testing..."
        let (compileOutput, compileCode) = execCmdEx("nim c --hints:off examples/qjs/repl_with_nim_functions.nim")
        if compileCode != 0:
          echo "Failed to compile repl_with_nim_functions: ", compileOutput
          fail()
        else:
          # Test the compiled binary
          let process = startProcess("build/qjs/bin/repl_with_nim_functions")
          sleep(500)  # Give it time to start
          if process.running():
            process.terminate()
            process.close()
            check true
          else:
            let exitCode = process.waitForExit()
            process.close()
            check exitCode == 0
      else:
        # Binary exists, test it
        let process = startProcess("build/qjs/bin/repl_with_nim_functions")
        sleep(500)  # Give it time to start
        if process.running():
          process.terminate()
          process.close()
          check true
        else:
          let exitCode = process.waitForExit()
          process.close()
          check exitCode == 0

  test "REPL bytecode functionality":
    # Check if expect is available
    let (expectOutput, expectCode) = execCmdEx("which expect")
    if expectCode != 0:
      skip()
    elif not fileExists("tests/qjs/test_repl_bytecode.exp"):
      skip()
    else:
      # Compile repl_bytecode if it doesn't exist
      if not fileExists("build/qjs/bin/repl_bytecode"):
        echo "Compiling repl_bytecode for testing..."
        let (compileOutput, compileCode) = execCmdEx("nim c --hints:off examples/qjs/repl_bytecode.nim")
        if compileCode != 0:
          echo "Failed to compile repl_bytecode: ", compileOutput
          fail()
        else:
          # Run the expect test only if compilation succeeded
          let (output, exitCode) = execCmdEx("tests/qjs/test_repl_bytecode.exp")
          check exitCode == 0
          check "All REPL bytecode tests passed!" in output
          check "REPL started successfully!" in output
      else:
        # Binary exists, run the expect test
        let (output, exitCode) = execCmdEx("tests/qjs/test_repl_bytecode.exp")
        check exitCode == 0
        check "All REPL bytecode tests passed!" in output
        check "REPL started successfully!" in output