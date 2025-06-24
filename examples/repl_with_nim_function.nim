import ../src/burrito

proc main() =
  # Create QuickJS instance with full REPL support
  var js = newQuickJS(QuickJSConfig(
    enableStdHandlers: true,
    includeStdLib: true,
    includeOsLib: true
  ))
  defer: js.close()

  # Add your custom functions to the REPL environment
  proc greet(ctx: ptr JSContext, name: JSValue): JSValue =
    let nameStr = toNimString(ctx, name)
    nimStringToJS(ctx, "Hello from Nim, " & nameStr & "!")

  js.registerFunction("greet", greet)

  # Load and start the interactive REPL
  let replCode = readFile("quickjs/repl.js")
  discard js.evalModule(replCode, "<repl>")
  js.runPendingJobs()

  # REPL is now running! Users can:
  # - Call your Nim functions: greet("Alice")
  # - Use std/os modules: std.printf("Hello %s\n", "world")
  # - Get syntax highlighting and command history
  # - Exit with Ctrl+D, Ctrl+C, or \q
  js.processStdLoop()

when isMainModule:
  main()