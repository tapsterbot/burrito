import ../src/burrito

proc main() =
  echo "Idiomatic Nim Syntax Examples"
  echo "============================"
  
  var js = newQuickJS()
  defer: js.close()
  
  echo "\n1. Idiomatic Global Property Access:"
  echo "-----------------------------------"
  
  # Before: verbose syntax
  echo "❌ Old verbose way:"
  echo "   let name = getGlobalProperty(js.context, \"userName\", string)"
  
  # After: multiple idiomatic options!
  echo "✨ New idiomatic ways:"
  echo "   ctx.getString(\"userName\")        # Type-specific"
  echo "   ctx.get(\"userName\", string)     # Generic with type"
  echo "   ctx[\"userName\"] = \"Alice\"       # Assignment"
  
  # Set some global properties using idiomatic assignment syntax
  js.context["userName"] = "Alice"
  js.context["userAge"] = 30
  js.context["userScore"] = 95.5
  js.context["isActive"] = true
  
  # Get them back using idiomatic methods
  let name = js.context.getString("userName")
  let age = js.context.getInt("userAge") 
  let score = js.context.getFloat("userScore")
  let active = js.context.getBool("isActive")
  
  # Or using generic syntax
  let name2 = js.context.get("userName", string)
  let age2 = js.context.get("userAge", int)
  
  echo "User name: ", name, " (also: ", name2, ")"
  echo "User age: ", age, " (also: ", age2, ")"
  echo "User score: ", score
  echo "Is active: ", active
  
  echo "\n2. Working with JavaScript Objects:"
  echo "----------------------------------"
  
  # Create JavaScript objects and arrays
  discard js.eval("var person = {name: 'Bob', age: 25};")
  discard js.eval("var numbers = [10, 20, 30, 40, 50];")
  
  # Access them using the auto-memory management helpers
  withGlobalObject(js.context, global):
    let personObj = getProperty(js.context, global, "person")
    defer: JS_FreeValue(js.context, personObj)
    
    let personName = getPropertyValue(js.context, personObj, "name", string)
    let personAge = getPropertyValue(js.context, personObj, "age", int)
    
    echo "Person name: ", personName
    echo "Person age: ", personAge
    
    let numbersArray = getProperty(js.context, global, "numbers")
    defer: JS_FreeValue(js.context, numbersArray)
    
    let first = getArrayElementValue(js.context, numbersArray, 0'u32, int)
    let second = getArrayElementValue(js.context, numbersArray, 1'u32, int)
    
    echo "First number: ", first
    echo "Second number: ", second
  
  echo "\n3. Setting Values Idiomatically:"
  echo "-------------------------------"
  
  # Setting values is clean and simple
  js.context.set("newValue", "Hello World")
  js.context["anotherValue"] = 123
  
  echo "New value: ", js.context.getString("newValue")
  echo "Another value: ", js.context.getInt("anotherValue")
  
  echo "\n4. Method Call Syntax Magic:"
  echo "---------------------------"
  
  # Nim's method call syntax makes it even more awesome
  js.context["magic"] = "This is magic!"
  js.context["number"] = 42
  
  # Type-specific methods are clean and clear
  let magicText = js.context.getString("magic")
  let magicNumber = js.context.getInt("number")
  
  echo "Magic text: ", magicText
  echo "Magic number: ", magicNumber
  
  # Or use the generic version
  let magicText2 = js.context.get("magic", string)
  let magicNumber2 = js.context.get("number", int)
  
  echo "Magic text (generic): ", magicText2
  echo "Magic number (generic): ", magicNumber2
  
  echo "\n5. 🎉 ULTIMATE AWESOME: True Type Inference!"
  echo "--------------------------------------------"
  echo "❌ Old way:"
  echo "   let name = getGlobalProperty(js.context, \"userName\", string)"
  echo "   let age = getGlobalProperty(js.context, \"userAge\", int)"
  echo ""
  echo "✨ New ULTIMATE way (automatic type inference!):"
  echo "   let name: string = js.context.get(\"userName\")   # auto-converts!"
  echo "   let age: int = js.context.get(\"userAge\")        # auto-converts!"
  echo ""
  
  # Demonstrate the ultimate syntax
  let autoName: string = js.context.get("userName")
  let autoAge: int = js.context.get("userAge") 
  let autoScore: float64 = js.context.get("userScore")
  let autoActive: bool = js.context.get("isActive")
  
  echo "✨ Results with automatic type inference:"
  echo "Name (auto string): ", autoName
  echo "Age (auto int): ", autoAge  
  echo "Score (auto float): ", autoScore
  echo "Active (auto bool): ", autoActive
  
  # Show it even works without type annotations (defaults to string)
  echo "\n💫 Even works without type annotations (defaults to string):"
  echo "Name: ", js.context.get("userName")
  echo "Age as string: ", js.context.get("userAge")
  
  echo "\n✨ Idiomatic Nim syntax makes JavaScript integration beautiful!"
  echo "   From: getGlobalProperty(ctx, \"name\", string)"
  echo "   To:   ctx.getString(\"name\")           # Type-specific"
  echo "   Or:   ctx.get(\"name\", string)        # Generic"
  echo "   Now:  let name: string = ctx.get(\"name\")  # AUTO TYPE INFERENCE! 🎉"
  echo "   Set:  ctx[\"name\"] = \"value\"         # Assignment"

when isMainModule:
  main()