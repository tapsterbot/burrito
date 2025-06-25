## MicroPython Native Integration Example
##
## This example demonstrates the MicroPython wrapper API that matches
## QuickJS patterns for consistency

import "../../src/burrito/mpy"

echo "=== MicroPython Native Integration Example ==="
echo ""

# Create MicroPython instance
var py = newMicroPython()

try:
  echo "1. Basic API demonstration:"
  echo "   Math: ", py.eval("2 ** 8")
  echo "   Strings: ", py.eval("print('HELLO'.lower())")
  echo "   Lists: ", py.eval("print(list(range(3)))")
  echo ""
  
  echo "2. Function simulation (string-based approach):"
  # Since direct C API integration is complex, demonstrate the concept
  echo "   This shows how native functions could be integrated"
  echo "   (Full implementation requires complete MicroPython C API bindings)"
  echo ""
  
  echo "3. Mathematical operations:"
  echo "   Factorial: ", py.eval("print(1*2*3*4*5)")  # 5!
  echo "   Power: ", py.eval("print(2**10)")
  echo "   Division: ", py.eval("print(100//7)")
  echo ""
  
  echo "4. String operations:"
  echo "   Upper: ", py.eval("print('hello world'.upper())")
  echo "   Replace: ", py.eval("print('hello world'.replace('world', 'python'))")
  echo "   Split: ", py.eval("print('a,b,c'.split(','))")
  echo ""
  
  echo "5. List operations:"
  echo "   Comprehension: ", py.eval("print([x*2 for x in range(5)])")
  echo "   Filter: ", py.eval("print([x for x in range(10) if x % 2 == 0])")
  echo "   Sum: ", py.eval("print(sum([1,2,3,4,5]))")
  echo ""
  
  echo "6. Python built-ins:"
  echo "   Length: ", py.eval("print(len('Hello'))")
  echo "   Type: ", py.eval("print(type(42))")
  echo "   Sorted: ", py.eval("print(sorted([3,1,4,1,5]))")

finally:
  py.close()

echo ""
echo "Native integration demo completed successfully!"
echo ""
echo "Note: This demonstrates MicroPython capabilities."
echo "For true native function integration, you would need:"
echo "- Complete MicroPython C API bindings"
echo "- Function registration mechanisms"
echo "- Type conversion between Nim and Python objects"