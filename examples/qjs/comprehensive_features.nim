import ../../src/burrito/qjs
import std/[tables, strutils]

# Custom Nim types for marshaling demonstration
type
  Person = object
    name: string
    age: int
    email: string

proc personToJS(ctx: ptr JSContext, person: Person): JSValue =
  let obj = JS_NewObject(ctx)
  discard setProperty(ctx, obj, "name", nimStringToJS(ctx, person.name))
  discard setProperty(ctx, obj, "age", nimIntToJS(ctx, person.age.int32))
  discard setProperty(ctx, obj, "email", nimStringToJS(ctx, person.email))
  return obj

# Advanced Nim function for JavaScript integration
proc processUser(ctx: ptr JSContext, userObj: JSValue): JSValue =
  if not isObject(ctx, userObj):
    return JS_ThrowTypeError(ctx, "Expected an object")
  
  # Extract data using auto-memory management
  let name = getPropertyValue(ctx, userObj, "name", string)
  let age = getPropertyValue(ctx, userObj, "age", int32)
  
  # Create enhanced result
  let resultObj = JS_NewObject(ctx)
  discard setProperty(ctx, resultObj, "processedName", nimStringToJS(ctx, name.toUpper()))
  discard setProperty(ctx, resultObj, "isAdult", nimBoolToJS(ctx, age >= 18))
  discard setProperty(ctx, resultObj, "category", nimStringToJS(ctx, 
    if age < 13: "child" elif age < 20: "teenager" else: "adult"))
  discard setProperty(ctx, resultObj, "originalAge", nimIntToJS(ctx, age))
  
  return resultObj

proc main() =
  echo "🌯 Burrito Comprehensive Features Demo"
  echo "====================================="
  
  var js = newQuickJS()
  defer: js.close()
  
  echo "\n📊 1. HIGH-LEVEL: Idiomatic Syntax & Type Inference"
  echo "---------------------------------------------------"
  
  # Beautiful idiomatic property access
  js.context["userName"] = "Alice"
  js.context["userAge"] = 25
  js.context["userScore"] = 98.5
  js.context["isActive"] = true
  
  # Type inference magic - no explicit types needed!
  let name: string = js.context.get("userName")   # auto-converts to string
  let age: int = js.context.get("userAge")        # auto-converts to int
  let score: float64 = js.context.get("userScore") # auto-converts to float
  let active: bool = js.context.get("isActive")   # auto-converts to bool
  
  echo "✨ Auto-inferred values:"
  echo "  Name: ", name, " (", typeof(name), ")"
  echo "  Age: ", age, " (", typeof(age), ")"
  echo "  Score: ", score, " (", typeof(score), ")"
  echo "  Active: ", active, " (", typeof(active), ")"
  
  echo "\n🔍 2. MID-LEVEL: Type Detection & Marshaling"
  echo "--------------------------------------------"
  
  # Set up various JavaScript values
  discard js.eval("""
    var mixedData = {
      text: "Hello World",
      number: 42,
      decimal: 3.14159,
      flag: true,
      nothing: null,
      missing: undefined,
      list: [1, 2, 3, 4, 5],
      config: {host: "localhost", port: 8080}
    };
  """)
  
  # Demonstrate type-specific access instead
  echo "🔍 Type-specific property access:"
  echo "  text: ", js.context.get("mixedData.text", string)
  echo "  number: ", js.context.get("mixedData.number", int)
  echo "  decimal: ", js.context.get("mixedData.decimal", float64)
  echo "  flag: ", js.context.get("mixedData.flag", bool)
  echo "  list: ", js.eval("JSON.stringify(mixedData.list)")
  echo "  config: ", js.eval("JSON.stringify(mixedData.config)")
  
  echo "\n🔄 3. MID-LEVEL: Advanced Type Marshaling"
  echo "-----------------------------------------"
  
  # Nim data structures to JavaScript
  let fruits = @["apple", "banana", "cherry"]
  let settings = {"timeout": "30", "retries": "3", "debug": "true"}.toTable()
  let coordinates = (x: 100, y: 200)
  let person = Person(name: "Bob Smith", age: 30, email: "bob@example.com")
  
  # Marshal to JavaScript with auto-memory management
  withGlobalObject(js.context, global):
    discard setProperty(js.context, global, "fruits", seqToJS(js.context, fruits))
    discard setProperty(js.context, global, "settings", tableToJS(js.context, settings))
    discard setProperty(js.context, global, "coordinates", nimTupleToJSArray(js.context, coordinates))
    discard setProperty(js.context, global, "person", personToJS(js.context, person))
  
  echo "📦 Marshaled Nim data to JavaScript:"
  echo "  Fruits: ", js.eval("JSON.stringify(fruits)")
  echo "  Settings: ", js.eval("JSON.stringify(settings)")
  echo "  Coordinates: ", js.eval("JSON.stringify(coordinates)")
  echo "  Person: ", js.eval("JSON.stringify(person)")
  
  echo "\n⚙️  4. LOW-LEVEL: Advanced Function Integration"
  echo "----------------------------------------------"
  
  # Register advanced Nim function
  js.registerFunction("processUser", processUser)
  
  # Test with JavaScript integration
  let jsResult = js.eval("""
    var users = [
      {name: "alice", age: 16},
      {name: "bob", age: 25},
      {name: "charlie", age: 45}
    ];
    
    var processed = users.map(processUser);
    JSON.stringify({
      totalUsers: users.length,
      adults: processed.filter(u => u.isAdult).length,
      processed: processed
    }, null, 2);
  """)
  
  echo "🔧 Advanced function processing result:"
  echo jsResult
  
  echo "\n💾 5. LOW-LEVEL: Manual Memory Management"
  echo "----------------------------------------"
  
  # Demonstrate manual control when needed
  withGlobalObject(js.context, globalObjManual):
    echo "🔧 Manual object manipulation:"
    
    # Create object manually
    let manualObj = JS_NewObject(js.context)
    discard setProperty(js.context, manualObj, "type", nimStringToJS(js.context, "manual"))
    discard setProperty(js.context, manualObj, "timestamp", nimIntToJS(js.context, 1234567890))
    
    # Create array manually
    let manualArray = newArray(js.context)
    for i in 0..<3:
      discard setArrayElement(js.context, manualArray, i.uint32, nimStringToJS(js.context, "item" & $i))
    
    discard setProperty(js.context, manualObj, "items", manualArray)
    discard setProperty(js.context, globalObjManual, "manualObject", manualObj)
    
    echo "  Created object: ", js.eval("JSON.stringify(manualObject)")
    echo "  Array length: ", getArrayLength(js.context, manualArray)
    
    # Manual property access with explicit memory management
    withProperty(js.context, manualObj, "type", typeVal):
      echo "  Type field: ", toNimString(js.context, typeVal)
  
  echo "\n🎉 6. VALIDATION: Everything Working Together"
  echo "--------------------------------------------"
  
  # Complex integration test
  let integrationTest = js.eval("""
    // Use all the data we've created
    var summary = {
      user: {
        name: userName,
        age: userAge,
        score: userScore,
        active: isActive
      },
      data: {
        fruitsCount: fruits.length,
        settingsKeys: Object.keys(settings).length,
        personAge: person.age,
        coordinatesSum: coordinates[0] + coordinates[1]
      },
      processed: {
        totalProcessed: processed.length,
        adultsCount: processed.filter(u => u.isAdult).length
      },
      manual: {
        type: manualObject.type,
        itemsCount: manualObject.items.length
      }
    };
    
    JSON.stringify(summary, null, 2);
  """)
  
  echo "🔬 Complete integration test result:"
  echo integrationTest
  
  echo "\n✅ All Burrito features demonstrated successfully!"
  echo "From high-level idiomatic syntax to low-level manual control."

when isMainModule:
  main()