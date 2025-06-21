import ../src/burrito
import std/times

# Nim functions that return JSValue for native bridging
proc getTime(ctx: ptr JSContext): JSValue =
  let timeStr = now().format("yyyy-MM-dd HH:mm:ss")
  result = nimStringToJS(ctx, timeStr)

proc getMessage(ctx: ptr JSContext): JSValue =
  let msg = "Hello from Nim! 🌯"
  result = nimStringToJS(ctx, msg)

proc main() =
  echo "Call Nim from JavaScript Example"
  echo "================================"
  
  var js = newQuickJS()
  defer: js.close()
  
  # Register Nim functions using native C bridging
  js.registerFunction("getTime", getTime)
  js.registerFunction("getMessage", getMessage)
  
  # Call Nim functions from JavaScript - now using native C function calls
  echo "Current time: ", js.eval("getTime()")
  echo "Message: ", js.eval("getMessage()")
  
  # Test with JavaScript code that calls our Nim functions
  let jsCode = """
    var time = getTime();
    var msg = getMessage();
    time + ' - ' + msg
  """
  echo "JS result: ", js.eval(jsCode)

when isMainModule:
  main()