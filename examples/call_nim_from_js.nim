import ../src/burrito
import std/times

proc getTime(): string =
  now().format("yyyy-MM-dd HH:mm:ss")

proc getMessage(): string =
  "Hello from Nim! 🌯"

proc main() =
  echo "Call Nim from JavaScript Example"
  echo "================================"
  
  var js = newQuickJS()
  defer: js.close()
  
  # Set up the bridge
  js.setupNimBridge()
  
  # Register Nim functions
  js.registerFunction("getTime", getTime)
  js.registerFunction("getMessage", getMessage)
  
  # Call Nim functions from JavaScript
  echo "Current time: ", js.eval("getTime()")
  echo "Message: ", js.eval("getMessage()")

when isMainModule:
  main()