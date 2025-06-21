import ../src/burrito

proc main() =
  echo "Auto Memory Management Examples"
  echo "=============================="
  
  var js = newQuickJS()
  defer: js.close()
  
  echo "\n1. Auto-freeing property access:"
  echo "-------------------------------"
  
  # Test setGlobalProperty and getGlobalProperty
  discard setGlobalProperty(js.context, "userName", "Alice")
  discard setGlobalProperty(js.context, "userAge", 30)
  discard setGlobalProperty(js.context, "userScore", 95.5)
  discard setGlobalProperty(js.context, "isActive", true)
  
  echo "Set global properties via auto-memory functions"
  echo "User name: ", getGlobalProperty(js.context, "userName", string)
  echo "User age: ", getGlobalProperty(js.context, "userAge", int)
  echo "User score: ", getGlobalProperty(js.context, "userScore", float64)
  echo "Is active: ", getGlobalProperty(js.context, "isActive", bool)
  
  echo "\n2. Auto-freeing array access:"
  echo "-----------------------------"
  
  # Create an array in JavaScript
  discard js.eval("var numbers = [10, 20, 30, 40, 50];")
  
  # Use collectArray to get all elements with auto memory management
  withGlobalObject(js.context, global1):
    withProperty(js.context, global1, "numbers", numbersArray):
      let collected = collectArray(js.context, numbersArray, int)
      echo "Collected array: ", collected
      
      # Use iterateArray with callback
      echo "Iterating with callback:"
      iterateArray(js.context, numbersArray) do (ctx: ptr JSContext, index: uint32, element: JSValueConst):
        let value = toNimInt(ctx, element)
        echo "  Index ", index, ": ", value
  
  echo "\n3. Auto-freeing property value access:"
  echo "-------------------------------------"
  
  # Create an object in JavaScript
  discard js.eval("var person = {name: 'Bob', age: 25, email: 'bob@example.com'};")
  
  # Use getPropertyValue for direct value access with auto memory management
  withGlobalObject(js.context, global2):
    withProperty(js.context, global2, "person", personObj):
      let name = getPropertyValue(js.context, personObj, "name", string)
      let age = getPropertyValue(js.context, personObj, "age", int)
      let email = getPropertyValue(js.context, personObj, "email", string)
      
      echo "Person name: ", name
      echo "Person age: ", age
      echo "Person email: ", email
  
  echo "\n4. Auto-freeing array element access:"
  echo "------------------------------------"
  
  # Create a mixed array
  discard js.eval("var mixed = ['hello', 42, 3.14, true];")
  
  withGlobalObject(js.context, global3):
    withProperty(js.context, global3, "mixed", mixedArray):
      let text = getArrayElementValue(js.context, mixedArray, 0, string)
      let number = getArrayElementValue(js.context, mixedArray, 1, int)
      let float_val = getArrayElementValue(js.context, mixedArray, 2, float64)
      let bool_val = getArrayElementValue(js.context, mixedArray, 3, bool)
      
      echo "Element 0 (string): ", text
      echo "Element 1 (int): ", number
      echo "Element 2 (float): ", float_val
      echo "Element 3 (bool): ", bool_val
  
  echo "\n✨ All auto memory management examples completed successfully!"
  echo "   No manual JS_FreeValue calls needed!"

when isMainModule:
  main()