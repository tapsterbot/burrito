## Comprehensive bytecode example
## Shows all bytecode features: compilation, execution, isolation, and REPL

import ../../src/burrito/qjs
import ../../build/qjs/src/repl_bytecode
import std/times

when isMainModule:
  echo "=== Comprehensive Bytecode Example ==="
  echo ""
  
  # Helper functions for examples
  proc safeAdd(ctx: ptr JSContext, a: JSValue, b: JSValue): JSValue =
    let numA = toNimFloat(ctx, a)
    let numB = toNimFloat(ctx, b)
    result = nimFloatToJS(ctx, numA + numB)
  
  proc getCurrentTime(ctx: ptr JSContext): JSValue =
    nimStringToJS(ctx, now().format("yyyy-MM-dd HH:mm:ss"))
  
  echo "🔄 1. Isolated Execution (defaultConfig - no std/os access)"
  echo "   Perfect for security-sensitive environments"
  var js1 = newQuickJS(defaultConfig())
  js1.registerFunction("safeAdd", safeAdd)
  
  let isolatedCode = """
    var result = safeAdd(10, 20);
    "Isolated calculation: " + result;
  """
  
  let isolatedBytecode = js1.compileToBytecode(isolatedCode)
  echo "   Bytecode size: ", isolatedBytecode.len, " bytes"
  let isolatedResult = js1.evalBytecode(isolatedBytecode)
  echo "   Result: ", isolatedResult
  js1.close()
  
  echo ""
  echo "🌐 2. Full-Featured Execution (configWithBothLibs)"
  echo "   Includes std and os libraries for complete functionality"
  var js2 = newQuickJS(configWithBothLibs())
  js2.registerFunction("safeAdd", safeAdd)
  js2.registerFunction("getCurrentTime", getCurrentTime)
  
  let fullCode = """
    var calc = safeAdd(15, 25);
    var time = getCurrentTime();
    "Full environment - Calc: " + calc + ", Time: " + time;
  """
  
  let fullBytecode = js2.compileToBytecode(fullCode)
  echo "   Bytecode size: ", fullBytecode.len, " bytes"
  let fullResult = js2.evalBytecode(fullBytecode)
  echo "   Result: ", fullResult
  
  echo ""
  echo "📊 3. Incremental Execution (state persistence)"
  echo "   Variables persist across separate bytecode executions"
  
  discard js2.evalBytecode(js2.compileToBytecode("var counter = 0;"))
  for i in 1..3:
    let incrementCode = "counter += " & $i & "; counter;"
    let value = js2.evalBytecode(js2.compileToBytecode(incrementCode))
    echo "   Step ", i, ": counter = ", value
  
  echo ""
  echo "🎯 4. Complex Bytecode (Large qjsc-compiled modules)"
  echo "   Demonstrates smart detection: large bytecode uses js_std_eval_binary"
  echo "   REPL bytecode size: ", qjsc_replBytecode.len, " bytes"
  echo "   ✓ Would use optimized execution path for complex modules"
  echo "   (See repl_bytecode.nim for actual REPL demo)"
  
  js2.close()
  
  echo ""
  echo "✅ Comprehensive bytecode demo completed!"
  echo ""
  echo "🎯 Key Benefits Demonstrated:"
  echo "   • Faster execution (no compilation at runtime)"
  echo "   • Isolated environments for security"
  echo "   • State persistence across executions" 
  echo "   • Self-contained binaries (no external files)"
  echo "   • Unified API works with any configuration"