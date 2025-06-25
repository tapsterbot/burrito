import ../../src/burrito/qjs
import std/times

# Example functions demonstrating different argument patterns

# No arguments - returns current timestamp
proc getCurrentTimestamp(ctx: ptr JSContext): JSValue =
  let timestamp = now().toTime().toUnix()
  result = nimIntToJS(ctx, timestamp.int32)

# One argument - square a number
proc square(ctx: ptr JSContext, arg: JSValue): JSValue =
  let num = toNimFloat(ctx, arg)
  let squared = num * num
  result = nimFloatToJS(ctx, squared)

# Two arguments - add two numbers
proc addNumbers(ctx: ptr JSContext, arg1, arg2: JSValue): JSValue =
  let a = toNimFloat(ctx, arg1)
  let b = toNimFloat(ctx, arg2)
  result = nimFloatToJS(ctx, a + b)

# Three arguments - calculate volume of a box
proc boxVolume(ctx: ptr JSContext, length, width, height: JSValue): JSValue =
  let l = toNimFloat(ctx, length)
  let w = toNimFloat(ctx, width)
  let h = toNimFloat(ctx, height)
  result = nimFloatToJS(ctx, l * w * h)

# Variadic arguments - concatenate strings
proc concatenateStrings(ctx: ptr JSContext, args: seq[JSValue]): JSValue =
  var result_str = ""
  for arg in args:
    let str_val = toNimString(ctx, arg)
    result_str.add(str_val)
  result = nimStringToJS(ctx, result_str)

# More complex function - factorial
proc factorial(ctx: ptr JSContext, arg: JSValue): JSValue =
  let n = toNimInt(ctx, arg)
  if n < 0:
    result = nimStringToJS(ctx, "Error: Factorial undefined for negative numbers")
  elif n == 0 or n == 1:
    result = nimIntToJS(ctx, 1)
  else:
    var fact: int32 = 1
    for i in 2..n:
      fact *= i
    result = nimIntToJS(ctx, fact)

proc main() =
  echo "Advanced Native C Function Bridging Example"
  echo "============================================"
  
  var js = newQuickJS()
  defer: js.close()
  
  # Register all our functions
  js.registerFunction("getCurrentTimestamp", getCurrentTimestamp)
  js.registerFunction("square", square)
  js.registerFunction("addNumbers", addNumbers)
  js.registerFunction("boxVolume", boxVolume)
  js.registerFunction("concatenateStrings", concatenateStrings)
  js.registerFunction("factorial", factorial)
  
  echo "\nTesting native C function calls:"
  echo "================================"
  
  # Test no-argument function
  echo "Current timestamp: ", js.eval("getCurrentTimestamp()")
  
  # Test single argument function
  echo "Square of 7: ", js.eval("square(7)")
  echo "Square of 3.14: ", js.eval("square(3.14)")
  
  # Test two-argument function
  echo "5 + 3 = ", js.eval("addNumbers(5, 3)")
  echo "2.5 + 7.3 = ", js.eval("addNumbers(2.5, 7.3)")
  
  # Test three-argument function
  echo "Box volume (2x3x4): ", js.eval("boxVolume(2, 3, 4)")
  
  # Test variadic function
  echo "Concatenate strings: ", js.eval("concatenateStrings('Hello', ' ', 'from', ' ', 'Nim!')")
  
  # Test factorial
  echo "Factorial of 5: ", js.eval("factorial(5)")
  echo "Factorial of 0: ", js.eval("factorial(0)")
  echo "Factorial of -1: ", js.eval("factorial(-1)")
  
  # Test complex JavaScript code using our Nim functions
  let complexJS = """
    function performCalculations() {
      var nums = [1, 2, 3, 4, 5];
      var squares = nums.map(square);
      var sum = squares.reduce(addNumbers);
      var timestamp = getCurrentTimestamp();
      
      return {
        numbers: nums,
        squares: squares,
        sum: sum,
        timestamp: timestamp,
        message: concatenateStrings('Processed at ', timestamp.toString())
      };
    }
    
    JSON.stringify(performCalculations());
  """
  
  echo "\nComplex calculation result:"
  echo js.eval(complexJS)

when isMainModule:
  main()