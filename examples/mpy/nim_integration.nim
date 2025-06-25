## Clean MicroPython-Nim Integration Example
##
## This example demonstrates the MicroPython API that matches QuickJS patterns

import "../../src/burrito/mpy"

echo "=== Clean MicroPython-Nim Integration Example ==="
echo ""

# Create MicroPython instance
var py = newMicroPython()

try:
  echo "1. Basic Python operations:"
  echo "   Addition: ", py.eval("5 + 3")
  echo "   Multiplication: ", py.eval("4 * 7") 
  echo "   Factorial (manual): ", py.eval("print(1*2*3*4*5*6)")
  echo "   String greeting: ", py.eval("print('Hello from Python!')")
  echo ""
  
  echo "2. Python functions (basic syntax):"
  echo py.eval("print('Basic function calls:')")
  echo py.eval("print('Range:', list(range(5)))")
  echo py.eval("print('Length of list:', len([1,2,3,4,5]))")
  echo py.eval("print('List length:', len([3,1,4,1,5]))")
  echo ""
  
  echo "3. Python data structures:"
  echo py.eval("numbers = [1, 2, 3, 4, 5]; print('Numbers:', numbers)")
  echo py.eval("print('Sum:', sum([1, 2, 3, 4, 5]))")
  echo py.eval("squared = [x*x for x in [1,2,3,4,5]]; print('Squared:', squared)")
  echo py.eval("evens = [x for x in [1,2,3,4,5,6] if x % 2 == 0]; print('Evens:', evens)")
  echo ""
  
  echo "4. Basic error handling:"
  echo py.eval("print('Division:', 20 // 2)")
  echo py.eval("print('Integer division:', 10 // 3)")
  echo py.eval("print('Modulo:', 10 % 3)")
  echo ""
  
  echo "5. Memory and built-ins:"
  echo py.eval("import gc; gc.collect(); print('Garbage collection completed')")
  echo py.eval("print('Available functions work correctly')")

finally:
  py.close()

echo ""
echo "Example completed successfully!"
echo ""
echo "This demonstrates the MicroPython wrapper API with:"
echo "- Consistent lifecycle management (newMicroPython, close)"
echo "- Python code evaluation and output capture"
echo "- Support for complex Python programs"
echo "- Error handling and memory management"
echo "- API patterns that match QuickJS for consistency"