## MicroPython API Demo - Matching QuickJS Style
##
## This example demonstrates the MicroPython API that matches
## the QuickJS naming conventions for consistency

import "../../src/burrito/mpy"

echo "=== MicroPython API Demo (QuickJS-style naming) ==="
echo ""

# Create MicroPython instance (matches newQuickJS)
var py = newMicroPython()

try:
  echo "API Consistency Demonstration:"
  echo ""
  
  # Basic evaluation (matches QuickJS eval)
  echo "1. Basic eval():"
  echo "   py.eval(\"2 + 3\") =", py.eval("2 + 3")
  echo "   py.eval(\"'Hello World'\") =", py.eval("print('Hello World')")
  echo ""
  
  # Type system demonstration  
  echo "2. Type system (matches QuickJS conversion functions):"
  echo "   Available conversion functions:"
  echo "   - toNimString(ctx, val)  # Convert MPValue to Nim string"
  echo "   - toNimInt(ctx, val)     # Convert MPValue to Nim int32"
  echo "   - toNimFloat(ctx, val)   # Convert MPValue to Nim float64"
  echo "   - toNimBool(ctx, val)    # Convert MPValue to Nim bool"
  echo ""
  echo "   - nimStringToMP(ctx, s)  # Convert Nim string to MPValue"
  echo "   - nimIntToMP(ctx, i)     # Convert Nim int32 to MPValue"
  echo "   - nimFloatToMP(ctx, f)   # Convert Nim float64 to MPValue"
  echo "   - nimBoolToMP(ctx, b)    # Convert Nim bool to MPValue"
  echo ""
  
  # Function registration demonstration
  echo "3. Function registration (matches QuickJS registerFunction):"
  echo "   Available registerFunction overloads:"
  echo "   - registerFunction(py, name, func: MPFunction0)   # No args"
  echo "   - registerFunction(py, name, func: MPFunction1)   # 1 arg" 
  echo "   - registerFunction(py, name, func: MPFunction2)   # 2 args"
  echo "   (Note: Full implementation requires complete C API access)"
  echo ""
  
  # Bytecode support (matches QuickJS evalBytecode)
  echo "4. Bytecode evaluation (matches QuickJS evalBytecode):"
  echo "   py.evalBytecode(bytecode) - Execute pre-compiled Python bytecode"
  echo ""
  
  # Configuration and lifecycle
  echo "5. Instance management (matches QuickJS patterns):"
  echo "   - newMicroPython(heapSize) # Create instance (like newQuickJS)"
  echo "   - py.close()              # Clean up (like QuickJS close)"
  echo "   - py.isInitialized()      # Check state"
  echo "   - py.heapSize()           # Get heap size"
  echo ""
  
  # Demonstrate actual functionality
  echo "6. Working examples:"
  echo py.eval("print('Math:', 2**8)")
  echo py.eval("print('Strings:', 'Python'.upper())")
  echo py.eval("print('Lists:', list(range(5)))")
  echo py.eval("print('Iteration:', [x*2 for x in range(3)])")
  echo ""
  
  echo "7. State information:"
  echo "   Initialized:", py.isInitialized()
  echo "   Heap size:", py.heapSize(), "bytes"

finally:
  # Clean up (matches QuickJS pattern)
  py.close()

echo ""
echo "API Demo completed!"
echo ""
echo "Key Benefits of Matching QuickJS API:"
echo "- Consistent naming across Burrito modules"
echo "- Easy to switch between JS and Python backends"
echo "- Familiar function signatures for developers"  
echo "- Same conversion function patterns"
echo "- Unified registration and lifecycle management"