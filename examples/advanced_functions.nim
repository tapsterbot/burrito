import ../src/burrito
import std/strutils

# Example of a Nim function that works with JavaScript objects
proc processUser(ctx: ptr JSContext, userObj: JSValue): JSValue =
  # Check if it's actually an object
  if not isObject(ctx, userObj):
    JS_FreeValue(ctx, userObj)
    return JS_ThrowTypeError(ctx, "Expected an object")
  
  # Extract user data
  let nameVal = getProperty(ctx, userObj, "name")
  let ageVal = getProperty(ctx, userObj, "age")
  defer:
    JS_FreeValue(ctx, userObj)  # Free the argument
    JS_FreeValue(ctx, nameVal)
    JS_FreeValue(ctx, ageVal)
  
  # Validate data types
  if not isString(ctx, nameVal):
    return JS_ThrowTypeError(ctx, "Name must be a string")
  if not isNumber(ctx, ageVal):
    return JS_ThrowTypeError(ctx, "Age must be a number")
  
  let name = toNimString(ctx, nameVal)
  let age = toNimInt(ctx, ageVal)
  
  # Create result object
  let resultObj = JS_NewObject(ctx)
  discard setProperty(ctx, resultObj, "processedName", nimStringToJS(ctx, name.toUpper()))
  discard setProperty(ctx, resultObj, "isAdult", nimBoolToJS(ctx, age >= 18))
  discard setProperty(ctx, resultObj, "category", nimStringToJS(ctx, 
    if age < 13: "child"
    elif age < 20: "teenager" 
    else: "adult"))
  
  return resultObj

# Function that creates and returns a JavaScript array
proc createNumberArray(ctx: ptr JSContext, count: JSValue): JSValue =
  if not isNumber(ctx, count):
    JS_FreeValue(ctx, count)
    return JS_ThrowTypeError(ctx, "Count must be a number")
  
  let n = toNimInt(ctx, count)
  JS_FreeValue(ctx, count)
  
  if n < 0 or n > 1000:
    return JS_ThrowRangeError(ctx, "Count must be between 0 and 1000")
  
  let arr = newArray(ctx)
  for i in 0..<n:
    discard setArrayElement(ctx, arr, i.uint32, nimIntToJS(ctx, i * i))  # squares
  
  return arr

# Function that works with arrays
proc sumArray(ctx: ptr JSContext, arr: JSValue): JSValue =
  if not isArray(ctx, arr):
    JS_FreeValue(ctx, arr)
    return JS_ThrowTypeError(ctx, "Expected an array")
  
  let length = getArrayLength(ctx, arr)
  var sum: float64 = 0
  
  for i in 0..<length:
    let element = getArrayElement(ctx, arr, i)
    defer: JS_FreeValue(ctx, element)
    
    if isNumber(ctx, element):
      sum += toNimFloat(ctx, element)
  
  JS_FreeValue(ctx, arr)
  return nimFloatToJS(ctx, sum)

# Function that demonstrates error handling
proc safeDivide(ctx: ptr JSContext, a: JSValue, b: JSValue): JSValue =
  defer:
    JS_FreeValue(ctx, a)
    JS_FreeValue(ctx, b)
  
  if not isNumber(ctx, a) or not isNumber(ctx, b):
    return JS_ThrowTypeError(ctx, "Both arguments must be numbers")
  
  let numA = toNimFloat(ctx, a)
  let numB = toNimFloat(ctx, b)
  
  if numB == 0.0:
    return JS_ThrowRangeError(ctx, "Division by zero")
  
  return nimFloatToJS(ctx, numA / numB)

# Function that creates complex nested objects
proc createConfig(ctx: ptr JSContext): JSValue =
  let config = JS_NewObject(ctx)
  
  # Create database section
  let db = JS_NewObject(ctx)
  discard setProperty(ctx, db, "host", nimStringToJS(ctx, "localhost"))
  discard setProperty(ctx, db, "port", nimIntToJS(ctx, 5432))
  discard setProperty(ctx, db, "ssl", nimBoolToJS(ctx, true))
  
  # Create allowed IPs array
  let allowedIPs = newArray(ctx)
  discard setArrayElement(ctx, allowedIPs, 0, nimStringToJS(ctx, "127.0.0.1"))
  discard setArrayElement(ctx, allowedIPs, 1, nimStringToJS(ctx, "192.168.1.0/24"))
  discard setProperty(ctx, db, "allowedIPs", allowedIPs)
  
  # Create server section
  let server = JS_NewObject(ctx)
  discard setProperty(ctx, server, "port", nimIntToJS(ctx, 8080))
  discard setProperty(ctx, server, "workers", nimIntToJS(ctx, 4))
  
  # Assemble main config
  discard setProperty(ctx, config, "database", db)
  discard setProperty(ctx, config, "server", server)
  discard setProperty(ctx, config, "version", nimStringToJS(ctx, "2.1.0"))
  
  return config

proc main() =
  echo "Advanced Functions with Objects and Arrays"
  echo "========================================="
  
  var js = newQuickJS()
  defer: js.close()
  
  # Register our advanced functions
  js.registerFunction("processUser", processUser)
  js.registerFunction("createNumberArray", createNumberArray)
  js.registerFunction("sumArray", sumArray)
  js.registerFunction("safeDivide", safeDivide)
  js.registerFunction("createConfig", createConfig)
  
  echo "\n1. Processing User Objects:"
  echo "---------------------------"
  
  # Test processUser with valid data
  let validUserTest = """
    var user = {name: "john doe", age: 25};
    processUser(user);
  """
  echo "Valid user result: ", js.eval(validUserTest)
  
  # Test processUser with invalid data
  echo "\n2. Error Handling Examples:"
  echo "---------------------------"
  
  try:
    discard js.eval("processUser('not an object')")
  except JSException as e:
    echo "Caught error (expected): ", e.msg
  
  try:
    discard js.eval("processUser({name: 123, age: 25})")  # invalid name type
  except JSException as e:
    echo "Caught error (expected): ", e.msg
  
  echo "\n3. Array Operations:"
  echo "-------------------"
  
  # Create array and sum it
  echo "Creating array of 5 squares: ", js.eval("JSON.stringify(createNumberArray(5))")
  echo "Sum of array: ", js.eval("sumArray([1, 2, 3, 4, 5])")
  echo "Sum mixed array: ", js.eval("sumArray([1, 'hello', 3, null, 5])")  # only numbers summed
  
  echo "\n4. Safe Division:"
  echo "----------------"
  echo "10 / 2 = ", js.eval("safeDivide(10, 2)")
  echo "15 / 3 = ", js.eval("safeDivide(15, 3)")
  
  try:
    discard js.eval("safeDivide(10, 0)")  # division by zero
  except JSException as e:
    echo "Division by zero error (expected): ", e.msg
  
  echo "\n5. Complex Configuration Object:"
  echo "-------------------------------"
  let configResult = js.eval("JSON.stringify(createConfig(), null, 2)")
  echo "Generated config:\n", configResult
  
  # Access nested properties
  echo "\nAccessing nested config values:"
  echo "Database host: ", js.eval("createConfig().database.host")
  echo "Database port: ", js.eval("createConfig().database.port") 
  echo "Server workers: ", js.eval("createConfig().server.workers")
  echo "First allowed IP: ", js.eval("createConfig().database.allowedIPs[0]")
  
  echo "\n6. JavaScript Integration Test:"
  echo "------------------------------"
  
  let integrationTest = """
    // Create users array
    var users = [
      {name: "alice", age: 30},
      {name: "bob", age: 17},
      {name: "charlie", age: 45}
    ];
    
    // Process all users
    var processed = users.map(processUser);
    
    // Create summary
    var adults = processed.filter(user => user.isAdult).length;
    var children = processed.filter(user => user.category === 'child').length;
    var teenagers = processed.filter(user => user.category === 'teenager').length;
    
    JSON.stringify({
      totalUsers: users.length,
      adults: adults,
      teenagers: teenagers, 
      children: children,
      processedUsers: processed
    }, null, 2);
  """
  
  echo js.eval(integrationTest)

when isMainModule:
  main()