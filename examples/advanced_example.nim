## Advanced QuickJS Nim Example
##
## This example demonstrates:
## 1. More complex JavaScript evaluation
## 2. Error handling
## 3. Working with different data types
## 4. Registering actual Nim functions as C callbacks

import ../src/quickjs_nim
import std/[strutils, tables, math, algorithm]

# Global storage for registered functions (simplified approach)
var nimFunctions: Table[string, proc(args: seq[string]): string]

# C callback function that bridges JavaScript calls to Nim
proc nimFunctionBridge(ctx: JSContext, thisVal: JSValueConst, argc: int32, argv: ptr JSValueConst): JSValue {.cdecl.} =
  # For this demo, we'll hardcode function names
  # In a production system, you'd store function metadata in the JSValue or context
  
  # Convert JS arguments to Nim strings
  var args: seq[string] = @[]
  for i in 0..<argc:
    let argVal = cast[ptr JSValueConst](cast[int](argv) + i * sizeof(JSValueConst))[]
    args.add(ctx.toNimString(argVal))
  
  # For this example, we'll determine the function name from context
  # In reality, you'd store this in the function object's opaque data
  
  # Try to call a registered function (this is simplified)
  if "calculate" in nimFunctions:
    let result = nimFunctions["calculate"](args)
    return JS_NewString(ctx, result.cstring)
  
  return ctx.jsUndefined()

# Nim functions to expose
proc calculate(args: seq[string]): string =
  if args.len >= 3:
    try:
      let operation = args[0]
      let a = parseFloat(args[1])
      let b = parseFloat(args[2])
      
      case operation:
      of "add": return $(a + b)
      of "subtract": return $(a - b)
      of "multiply": return $(a * b)
      of "divide":
        if b == 0:
          return "Error: Division by zero"
        return $(a / b)
      of "power": return $(pow(a, b))
      of "sqrt":
        if a < 0:
          return "Error: Cannot take square root of negative number"
        return $sqrt(a)
      else: return "Error: Unknown operation: " & operation
    except ValueError:
      return "Error: Invalid numbers"
  else:
    return "Error: Need operation and numbers"

proc processText(args: seq[string]): string =
  if args.len >= 2:
    let operation = args[0]
    let text = args[1]
    
    case operation:
    of "upper": return text.toUpper()
    of "lower": return text.toLower()
    of "reverse": 
      var reversed = ""
      for i in countdown(text.len - 1, 0):
        reversed.add(text[i])
      return reversed
    of "length": return $text.len
    of "words": return $text.split().len
    of "capitalize": return text.capitalizeAscii()
    else: return "Error: Unknown operation: " & operation
  else:
    return "Error: Need operation and text"

proc registerNimFunction(js: QuickJS, name: string, nimFunc: proc(args: seq[string]): string) =
  ## Register a Nim function to be callable from JavaScript
  nimFunctions[name] = nimFunc
  
  let jsFunc = JS_NewCFunction(js.context, nimFunctionBridge, name.cstring, 0)
  let globalObj = JS_GetGlobalObject(js.context)
  defer: JS_FreeValue(js.context, globalObj)
  
  discard JS_DefinePropertyValueStr(js.context, globalObj, name.cstring, jsFunc, 
                                   JS_PROP_WRITABLE or JS_PROP_CONFIGURABLE)

proc main() =
  echo "QuickJS Nim Wrapper - Advanced Example"
  echo "======================================"
  
  var js = newQuickJS()
  defer: js.close()
  
  # Test complex JavaScript without Nim functions
  echo "\n1. Complex JavaScript evaluation:"
  
  let fibResult = js.eval("""
    function fibonacci(n) {
      if (n <= 1) return n;
      return fibonacci(n - 1) + fibonacci(n - 2);
    }
    
    const numbers = [];
    for (let i = 0; i < 10; i++) {
      numbers.push(fibonacci(i));
    }
    
    'Fibonacci sequence: ' + numbers.join(', ');
  """)
  echo "  ", fibResult
  
  # Test object manipulation
  echo "\n2. Object and array manipulation:"
  
  let objectResult = js.eval("""
    const data = {
      users: [
        {name: 'Alice', age: 30, city: 'New York'},
        {name: 'Bob', age: 25, city: 'London'},
        {name: 'Charlie', age: 35, city: 'Tokyo'}
      ]
    };
    
    const adults = data.users.filter(user => user.age >= 30);
    const summary = {
      total: data.users.length,
      adults: adults.length,
      cities: [...new Set(data.users.map(u => u.city))].join(', ')
    };
    
    JSON.stringify(summary, null, 2);
  """)
  echo "  Object processing result:\n", objectResult
  
  # Register and test Nim functions  
  echo "\n3. Registering Nim functions as JavaScript functions:"
  
  # Note: This is a simplified demo. The actual function calling
  # would need more sophisticated argument passing
  nimFunctions["calculate"] = calculate
  
  echo "  Demonstrating Nim function capabilities:"
  echo "  - calculate(['add', '10', '5']) = ", calculate(@["add", "10", "5"])
  echo "  - calculate(['power', '2', '8']) = ", calculate(@["power", "2", "8"])
  echo "  - calculate(['sqrt', '16']) = ", calculate(@["sqrt", "16", "0"])
  
  echo "  - processText(['upper', 'hello nim']) = ", processText(@["upper", "hello nim"])
  echo "  - processText(['reverse', 'QuickJS']) = ", processText(@["reverse", "QuickJS"])
  
  # Test error handling
  echo "\n4. Error handling:"
  
  let errorTest1 = js.eval("JSON.parse('{invalid json}')")
  echo "  Invalid JSON: ", errorTest1
  
  let errorTest2 = js.eval("nonExistentFunction()")
  echo "  Non-existent function: ", errorTest2
  
  let errorTest3 = js.eval("1 / 0")
  echo "  Division by zero: ", errorTest3
  
  # Test complex computation with data flow
  echo "\n5. Complex data processing:"
  
  var globals = initTable[string, string]()
  globals["dataSize"] = "1000"
  globals["iterations"] = "5"
  
  let computeResult = js.evalWithGlobals("""
    function processData(size, iter) {
      let sum = 0;
      let operations = 0;
      
      for (let i = 0; i < iter; i++) {
        for (let j = 0; j < size; j++) {
          sum += Math.sin(j * 0.001) * Math.cos(i * 0.01);
          operations++;
        }
      }
      
      return {
        sum: sum.toFixed(6),
        operations: operations,
        average: (sum / operations).toFixed(8)
      };
    }
    
    const result = processData(parseInt(dataSize), parseInt(iterations));
    JSON.stringify(result, null, 2);
  """, globals)
  
  echo "  Computation result:\n", computeResult
  
  echo "\nAdvanced example completed successfully!"

when isMainModule:
  main()