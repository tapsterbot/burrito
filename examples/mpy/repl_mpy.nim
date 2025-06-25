## Burrito REPL - Interactive Python REPL using MicroPython
##
## This program creates an interactive REPL similar to the Python interpreter
## using MicroPython's built-in pyexec_friendly_repl function.

import ../../src/burrito/mpy

proc main() =
  # Create MicroPython instance with larger heap for REPL operations
  var py = newMicroPython(heapSize = 256 * 1024)  # 256KB heap
  defer: py.close()

  # Display welcome message
  echo "🌯 Burrito - MicroPython wrapper"
  
  # Start the interactive REPL
  # This will handle everything including the banner, prompts, and Ctrl+D to exit
  py.startRepl()

when isMainModule:
  main()