import ../src/burrito

proc main() =
  echo "Basic Burrito Example"
  echo "===================="
  
  var js = newQuickJS()
  defer: js.close()
  
  # Simple math
  echo js.eval("2 + 3")        # 5
  
  # String operations  
  echo js.eval("'Hello ' + 'World!'")  # Hello World!
  
  # Built-in functions
  echo js.eval("Math.sqrt(16)")        # 4

when isMainModule:
  main()