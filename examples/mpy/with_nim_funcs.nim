## MicroPython with Nim Functions Example
##
## This example shows how to expose Nim functions to MicroPython
## using a simpler approach that doesn't require deep C API knowledge

import "../../src/burrito/mpy"
import strformat
import strutils

# Global variables to share data between Nim and Python
var nimSharedData: seq[int] = @[]
var nimCounter = 0

# Helper to inject Python code that can call back to Nim
proc injectNimBridge(py: MicroPython) =
  # Create Python functions that interact with Nim through shared state
  discard py.eval("""
# Python functions that will be filled by Nim
nim_results = {}

def nim_add(a, b):
    # Store request in a format Nim can read
    nim_results['pending'] = ('add', a, b)
    # Trigger Nim processing (this is a placeholder)
    # In real implementation, we'd need a callback mechanism
    return nim_results.get('add_result', 0)

def nim_greet(name):
    nim_results['pending'] = ('greet', name)
    return nim_results.get('greet_result', 'Hello')

def nim_factorial(n):
    nim_results['pending'] = ('factorial', n)
    return nim_results.get('factorial_result', 1)
""")

# Process Python requests from Nim side
proc processNimRequest(py: MicroPython, operation: string, args: seq[string]): string =
  case operation
  of "add":
    if args.len >= 2:
      let a = parseInt(args[0])
      let b = parseInt(args[1])
      let sum = a + b
      return $sum
  of "greet":
    if args.len >= 1:
      return fmt"Hello from Nim, {args[0]}!"
  of "factorial":
    if args.len >= 1:
      let n = parseInt(args[0])
      var fact = 1
      for i in 1..n:
        fact *= i
      return $fact
  of "get_counter":
    nimCounter += 1
    return $nimCounter
  of "store_data":
    if args.len >= 1:
      nimSharedData.add(parseInt(args[0]))
      return "ok"
  of "get_data":
    return $nimSharedData
  else:
    return "unknown operation"

echo "=== MicroPython with Nim Functions Example ==="
echo ""

# Create MicroPython instance
var py = newMicroPython()

try:
  # Inject our bridge functions
  injectNimBridge(py)
  
  echo "1. Simulated Nim function calls from Python:"
  echo ""
  
  # Simulate add function
  discard py.eval("nim_results['add_result'] = 8")  # Simulate Nim calculating 5+3
  echo "Python calling nim_add(5, 3):"
  echo py.eval("print('Result:', nim_add(5, 3))")
  echo ""
  
  # Simulate greet function
  discard py.eval("nim_results['greet_result'] = 'Hello from Nim, MicroPython!'")
  echo "Python calling nim_greet('MicroPython'):"
  echo py.eval("print(nim_greet('MicroPython'))")
  echo ""
  
  # Better approach: Direct string-based communication
  echo "2. String-based communication (more practical):"
  echo ""
  
  # Define a protocol for Nim-Python communication
  discard py.eval("""
# Define a simple protocol for calling Nim functions
def call_nim(operation, *args):
    # Format: operation|arg1|arg2|...
    args_str = [repr(arg) for arg in args]
    request = operation + '|' + '|'.join(args_str)
    # Store the request where Nim can see it
    nim_results['request'] = request
    # Return placeholder (in real app, would wait for Nim response)
    return nim_results.get('response', 'pending')

# Convenience wrappers
def nim_add_real(a, b):
    return call_nim('add', a, b)
    
def nim_factorial_real(n):
    return call_nim('factorial', n)
    
def nim_greet_real(name):
    return call_nim('greet', name)
""")
  
  # Simulate processing requests from Nim side
  echo "Nim processing Python requests:"
  
  # Process add request
  discard py.eval("call_nim('add', 10, 20)")
  let addRequest = py.eval("nim_results['request']")
  let addParts = addRequest.split('|')
  if addParts.len >= 3:
    let result = processNimRequest(py, addParts[0], @[addParts[1], addParts[2]])
    discard py.eval(fmt"nim_results['response'] = '{result}'")
    echo "  Add result: ", py.eval("nim_results['response']")
  
  # Process factorial request
  discard py.eval("call_nim('factorial', 5)")
  let factRequest = py.eval("nim_results['request']")
  let factParts = factRequest.split('|')
  if factParts.len >= 2:
    let result = processNimRequest(py, factParts[0], @[factParts[1]])
    discard py.eval(fmt"nim_results['response'] = '{result}'")
    echo "  Factorial result: ", py.eval("nim_results['response']")
  
  echo ""
  echo "3. Shared state example:"
  
  # Use shared counter
  for i in 1..3:
    let count = processNimRequest(py, "get_counter", @[])
    echo fmt"  Nim counter: {count}"
  
  # Store and retrieve data
  discard processNimRequest(py, "store_data", @["42"])
  discard processNimRequest(py, "store_data", @["100"])
  discard processNimRequest(py, "store_data", @["7"])
  let data = processNimRequest(py, "get_data", @[])
  echo fmt"  Nim shared data: {data}"
  
  echo ""
  echo "4. Python using the communication protocol:"
  echo py.eval("""
# Use the protocol from Python side
print("From Python:")
print("  10 + 20 =", call_nim('add', 10, 20))
print("  5! =", call_nim('factorial', 5))
print("  Greeting:", call_nim('greet', 'World'))
print("  Counter:", call_nim('get_counter'))
""")

finally:
  py.close()

echo ""
echo "Example completed!"
echo ""
echo "Note: This example shows the concept of Nim-Python interaction."
echo "For production use, you would need a proper callback mechanism"
echo "or use MicroPython's C API with proper bindings."