## Dual Engines Example
##
## This example demonstrates using both QuickJS and MicroPython
## in the same Nim application, showing how they can work together
## or independently.

import "../../src/burrito/qjs"
import "../../src/burrito/mpy"

echo "=== Burrito Dual Engines Example ==="
echo "Running both JavaScript and Python in the same application!"
echo ""

# Create both engines
var js = newQuickJS()
var py = newMicroPython()

try:
  echo "1. JavaScript computation:"
  let jsResult = js.eval("3 + 4 * 5")
  echo "   JS: 3 + 4 * 5 = ", jsResult

  echo "2. Python computation:"
  discard py.eval("result = 3 + 4 * 5")
  echo py.eval("print('Python: 3 + 4 * 5 = ' + str(result))")
  echo ""

  echo "3. Complex JavaScript:"
  let jsComplex = js.eval("""
    const fibonacci = (n) => {
      if (n <= 1) return n;
      return fibonacci(n - 1) + fibonacci(n - 2);
    };
    fibonacci(10);
  """)
  echo "   JS Fibonacci(10): ", jsComplex

  echo "4. Complex Python:"
  echo py.eval("""
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

result = fibonacci(10)
print('Python Fibonacci(10): ' + str(result))
  """)
  echo ""

  echo "5. Data processing in both languages:"

  # JavaScript array processing
  let jsArray = js.eval("""
    const data = [1, 2, 3, 4, 5];
    const doubled = data.map(x => x * 2);
    const sum = doubled.reduce((a, b) => a + b, 0);
    sum;
  """)
  echo "   JS array processing result: ", jsArray

  # Python list processing
  echo py.eval("""
data = [1, 2, 3, 4, 5]
doubled = [x * 2 for x in data]
total = sum(doubled)
print('Python list processing result: ' + str(total))
  """)
  echo ""

  echo "6. String manipulation comparison:"

  # JavaScript string ops
  let jsString = js.eval("""
    const text = "Hello World";
    text.split(' ').reverse().join(' ').toUpperCase();
  """)
  echo "   JS string result: ", jsString

  # Python string ops
  echo py.eval("""
text = "Hello World"
words = text.split(' ')
words.reverse()
result = ' '.join(words).upper()
print('Python string result: ' + result)
  """)
  echo ""

  echo "7. Mathematical operations:"

  # JavaScript math
  let jsMath = js.eval("""
    Math.sqrt(Math.pow(3, 2) + Math.pow(4, 2));
  """)
  echo "   JS: sqrt(3² + 4²) = ", jsMath

  # Python math
  echo py.eval("""
# Simple calculation - we know sqrt(25) = 5
a_squared = 3 * 3
b_squared = 4 * 4
sum_squares = a_squared + b_squared
print('Python: sqrt(3² + 4²) = 5 (calculated: ' + str(sum_squares) + '^0.5)')
  """)

finally:
  js.close()
  py.close()

echo ""
echo "Dual engines example completed!"
echo "Both JavaScript and Python executed successfully in the same application."
