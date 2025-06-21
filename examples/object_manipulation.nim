import ../src/burrito

proc main() =
  echo "Object and Array Manipulation Example"
  echo "===================================="
  
  var js = newQuickJS()
  defer: js.close()
  
  # Test object creation and manipulation from Nim
  echo "\n1. Object Creation and Property Access:"
  echo "--------------------------------------"
  
  # Create a JavaScript object and set properties
  let jsCode1 = """
    var person = {
      name: "Alice",
      age: 30,
      city: "New York"
    };
    person;
  """
  
  let personObj = js.eval(jsCode1)
  echo "Created object: ", personObj
  
  # Read and modify properties from Nim using idiomatic syntax
  withGlobalObject(js.context, globalObj):
    let person = getProperty(js.context, globalObj, "person")
    defer: JS_FreeValue(js.context, person)
    
    let name = getPropertyValue(js.context, person, "name", string)
    let age = getPropertyValue(js.context, person, "age", int)
    
    echo "Name from Nim: ", name
    echo "Age from Nim: ", age
    
    # Set new property from Nim
    let emailVal = nimStringToJS(js.context, "alice@example.com")
    discard setProperty(js.context, person, "email", emailVal)
  
  echo "After adding email: ", js.eval("JSON.stringify(person)")
  
  echo "\n2. Array Creation and Manipulation:"
  echo "-----------------------------------"
  
  # Create array from Nim
  let arr = newArray(js.context)
  
  # Add elements to array (these create new JSValues that get owned by the array)
  let apple = nimStringToJS(js.context, "apple")
  let banana = nimStringToJS(js.context, "banana") 
  let cherry = nimStringToJS(js.context, "cherry")
  
  discard setArrayElement(js.context, arr, 0, apple)
  discard setArrayElement(js.context, arr, 1, banana)
  discard setArrayElement(js.context, arr, 2, cherry)
  
  # Set array as global variable (this transfers ownership)
  withGlobalObject(js.context, globalObjForFruits):
    discard setProperty(js.context, globalObjForFruits, "fruits", arr)
  
  echo "Array created from Nim: ", js.eval("JSON.stringify(fruits)")
  
  # Get array length using idiomatic syntax
  withGlobalObject(js.context, globalObjForArray):
    let fruitsArray = getProperty(js.context, globalObjForArray, "fruits")
    defer: JS_FreeValue(js.context, fruitsArray)
    echo "Array length: ", getArrayLength(js.context, fruitsArray)
    
    # Read array elements using auto-memory management
    for i in 0..<getArrayLength(js.context, fruitsArray):
      let element = getArrayElementValue(js.context, fruitsArray, i.uint32, string)
      echo "Element ", i, ": ", element

proc typeCheckingDemo() =
  echo "\n3. Type Checking from Nim:"
  echo "--------------------------"
  
  var js = newQuickJS()
  defer: js.close()
  
  # Create various JavaScript values
  discard js.eval("""
    var str = "hello";
    var num = 42;
    var bool = true;
    var obj = {key: "value"};
    var arr = [1, 2, 3];
    var func = function() { return "test"; };
    var undef = undefined;
    var nul = null;
  """)
  
  let values = [
    ("str", "string"),
    ("num", "number"), 
    ("bool", "boolean"),
    ("obj", "object"),
    ("arr", "array"),
    ("func", "function"),
    ("undef", "undefined"),
    ("nul", "null")
  ]
  
  withGlobalObject(js.context, globalObj):
    for (varName, expectedType) in values:
      withProperty(js.context, globalObj, varName, val):
        var actualType = "unknown"
        if isString(js.context, val): actualType = "string"
        elif isNumber(js.context, val): actualType = "number"
        elif isBool(js.context, val): actualType = "boolean"
        elif isArray(js.context, val): actualType = "array"
        elif isFunction(js.context, val): actualType = "function"
        elif isUndefined(js.context, val): actualType = "undefined"
        elif isNull(js.context, val): actualType = "null"
        elif isObject(js.context, val): actualType = "object"
        
        echo varName, " is ", actualType, " (expected: ", expectedType, ")"

proc complexObjectDemo() =
  echo "\n4. Complex Object Manipulation:"
  echo "-------------------------------"
  
  var js = newQuickJS()
  defer: js.close()
  
  # Create a complex nested structure from Nim
  withGlobalObject(js.context, globalObj):
    # Create main object
    let config = JS_NewObject(js.context)
    
    # Create nested objects
    let database = JS_NewObject(js.context)
    let server = JS_NewObject(js.context)
    
    # Set database config (setProperty takes ownership of values)
    discard setProperty(js.context, database, "host", nimStringToJS(js.context, "localhost"))
    discard setProperty(js.context, database, "port", nimIntToJS(js.context, 5432))
    discard setProperty(js.context, database, "name", nimStringToJS(js.context, "myapp"))
    
    # Set server config
    discard setProperty(js.context, server, "host", nimStringToJS(js.context, "0.0.0.0"))
    discard setProperty(js.context, server, "port", nimIntToJS(js.context, 8080))
    discard setProperty(js.context, server, "ssl", nimBoolToJS(js.context, true))
    
    # Create features array
    let features = newArray(js.context)
    discard setArrayElement(js.context, features, 0, nimStringToJS(js.context, "authentication"))
    discard setArrayElement(js.context, features, 1, nimStringToJS(js.context, "logging"))
    discard setArrayElement(js.context, features, 2, nimStringToJS(js.context, "caching"))
    
    # Assemble main config (all these transfer ownership)
    discard setProperty(js.context, config, "database", database)
    discard setProperty(js.context, config, "server", server)
    discard setProperty(js.context, config, "features", features)
    discard setProperty(js.context, config, "version", nimStringToJS(js.context, "1.0.0"))
    
    # Set as global (this transfers ownership of config)
    discard setProperty(js.context, globalObj, "config", config)
  
  echo "Complex config created from Nim:"
  echo js.eval("JSON.stringify(config, null, 2)")
  
  # Access nested values from JavaScript
  echo "\nAccessing nested values:"
  echo "Database host: ", js.eval("config.database.host")
  echo "Server port: ", js.eval("config.server.port")
  echo "Feature count: ", js.eval("config.features.length")
  echo "First feature: ", js.eval("config.features[0]")

when isMainModule:
  main()
  typeCheckingDemo()
  complexObjectDemo()