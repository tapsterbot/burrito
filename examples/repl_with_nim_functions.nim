## Drop-in REPL Example - Exposing Nim Functions to JavaScript REPL
##
## This example demonstrates how to embed a JavaScript REPL into your Nim application
## and expose custom Nim functions that can be called from the REPL.
##
## Perfect for creating developer tools, debugging interfaces, or interactive applications.

import ../src/burrito
import std/[os, times, unicode]

proc main() =
  echo "🌯 Burrito REPL with Custom Nim Functions"
  echo "=========================================="
  echo ""

  # Create QuickJS instance with full REPL support
  var js = newQuickJS(QuickJSConfig(
    enableStdHandlers: true,
    includeStdLib: true,
    includeOsLib: true
  ))
  defer: js.close()

  # Define custom Nim functions to expose to JavaScript

  proc greet(ctx: ptr JSContext, name: JSValue): JSValue =
    ## Simple greeting function that takes a name
    let nameStr = toNimString(ctx, name)
    let greeting = "Hello from Nim, " & nameStr & "! 🌯"
    result = nimStringToJS(ctx, greeting)

  proc getCurrentTime(ctx: ptr JSContext): JSValue =
    ## Get current time formatted nicely
    let timeStr = now().format("yyyy-MM-dd HH:mm:ss")
    result = nimStringToJS(ctx, timeStr)

  proc calculate(ctx: ptr JSContext, operation: JSValue, a: JSValue, b: JSValue): JSValue =
    ## Perform basic math operations
    let op = toNimString(ctx, operation)
    let numA = toNimFloat(ctx, a)
    let numB = toNimFloat(ctx, b)

    let result_val = case op:
      of "add", "+": numA + numB
      of "sub", "-": numA - numB
      of "mul", "*": numA * numB
      of "div", "/":
        if numB == 0.0:
          return nimStringToJS(ctx, "Error: Division by zero")
        else:
          numA / numB
      else:
        return nimStringToJS(ctx, "Error: Unknown operation '" & op & "'")

    result = nimFloatToJS(ctx, result_val)

  proc getSystemInfo(ctx: ptr JSContext): JSValue =
    ## Get basic system information
    let info = "Platform: " & hostOS & ", CPU: " & hostCPU
    result = nimStringToJS(ctx, info)

  proc reverseString(ctx: ptr JSContext, text: JSValue): JSValue =
    ## Reverse a string
    let input = toNimString(ctx, text)
    let reversed = input.reversed()
    result = nimStringToJS(ctx, reversed)

  # Register all our custom functions with the REPL
  echo "Registering custom Nim functions..."
  js.registerFunction("greet", greet)
  js.registerFunction("getCurrentTime", getCurrentTime)
  js.registerFunction("calculate", calculate)
  js.registerFunction("getSystemInfo", getSystemInfo)
  js.registerFunction("reverseString", reverseString)

  # Display available functions
  echo """
Available custom functions in the REPL:
  • greet(name)                    - Greet someone
  • getCurrentTime()               - Get current timestamp
  • calculate(op, a, b)            - Math operations (add, sub, mul, div)
  • getSystemInfo()                - System platform info
  • reverseString(text)            - Reverse a string

Try these examples:
  greet("Alice")
  getCurrentTime()
  calculate("add", 10, 5)
  calculate("mul", 7, 6)
  getSystemInfo()
  reverseString("Hello World")

Plus all standard JavaScript and QuickJS std/os modules are available!
Use std.printf(), os.getcwd(), etc.

Press Ctrl+D, Ctrl+C, or type \\q to exit.
"""

  # Check if repl.js exists
  let replPath = "quickjs/repl.js"
  if not fileExists(replPath):
    echo "Error: repl.js not found at ", replPath
    echo "Make sure you have run 'nimble get_quickjs' first"
    quit(1)

  # Load and start the interactive REPL
  echo "Loading REPL..."
  let replCode = readFile(replPath)

  try:
    discard js.evalModule(replCode, "<repl>")
  except JSException as e:
    echo "Error loading REPL: ", e.msg
    quit(1)

  # Process pending jobs (needed for module loading)
  js.runPendingJobs()

  # REPL is now running! Users can:
  # - Call your Nim functions: greet("Alice")
  # - Use std/os modules: std.printf("Hello %s\n", "world")
  # - Get syntax highlighting and command history
  # - Exit with Ctrl+D, Ctrl+C, or \q
  js.processStdLoop()

  echo "\nREPL session ended. Goodbye! 👋"

when isMainModule:
  main()