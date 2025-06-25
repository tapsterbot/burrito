## Simple MicroPython Integration Example
##
## This demonstrates basic MicroPython usage with the Burrito wrapper

import "../../src/burrito/mpy"

echo "=== Simple MicroPython Integration Example ==="
echo ""

var py = newMicroPython()

try:
  echo "1. Basic calculations:"
  echo "   5 + 3 = ", py.eval("5 + 3")
  echo "   4 * 7 = ", py.eval("4 * 7")
  echo "   Manual factorial (6!): ", py.eval("print(1*2*3*4*5*6)")
  echo "   String greeting: ", py.eval("print('Hello from Python!')")
  echo ""
  
  echo "2. Working with variables:"
  echo py.eval("x = 10; y = 5; result = x + y; print('x =', x, ', y =', y, ', x + y =', result)")
  echo ""
  
  echo "3. Simple calculations:"
  echo py.eval("print('10 + 20 =', 10 + 20)")
  echo py.eval("print('6 * 7 =', 6 * 7)")
  echo py.eval("print('Hello, Developer!')")
  echo ""
  
  echo "4. List operations:"
  echo py.eval("""
# Create and manipulate lists
numbers = [1, 2, 3, 4, 5]
print('Numbers:', numbers)
print('Sum:', sum(numbers))
print('Doubled:', [x * 2 for x in numbers])
print('Evens:', [x for x in numbers if x % 2 == 0])
""")
  echo ""
  
  echo "5. Simple operations:"
  echo py.eval("print('Division result:', 20 // 2)")
  echo py.eval("print('String length:', len('Hello World'))")
  echo py.eval("print('List info: length =', len([3,1,4,1,5]))")

finally:
  py.close()

echo ""
echo "Integration completed successfully!"
echo ""
echo "This approach demonstrates:"
echo "- Basic MicroPython usage with Burrito wrapper"
echo "- Variable management and function definitions"
echo "- List comprehensions and built-in functions"
echo "- Error handling with try/except"
echo "- Consistent API with QuickJS patterns (newMicroPython, eval, close)"