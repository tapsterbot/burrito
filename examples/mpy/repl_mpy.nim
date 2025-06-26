## Burrito REPL - Interactive Python REPL using MicroPython
##
## This program creates an interactive REPL similar to the Python interpreter
## using MicroPython's built-in pyexec_friendly_repl function.

import ../../src/burrito/mpy

proc main() =
  # Create MicroPython instance with larger heap for REPL operations
  var py = newMicroPython(heapSize = 256 * 1024)  # 256KB heap
  defer: py.close()

  # Start the interactive REPL with readline support
  # Features: command history, line editing, tab completion
  py.startReplWithReadline()

when isMainModule:
  main()
