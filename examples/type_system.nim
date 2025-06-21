import ../src/burrito
import std/tables

# Custom Nim types for advanced marshaling
type
  Status = enum
    Active = "active"
    Inactive = "inactive"
    Pending = "pending"
  
  User = object
    id: int
    name: string
    email: string
    status: Status
    tags: seq[string]
  
  Company = object
    name: string
    users: seq[User]
    settings: Table[string, string]
    metadata: tuple[founded: int, employees: int]

# Advanced conversion functions
proc userToJS(ctx: ptr JSContext, user: User): JSValue =
  let obj = JS_NewObject(ctx)
  discard setProperty(ctx, obj, "id", nimIntToJS(ctx, user.id.int32))
  discard setProperty(ctx, obj, "name", nimStringToJS(ctx, user.name))
  discard setProperty(ctx, obj, "email", nimStringToJS(ctx, user.email))
  discard setProperty(ctx, obj, "status", nimStringToJS(ctx, $user.status))
  discard setProperty(ctx, obj, "tags", seqToJS(ctx, user.tags))
  return obj

proc companyToJS(ctx: ptr JSContext, company: Company): JSValue =
  let obj = JS_NewObject(ctx)
  discard setProperty(ctx, obj, "name", nimStringToJS(ctx, company.name))
  
  # Convert users array
  let usersArray = newArray(ctx)
  for i, user in company.users:
    discard setArrayElement(ctx, usersArray, i.uint32, userToJS(ctx, user))
  discard setProperty(ctx, obj, "users", usersArray)
  
  # Convert settings table
  discard setProperty(ctx, obj, "settings", tableToJS(ctx, company.settings))
  
  # Convert metadata tuple
  discard setProperty(ctx, obj, "metadata", nimTupleToJSArray(ctx, company.metadata))
  
  return obj

proc main() =
  echo "🔬 Burrito Type System Demo"
  echo "==============================="
  
  var js = newQuickJS()
  defer: js.close()
  
  echo "\n🔍 1. JavaScript Type Detection"
  echo "-------------------------------"
  
  # Create diverse JavaScript values
  discard js.eval("""
    var samples = {
      // Primitives
      text: "Hello World",
      integer: 42,
      decimal: 3.14159,
      flag: true,
      empty: null,
      missing: undefined,
      
      // Collections
      numbers: [1, 2, 3, 4, 5],
      mixed: ["hello", 42, true, null],
      
      // Objects
      simple: {name: "test", value: 123},
      nested: {
        user: {name: "Alice", age: 30},
        config: {debug: true, timeout: 5000}
      },
      
      // Function
      calculator: function(a, b) { return a + b; }
    };
  """)
  
  echo "🔍 Auto-detecting all JavaScript types:"
  let sampleProps = ["text", "integer", "decimal", "flag", "empty", "missing", 
                     "numbers", "mixed", "simple", "nested", "calculator"]
  
  echo "🔍 Type-specific access examples:"
  echo "  text     → string       = ", js.context.get("samples.text", string)
  echo "  integer  → int          = ", js.context.get("samples.integer", int)
  echo "  decimal  → float64      = ", js.context.get("samples.decimal", float64)
  echo "  flag     → bool         = ", js.context.get("samples.flag", bool)
  echo "  numbers  → array        = ", js.eval("JSON.stringify(samples.numbers)")
  echo "  simple   → object       = ", js.eval("JSON.stringify(samples.simple)")
  
  echo "\n📊 2. Type Conversion Examples"
  echo "------------------------------"
  
  # Test various conversion scenarios
  js.context["flexibleValue"] = "42"  # String that looks like a number
  
  echo "🔄 Same JavaScript value, different Nim types:"
  echo "  Original JS: \"42\" (string)"
  
  let asString: string = js.context.get("flexibleValue")
  let asInt: int = js.context.get("flexibleValue") 
  let asFloat: float64 = js.context.get("flexibleValue")
  # Note: bool conversion of "42" string would be true (non-empty)
  
  echo "  As string: \"", asString, "\" (", typeof(asString), ")"
  echo "  As int: ", asInt, " (", typeof(asInt), ")"
  echo "  As float: ", asFloat, " (", typeof(asFloat), ")"
  
  # Test type flexibility
  echo "  Type flexibility: same value, different interpretations"
  
  echo "\n🏗️  3. Nim to JavaScript Marshaling"
  echo "-----------------------------------"
  
  echo "📦 Basic type marshaling:"
  
  # Basic collections
  let fruits = @["apple", "banana", "cherry", "date"]
  let numbers = @[10, 20, 30, 40, 50]
  let mixed = @[1.1, 2.2, 3.3]
  
  withGlobalObject(js.context, global):
    discard setProperty(js.context, global, "fruits", seqToJS(js.context, fruits))
    discard setProperty(js.context, global, "numbers", seqToJS(js.context, numbers))
    discard setProperty(js.context, global, "decimals", seqToJS(js.context, mixed))
  
  echo "  Fruits: ", js.eval("JSON.stringify(fruits)")
  echo "  Numbers: ", js.eval("JSON.stringify(numbers)")
  echo "  Decimals: ", js.eval("JSON.stringify(decimals)")
  
  # Table marshaling
  let config = {
    "host": "localhost",
    "port": "8080", 
    "ssl": "true",
    "timeout": "30"
  }.toTable()
  
  let stats = {
    "users": 1500,
    "posts": 12000,
    "comments": 45000
  }.toTable()
  
  withGlobalObject(js.context, globalTables):
    discard setProperty(js.context, globalTables, "config", tableToJS(js.context, config))
    discard setProperty(js.context, globalTables, "stats", tableToJS(js.context, stats))
  
  echo "  Config: ", js.eval("JSON.stringify(config)")
  echo "  Stats: ", js.eval("JSON.stringify(stats)")
  
  # Tuple marshaling
  let point2D = (x: 100, y: 200)
  let nameValue = ("apiKey", "secret-123")
  let coordinates = (42, 24)
  
  withGlobalObject(js.context, globalTuples):
    discard setProperty(js.context, globalTuples, "point", nimTupleToJSArray(js.context, point2D))
    discard setProperty(js.context, globalTuples, "keyValue", nimTupleToJSArray(js.context, nameValue))
    discard setProperty(js.context, globalTuples, "coords", nimTupleToJSArray(js.context, coordinates))
  
  echo "  Point2D: ", js.eval("JSON.stringify(point)")
  echo "  KeyValue: ", js.eval("JSON.stringify(keyValue)")
  echo "  Coordinates: ", js.eval("JSON.stringify(coords)")
  
  echo "\n🏛️  4. Advanced Custom Type Marshaling"
  echo "--------------------------------------"
  
  # Create complex Nim data structures
  let users = @[
    User(id: 1, name: "Alice", email: "alice@company.com", 
         status: Active, tags: @["admin", "senior"]),
    User(id: 2, name: "Bob", email: "bob@company.com", 
         status: Pending, tags: @["developer", "junior"]),
    User(id: 3, name: "Charlie", email: "charlie@company.com", 
         status: Inactive, tags: @["designer"])
  ]
  
  let company = Company(
    name: "Tech Innovations Inc",
    users: users,
    settings: {"theme": "dark", "notifications": "enabled", "backup": "daily"}.toTable(),
    metadata: (founded: 2010, employees: 150)
  )
  
  echo "🏢 Complex object marshaling:"
  withGlobalObject(js.context, globalCompany):
    discard setProperty(js.context, globalCompany, "company", companyToJS(js.context, company))
  
  let companyJson = js.eval("JSON.stringify(company, null, 2)")
  echo "  Company object:"
  echo companyJson
  
  echo "\n🧪 5. JavaScript-Side Type Analysis"
  echo "-----------------------------------"
  
  # Analyze the marshaled data from JavaScript
  let analysisResult = js.eval("""
    var analysis = {
      company: {
        name: company.name,
        userCount: company.users.length,
        activeUsers: company.users.filter(u => u.status === 'active').length,
        totalTags: company.users.reduce((sum, u) => sum + u.tags.length, 0),
        settingsKeys: Object.keys(company.settings).length,
        foundedYear: company.metadata[0],
        employeeCount: company.metadata[1]
      },
      
      collections: {
        fruitsLength: fruits.length,
        numbersSum: numbers.reduce((a, b) => a + b, 0),
        decimalsAvg: decimals.reduce((a, b) => a + b, 0) / decimals.length,
        configEntries: Object.entries(config).length,
        pointDistance: Math.sqrt(point[0] * point[0] + point[1] * point[1])
      }
    };
    
    JSON.stringify(analysis, null, 2);
  """)
  
  echo "📈 JavaScript analysis of marshaled data:"
  echo analysisResult
  
  echo "\n🔄 6. Round-Trip Type Safety"
  echo "----------------------------"
  
  # Test round-trip conversion reliability
  echo "🔄 Testing round-trip conversions:"
  
  # Set various types and read them back
  let testData = [
    ("string", "Hello World"),
    ("integer", "42"),
    ("float", "3.14159"),
    ("boolean", "true")
  ]
  
  for (typeName, value) in testData:
    js.context["testValue"] = value
    
    # Read back with different type expectations
    let asString: string = js.context.get("testValue")
    let detected = js.context.detectType("testValue")
    
    echo "  ", typeName, ": set \"", value, "\" → got \"", asString, "\" (detected: ", detected.kind, ")"
  
  echo "\n🎯 7. Type-Safe Property Access"
  echo "-------------------------------"
  
  # Demonstrate safe property access patterns
  discard js.eval("""
    var safeData = {
      validString: "test",
      validNumber: 123,
      validBoolean: true,
      nullValue: null,
      undefinedValue: undefined,
      emptyString: "",
      zeroNumber: 0,
      falseBoolean: false
    };
  """)
  
  echo "🛡️  Safe property access with fallbacks:"
  let properties = ["validString", "validNumber", "validBoolean", 
                   "nullValue", "undefinedValue", "emptyString", 
                   "zeroNumber", "falseBoolean", "nonExistent"]
  
  echo "🛡️  Testing property access safety:"
  echo "  validString    → ", js.context.get("safeData.validString", string)
  echo "  validNumber    → ", js.context.get("safeData.validNumber", int)
  echo "  validBoolean   → ", js.context.get("safeData.validBoolean", bool)
  echo "  nullValue      → ", js.context.get("safeData.nullValue", string)
  echo "  emptyString    → \"", js.context.get("safeData.emptyString", string), "\""
  echo "  zeroNumber     → ", js.context.get("safeData.zeroNumber", int)
  
  echo "\n✅ Type System Summary"
  echo "======================"
  echo "🔄 Conversion: Flexible type conversion with safety"
  echo "📦 Marshaling: Complex Nim types → JavaScript objects"  
  echo "🛡️  Safety: Null/undefined handling and type checking"
  echo "🎯 Patterns: Idiomatic access with automatic memory management"
  echo "✨ Inference: Automatic type conversion from assignment context"
  echo ""
  echo "💎 Complete type interoperability between Nim and JavaScript!"

when isMainModule:
  main()