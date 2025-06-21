## Basic Burrito Example
##
## This example demonstrates:
## 1. Creating a QuickJS instance
## 2. Evaluating JavaScript code
## 3. Setting global variables from Nim
## 4. Working with the simplified API

import ../src/burrito
import std/[strutils, tables, sequtils]

proc main() =
  echo "Burrito - QuickJS Nim Wrapper - Basic Example"
  echo "=============================================="
  
  # Create QuickJS instance
  var js = newQuickJS()
  defer: js.close()
  
  # Test basic JavaScript evaluation
  echo "\n1. Basic JavaScript evaluation:"
  let result1 = js.eval("2 + 3 * 4")
  echo "  2 + 3 * 4 = ", result1
  
  let result2 = js.eval("Math.sqrt(16)")
  echo "  Math.sqrt(16) = ", result2
  
  let result3 = js.eval("'Hello ' + 'World!'")
  echo "  'Hello ' + 'World!' = ", result3
  
  # Test JavaScript with global variables
  echo "\n2. Setting global variables from Nim:"
  var globals = initTable[string, string]()
  globals["name"] = "QuickJS"
  globals["version"] = "2025-04-26"
  globals["message"] = "Hello from Nim!"
  
  let result4 = js.evalWithGlobals(
    "`My name is ${name}, version ${version}. ${message}`",
    globals
  )
  echo "  Template result: ", result4
  
  # Test setting JavaScript functions
  echo "\n3. Setting JavaScript functions from Nim:"
  js.setJSFunction("addTen", "function(x) { return x + 10; }")
  js.setJSFunction("greet", "function(name) { return 'Hello, ' + name + '!'; }")
  
  let result5 = js.eval("addTen(5)")
  echo "  addTen(5) = ", result5
  
  let result6 = js.eval("greet('Alice')")
  echo "  greet('Alice') = ", result6
  
  # Test more complex JavaScript
  echo "\n4. Complex JavaScript expressions:"
  
  let result7 = js.eval("[1, 2, 3].map(x => x * 2).join(', ')")
  echo "  [1, 2, 3].map(x => x * 2).join(', ') = ", result7
  
  let result8 = js.eval("JSON.stringify({name: 'QuickJS', version: '2025-04-26'})")
  echo "  JSON.stringify({name: 'QuickJS', version: '2025-04-26'}) = ", result8
  
  # Test setting data that can be processed in JavaScript
  echo "\n5. Nim data processing in JavaScript:"
  
  # Nim calculates some data
  let numbers = @[1, 2, 3, 4, 5]
  let sum = numbers.foldl(a + b)
  let avg = sum.float / numbers.len.float
  
  # Pass the calculated data to JavaScript
  var nimData = initTable[string, string]()
  nimData["sum"] = $sum
  nimData["average"] = $avg
  nimData["count"] = $numbers.len
  
  let result9 = js.evalWithGlobals("""
    const report = {
      sum: parseInt(sum),
      average: parseFloat(average),
      count: parseInt(count),
      description: `Processed ${count} numbers with sum ${sum} and average ${average.substring(0, 5)}`
    };
    JSON.stringify(report, null, 2);
  """, nimData)
  
  echo "  Data processing result:\n", result9
  
  echo "\nExample completed successfully!"

when isMainModule:
  main()