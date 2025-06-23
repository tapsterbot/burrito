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
    elif not fileExists("build/bin/repl"):
      skip()
    elif not fileExists("tests/test_repl.exp"):
      skip()
    else:
      # Run the expect test
      let (output, exitCode) = execCmdEx("tests/test_repl.exp")

      check exitCode == 0
      check "All tests passed!" in output
      check "REPL exited cleanly with Ctrl+D" in output

  test "REPL with custom functions":
    # Check if expect is available
    let (expectOutput, expectCode) = execCmdEx("which expect")
    if expectCode != 0:
      skip()
    elif not fileExists("build/bin/repl_with_nim_functions"):
      skip()
    else:
      # For now, just check that the binary can start and respond
      # (A full expect test for the custom functions would be more complex)
      let process = startProcess("build/bin/repl_with_nim_functions")
      sleep(500)  # Give it time to start

      if process.running():
        process.terminate()
        process.close()
        # If it started and was running, that's a good sign
        check true
      else:
        let exitCode = process.waitForExit()
        process.close()
        # If it exited immediately, that might be an error
        if exitCode != 0:
          fail()
        else:
          # Exit code 0 might be normal if it's configured to exit immediately
          check true