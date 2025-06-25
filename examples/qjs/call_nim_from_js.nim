import ../../src/burrito/qjs
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

  # Anonymous function with a do block
  js.registerFunction("add") do (ctx: ptr JSContext, a: JSValue, b: JSValue) -> JSValue:
    let numA = toNimInt(ctx, a)
    let numB = toNimInt(ctx, b)
    return nimIntToJS(ctx, numA + numB)

  # Call Nim functions from JavaScript - now using native C function calls
  echo "Current time: ", js.eval("getTime()")
  echo "Message: ", js.eval("getMessage()")
  echo "add(1, 2): ", js.eval("add(1, 2)")

  # Slightly longer example calling JS code that calls Nim
  let jsCode = """
    var time = getTime();
    var msg = getMessage();
    time + ' - ' + msg
  """
  echo "\nJS result: ", js.eval(jsCode)

when isMainModule:
  main()
