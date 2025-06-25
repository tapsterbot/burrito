## MicroPython EVERYTHING Configuration Features Demo
##
## This example demonstrates advanced features available in the 
## MICROPY_CONFIG_ROM_LEVEL_EVERYTHING configuration

import "../../src/burrito/mpy"

echo "=== MicroPython EVERYTHING Features Demo ==="
echo ""

var py = newMicroPython()

try:
  echo "1. Check available modules:"
  echo py.eval("print('Available modules:', dir(__builtins__)[:10], '...')")
  echo ""
  
  echo "2. Enhanced Built-in Functions:"
  echo "   Complex abs(): ", py.eval("abs(-3.14)")
  echo "   Advanced range(): ", py.eval("list(range(0, 10, 2))")
  echo "   Divmod function: ", py.eval("divmod(17, 5)")
  echo ""
  
  echo "3. Advanced String Methods:"
  echo "   String formatting: ", py.eval("print('Hello {}'.format('World'))")
  echo "   Advanced operations: ", py.eval("print(' '.join(['a', 'b', 'c']))")
  echo "   Case operations: ", py.eval("print('hello world'.title())")
  echo ""
  
  echo "4. Enhanced Data Structures:"
  echo "   List operations: ", py.eval("print([1,2,3] * 2)")
  echo "   Tuple operations: ", py.eval("print((1,2,3) + (4,5,6))")
  echo "   Dict comprehension: ", py.eval("print({x: x**2 for x in range(3)})")
  echo ""
  
  echo "5. Advanced Mathematics:"
  echo py.eval("print('Math operations:')")
  echo "   Power operations: ", py.eval("2 ** 10")
  echo "   Advanced division: ", py.eval("17 / 5")  # Should work with EVERYTHING
  echo "   Modulo: ", py.eval("17 % 5")
  echo ""
  
  echo "6. Enhanced Functions:"
  echo "   Lambda functions: ", py.eval("f = lambda x: x * 2; print(f(5))")
  echo "   Map function: ", py.eval("print(list(map(lambda x: x**2, [1,2,3,4])))")
  echo "   Filter function: ", py.eval("print(list(filter(lambda x: x % 2 == 0, range(10))))")
  echo ""
  
  echo "7. Advanced List Comprehensions:"
  echo py.eval("print([x**2 for x in range(5) if x % 2 == 0])")
  echo py.eval("print([[x*y for x in range(3)] for y in range(2)])")
  echo ""
  
  echo "8. Error Handling & Debugging:"
  echo py.eval("""
try:
    x = 1 / 0
except ZeroDivisionError as e:
    print('Caught error:', type(e).__name__)
finally:
    print('Error handling works!')
""")
  echo ""
  
  echo "9. Generator Expressions:"
  echo py.eval("g = (x**2 for x in range(5)); print(list(g))")
  echo ""
  
  echo "10. Enhanced Built-ins Available:"
  echo py.eval("print('Functions available:', 'all' in dir(__builtins__), 'any' in dir(__builtins__))")
  echo py.eval("print('all([True, True, True]):', all([True, True, True]))")
  echo py.eval("print('any([False, True, False]):', any([False, True, False]))")

finally:
  py.close()

echo ""
echo "EVERYTHING configuration provides:"
echo "- Maximum built-in function coverage"
echo "- Advanced Python language features"
echo "- Enhanced error handling and debugging"
echo "- Complete data structure operations"
echo "- Full expression and comprehension support"