## Burrito REPL - Interactive JavaScript REPL using QuickJS
##
## This program creates an interactive REPL similar to qjs by loading
## the QuickJS repl.js file and providing the necessary runtime environment.

import ../src/burrito
import std/os

proc main() =
  # Create QuickJS instance with full standard library support
  var js = newQuickJS(QuickJSConfig(
    enableStdHandlers: true,
    includeStdLib: true,
    includeOsLib: true
  ))
  defer: js.close()

  # Get the path to repl.js
  let replPath = "quickjs/repl.js"
  if not fileExists(replPath):
    echo "Error: repl.js not found at ", replPath
    echo "Make sure you have run 'nimble get_quickjs' first"
    quit(1)

  # Read the repl.js file
  let replCode = readFile(replPath)

  # Evaluate repl.js as a module (it uses ES6 imports)
  try:
    echo "🌯 Burrito - QuickJS wrapper"
    discard js.evalModule(replCode, "<repl>")
  except JSException as e:
    echo "Error loading REPL: ", e.msg
    quit(1)

  # Process pending jobs (needed for module loading)
  js.runPendingJobs()

  # Run the standard event loop - this will handle the REPL until it exits
  # The js_std_loop function in QuickJS handles everything including Ctrl+D
  js.processStdLoop()

when isMainModule:
  main()