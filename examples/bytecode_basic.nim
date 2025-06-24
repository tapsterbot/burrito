## Basic bytecode example
## Shows fundamental bytecode compilation and execution

import ../src/burrito

when isMainModule:
  echo "=== Basic Bytecode Example ==="
  echo ""
  
  var js = newQuickJS()
  
  # Add a simple function
  proc multiply(ctx: ptr JSContext, a: JSValue, b: JSValue): JSValue =
    let numA = toNimFloat(ctx, a)
    let numB = toNimFloat(ctx, b)
    result = nimFloatToJS(ctx, numA * numB)
  
  js.registerFunction("multiply", multiply)
  
  echo "1. Compile and execute simple bytecode:"
  let code = "multiply(6, 7);"
  let bytecode = js.compileToBytecode(code)
  let result = js.evalBytecode(bytecode)
  echo "   ", code, " → ", result
  
  echo ""
  echo "2. Variables persist across bytecode executions:"
  discard js.evalBytecode(js.compileToBytecode("var x = 10;"))
  discard js.evalBytecode(js.compileToBytecode("var y = 5;"))
  let sum = js.evalBytecode(js.compileToBytecode("x + y"))
  echo "   x + y → ", sum
  
  js.close()
  echo ""
  echo "✅ Basic bytecode compilation and execution completed!"