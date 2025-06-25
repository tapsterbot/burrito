import ../../src/burrito/mpy

proc main() =
  echo "Basic Burrito Example"
  echo "===================="
  
  var py = newMicroPython()
  defer: py.close()
  
  # Simple math
  echo py.eval("print(2 + 3)")        # 5
  
  # String operations  
  echo py.eval("print('Hello ' + 'World!')")  # Hello World!
  
  # Built-in functions
  echo py.eval("print(2 ** 2)")           # 4

when isMainModule:
  main()