## MicroPython REPL Integration Tests
##
## Tests the interactive MicroPython REPL functionality using expect

import unittest
import std/[os, osproc, strutils]

suite "MicroPython REPL Tests":
  test "MicroPython REPL basic functionality":
    # Check if expect is available
    let (expectOutput, expectCode) = execCmdEx("which expect")
    if expectCode != 0:
      skip()
    elif not fileExists("tests/mpy/test_repl.exp"):
      skip()
    else:
      # Compile mpy repl if it doesn't exist
      if not fileExists("build/mpy/bin/repl_mpy"):
        echo "Compiling MicroPython repl for testing..."
        let (compileOutput, compileCode) = execCmdEx("nim c --hints:off examples/mpy/repl_mpy.nim")
        if compileCode != 0:
          echo "Failed to compile MicroPython repl: ", compileOutput
          fail()
        else:
          # Run the expect test with simple execution
          let (output, exitCode) = execCmdEx("tests/mpy/test_repl.exp")
          check exitCode == 0
          check "All tests passed!" in output
          check "REPL exited cleanly with Ctrl+D" in output
      else:
        # Binary exists, run the expect test
        let (output, exitCode) = execCmdEx("tests/mpy/test_repl.exp")
        check exitCode == 0
        check "All tests passed!" in output
        check "REPL exited cleanly with Ctrl+D" in output

  test "MicroPython REPL startup":
    # Test that MicroPython REPL can start and exit cleanly with timeout
    if not fileExists("build/mpy/bin/repl_mpy"):
      echo "Compiling MicroPython repl for startup test..."
      let (compileOutput, compileCode) = execCmdEx("nim c --hints:off examples/mpy/repl_mpy.nim")
      if compileCode != 0:
        echo "Failed to compile MicroPython repl: ", compileOutput
        fail()
    
    # Test that the binary can start (but don't try to interact)
    let process = startProcess("build/mpy/bin/repl_mpy")
    sleep(1000)  # Give it time to start
    if process.running():
      process.terminate()
      discard process.waitForExit()  # Wait for termination
      process.close()
      check true  # Successfully started and terminated
    else:
      let exitCode = process.waitForExit()
      process.close()
      # REPL should not exit immediately unless there's an error
      check exitCode == 0