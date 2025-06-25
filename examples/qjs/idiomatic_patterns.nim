import ../../src/burrito/qjs

proc main() =
  echo "✨ Burrito Idiomatic Nim Patterns"
  echo "================================="
  
  var js = newQuickJS()
  defer: js.close()
  
  echo "\n🎯 1. Type Inference Magic"
  echo "-------------------------"
  
  # Set up test data
  js.context["message"] = "Hello Nim!"
  js.context["count"] = 42
  js.context["pi"] = 3.14159
  js.context["enabled"] = true
  
  echo "❌ Old verbose way:"
  echo """   let msg = getGlobalProperty(js.context, "message", string)"""
  echo """   let num = getGlobalProperty(js.context, "count", int)"""
  echo ""
  
  echo "✨ New beautiful way (automatic type inference):"
  echo """   let msg: string = js.context.get("message")   # auto-converts!"""
  echo """   let num: int = js.context.get("count")        # auto-converts!"""
  echo ""
  
  # Demonstrate the magic
  let msg: string = js.context.get("message")     # Type inferred from annotation!
  let num: int = js.context.get("count")          # Type inferred from annotation!
  let decimal: float64 = js.context.get("pi")     # Type inferred from annotation!
  let flag: bool = js.context.get("enabled")      # Type inferred from annotation!
  
  echo "📝 Results:"
  echo "  Message: \"", msg, "\" (", typeof(msg), ")"
  echo "  Count: ", num, " (", typeof(num), ")"
  echo "  Pi: ", decimal, " (", typeof(decimal), ")"
  echo "  Enabled: ", flag, " (", typeof(flag), ")"
  
  echo "\n🚀 2. Ultra-Concise Property Access"
  echo "-----------------------------------"
  
  echo "🔥 Even shorter with type-specific methods:"
  echo """   js.context.getString("message")   # Direct string access"""
  echo """   js.context.getInt("count")        # Direct int access"""
  echo """   js.context.getFloat("pi")         # Direct float access"""
  echo """   js.context.getBool("enabled")     # Direct bool access"""
  echo ""
  
  echo "📝 Results:"
  echo "  getString: \"", js.context.getString("message"), "\""
  echo "  getInt: ", js.context.getInt("count")
  echo "  getFloat: ", js.context.getFloat("pi")
  echo "  getBool: ", js.context.getBool("enabled")
  
  echo "\n💎 3. Assignment Syntax Beauty"
  echo "------------------------------"
  
  echo "🎨 Nim-style assignment operators:"
  echo """   js.context["name"] = "Alice"      # Beautiful assignment"""
  echo """   js.context.set("age", 25)         # Alternative syntax"""
  echo ""
  
  # Demonstrate assignment patterns
  js.context["name"] = "Alice"
  js.context["age"] = 25
  js.context.set("location", "San Francisco")
  js.context["active"] = true
  
  echo "📝 Set values:"
  echo "  Name: ", js.context.getString("name")
  echo "  Age: ", js.context.getInt("age")
  echo "  Location: ", js.context.getString("location")
  echo "  Active: ", js.context.getBool("active")
  
  echo "\n🔄 4. Automatic Memory Management"
  echo "---------------------------------"
  
  # Create JavaScript objects and arrays for demonstration
  discard js.eval("""
    var user = {
      profile: {name: "Bob", age: 30},
      preferences: {theme: "dark", notifications: true},
      history: ["login", "browse", "purchase"]
    };
  """)
  
  echo "🧠 Smart memory-managed access patterns:"
  echo """   withGlobalObject(js.context, global):"""
  echo """     # Automatic cleanup of global object"""
  echo """   withProperty(js.context, obj, "key", prop):"""
  echo """     # Automatic cleanup of property"""
  echo ""
  
  # Demonstrate auto-memory patterns
  withGlobalObject(js.context, global):
    echo "✅ Accessing nested data with auto-cleanup:"
    
    withProperty(js.context, global, "user", userObj):
      let profileName = getPropertyValue(js.context, userObj, "profile", string)
      echo "  Profile (as string): ", profileName
      
      withProperty(js.context, userObj, "profile", profileObj):
        let name = getPropertyValue(js.context, profileObj, "name", string)
        let age = getPropertyValue(js.context, profileObj, "age", int)
        echo "  Profile name: ", name
        echo "  Profile age: ", age
      
      withProperty(js.context, userObj, "history", historyArray):
        let historyLength = getArrayLength(js.context, historyArray)
        echo "  History items: ", historyLength
        
        for i in 0..<historyLength:
          let item = getArrayElementValue(js.context, historyArray, i.uint32, string)
          echo "    [", i, "] ", item
  
  echo "\n🎭 5. Pattern Comparison Examples"
  echo "--------------------------------"
  
  # Set up comparison data
  js.context["demo"] = "comparison"
  
  echo "📊 Same result, different patterns:"
  echo ""
  
  echo "🔧 Explicit type parameter:"
  let explicit = js.context.get("demo", string)
  echo "  get(\"demo\", string) → \"", explicit, "\""
  
  echo "✨ Type inference:"
  let inferred: string = js.context.get("demo")
  echo "  let x: string = get(\"demo\") → \"", inferred, "\""
  
  echo "🎯 Type-specific method:"
  let specific = js.context.getString("demo")
  echo "  getString(\"demo\") → \"", specific, "\""
  
  echo "🔍 Auto-detection:"
  let detected = js.context.detectType("demo")
  echo "  detectType(\"demo\") → ", detected.kind, ": \"", detected, "\""
  
  echo "⚡ All produce the same result with different levels of explicitness!"
  
  echo "\n🌟 6. Real-World Usage Pattern"
  echo "------------------------------"
  
  # Simulate a real configuration scenario
  discard js.eval("""
    var appConfig = {
      server: {
        host: "localhost",
        port: 3000,
        ssl: false
      },
      database: {
        url: "postgres://localhost:5432/myapp",
        poolSize: 10,
        timeout: 30000
      },
      features: ["auth", "logging", "metrics"],
      debug: true
    };
  """)
  
  echo "🏗️  Real-world config access pattern:"
  echo ""
  
  # Beautiful idiomatic access to nested config
  withGlobalObject(js.context, globalConfig):
    withProperty(js.context, globalConfig, "appConfig", config):
      # Server config
      let serverHost = getPropertyValue(js.context, config, "server", string)
      echo "🖥️  Server config: ", serverHost
      
      withProperty(js.context, config, "server", server):
        let host: string = js.context.getString("server.host")  # Alternative syntax
        let port: int = getPropertyValue(js.context, server, "port", int)
        let ssl: bool = getPropertyValue(js.context, server, "ssl", bool)
        
        echo "  Host: ", host
        echo "  Port: ", port
        echo "  SSL: ", ssl
      
      # Features array
      withProperty(js.context, config, "features", features):
        let featureCount = getArrayLength(js.context, features)
        echo "🎛️  Features (", featureCount, "):"
        for i in 0..<featureCount:
          let feature = getArrayElementValue(js.context, features, i.uint32, string)
          echo "  - ", feature
      
      # Simple values with type inference
      let debugMode: bool = js.context.get("appConfig.debug")
      echo "🐛 Debug mode: ", debugMode
  
  echo "\n🎉 Idiomatic Patterns Summary"
  echo "=============================="
  echo "✅ Type inference: let x: T = ctx.get(\"prop\")"
  echo "✅ Type-specific: ctx.getString(\"prop\")"
  echo "✅ Assignment: ctx[\"prop\"] = value"
  echo "✅ Auto-memory: withGlobalObject, withProperty"
  echo "✅ Detection: ctx.detectType(\"prop\")"
  echo ""
  echo "💎 Beautiful, safe, and memory-efficient JavaScript integration!"

when isMainModule:
  main()