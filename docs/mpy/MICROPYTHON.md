# MicroPython Integration for Burrito

*This document provides detailed information about MicroPython integration in Burrito v0.3.0. For general project information and QuickJS documentation, see [CLAUDE.md](../../CLAUDE.md).*

Burrito provides a clean, idiomatic Nim wrapper for **MicroPython** using the official embedding API. This allows you to embed Python scripting capabilities into your Nim applications with automatic memory management and a consistent API.

## Quick Start

### 1. Setup MicroPython
```bash
# Download and build MicroPython embedding library
nimble get_micropython
nimble build_micropython
```

### 2. Basic Usage
```nim
import burrito/mpy

var py = newMicroPython()
defer: py.close()

# Execute Python code
echo py.eval("print('Hello from MicroPython!')")  # Output: Hello from MicroPython!
echo py.eval("2 + 3")                            # Output: 5
```

### 3. Dual Engines Example
```nim
import burrito/qjs  # JavaScript engine
import burrito/mpy  # Python engine

var js = newQuickJS()
var py = newMicroPython()

# JavaScript computation
let jsResult = js.eval("Math.sqrt(16)")
echo "JS result: ", jsResult                     # Output: JS result: 4

# Python computation
echo py.eval("print('Python result:', (16 ** 0.5))")  # Output: Python result: 4.0

js.close()
py.close()
```

### 4. Running Examples
```bash
# Basic MicroPython example
nimble example_mpy

# Dual engines (JavaScript + Python)
nimble dual_engines
```

## API Reference

### Core Functions

#### `newMicroPython(heapSize: int = DEFAULT_HEAP_SIZE): MicroPython`
Creates a new MicroPython instance with specified heap size (default 64KB).

#### `eval(py: MicroPython, code: string): string`
Evaluates Python code and returns captured output from print statements.

#### `close(py: MicroPython)`
Cleans up the MicroPython instance and releases memory.

## Examples

### Basic Operations
```nim
import burrito/mpy

var py = newMicroPython()
defer: py.close()

# Arithmetic
echo py.eval("print(7 * 6)")                    # Output: 42

# String manipulation
echo py.eval("print('Hello ' + 'World!')")      # Output: Hello World!

# Variables and calculations
discard py.eval("result = 3 + 4 * 5")
echo py.eval("print('Result is:', result)")     # Output: Result is: 23

# Function definitions
echo py.eval("""
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

result = fibonacci(10)
print('Fibonacci(10):', result)
""")  # Output: Fibonacci(10): 55
```

### List Processing
```nim
import burrito/mpy

var py = newMicroPython()
defer: py.close()

echo py.eval("""
data = [1, 2, 3, 4, 5]
doubled = [x * 2 for x in data]
total = sum(doubled)
print('Doubled list sum:', total)
""")  # Output: Doubled list sum: 30
```

### String Operations
```nim
import burrito/mpy

var py = newMicroPython()
defer: py.close()

echo py.eval("""
text = "Hello World"
words = text.split(' ')
words.reverse()
result = ' '.join(words).upper()
print('Reversed and uppercase:', result)
""")  # Output: Reversed and uppercase: WORLD HELLO
```

## Language Support and Limitations

### ✅ Supported Features
- [x] Basic Python syntax (variables, functions, classes)
- [x] Data structures (lists, dicts, tuples, sets)
- [x] List comprehensions and generators
- [x] String operations and methods
- [x] Arithmetic and logical operations
- [x] Function definitions and calls
- [x] Exception handling (try/except)
- [x] Built-in functions (print, len, sum, etc.)
- [x] Multi-line code execution
- [x] Variable persistence across eval() calls

### ⚠️ Limitations
- **No f-strings**: Use string concatenation instead (`'Hello ' + name`)
- **Limited module imports**: Standard library modules may not be available
- **No advanced slicing**: Use `.reverse()` instead of `[::-1]`
- **No decimal exponents**: Use integer arithmetic where possible
- **Limited string formatting**: Use simple concatenation or `.format()` method

### Compatible vs Incompatible Syntax

#### ✅ Compatible
```python
# String concatenation
name = "World"
print("Hello " + name)

# List operations
data = [1, 2, 3]
data.reverse()
print(' '.join(str(x) for x in data))

# Basic math
result = 3 * 3 + 4 * 4  # 25
```

#### ❌ Incompatible
```python
# F-strings (not supported)
print(f"Hello {name}")

# Advanced slicing (not supported)
data[::-1]

# Decimal exponents (not supported)
result = 25 ** 0.5

# Module imports (limited)
import math
```

## Architecture

### MicroPython Embedding API
Burrito uses the **official MicroPython embedding API** from `micropython/examples/embedding/`:

- **Static Library**: Links against `libmicropython_embed.a`
- **C Headers**: Uses `micropython_embed.h` for API access
- **Memory Management**: Custom heap allocation with configurable size
- **Output Capture**: Overrides `mp_hal_stdout_tx_strn_cooked()` to capture print output

### ROM Level Configuration
The MicroPython build uses **MICROPY_CONFIG_ROM_LEVEL_EVERYTHING** for maximum Python language compatibility:

- Complete built-in function coverage (`all()`, `any()`, `divmod()`, etc.)
- Advanced data structures (dict/list/set comprehensions)
- Enhanced string operations and manipulation methods
- Full mathematical operations and complex arithmetic
- Lambda and functional programming (`map()`, `filter()`)
- Advanced error handling with complete exception hierarchy
- Maximum CPython compatibility within MicroPython's scope

### API Consistency
The MicroPython wrapper follows the same design patterns as QuickJS:

```nim
# Consistent API across engines
var js = newQuickJS()      ↔  var py = newMicroPython()
js.eval("code")            ↔  py.eval("code")
js.close()                 ↔  py.close()
```

## Build Configuration

### Nimble Tasks (Recommended)
```bash
# Setup
nimble get_micropython      # Download MicroPython source
nimble build_micropython    # Build embedding library

# Examples
nimble example_mpy          # Basic MicroPython example
nimble repl_mpy             # Interactive MicroPython REPL
nimble dual_engines         # JavaScript + Python together

# Aliases
nimble empy                 # Alias for example_mpy
nimble rmpy                 # Alias for repl_mpy
```

### Manual Compilation
If you need to compile manually, use these flags:
```bash
nim c -r \
  --cincludes:micropython/examples/embedding/micropython_embed \
  --passL:micropython/examples/embedding/libmicropython_embed.a \
  --passL:-lm \
  examples/mpy/basic_example.nim
```

### Build Artifacts
- **Source**: `micropython/` (Git repository)
- **Library**: `micropython/examples/embedding/libmicropython_embed.a`
- **Headers**: `micropython/examples/embedding/micropython_embed/`
- **Size**: ~450KB static library with full feature set

## Examples Directory

### MicroPython Examples
- `examples/mpy/basic_example.nim` - Basic MicroPython usage
- `examples/mpy/repl_mpy.nim` - Interactive REPL with readline support (command history, line editing, tab completion)

### Multi-Engine Examples
- `examples/multi/dual_engines.nim` - JavaScript + Python in same application

## Testing

### Test Suite
```bash
# Run all tests including MicroPython
nimble test_report

# MicroPython-specific tests
nim c -r tests/mpy/test_repl.nim
```

### Test Coverage
- Basic functionality (arithmetic, variables, functions)
- Multi-line code execution
- Variable persistence across eval() calls
- Memory management and cleanup
- Error handling and recovery

## Integration Patterns

### Single Engine Usage
```nim
import burrito/mpy

proc pythonCalculator() =
  var py = newMicroPython()
  defer: py.close()

  echo py.eval("print('Calculator ready!')")
  discard py.eval("result = 0")

  while true:
    write(stdout, "Enter expression (or 'quit'): ")
    let input = readLine(stdin)
    if input == "quit": break

    echo py.eval("result = " & input & "; print('Result:', result)")

pythonCalculator()
```

### Dual Engine Usage
```nim
import burrito/qjs
import burrito/mpy

proc dualCalculator() =
  var js = newQuickJS()
  var py = newMicroPython()
  defer: js.close()
  defer: py.close()

  # JavaScript processing
  let jsResult = js.eval("Math.PI * 2")

  # Pass to Python for further processing
  echo py.eval("js_result = " & jsResult & "; print('From JS:', js_result)")

dualCalculator()
```

## Performance Considerations

### Memory Usage
- **Heap Size**: Default 64KB, configurable per instance
- **Binary Size**: ~450KB static library overhead
- **Runtime**: Minimal overhead for eval() calls

### Startup Time
- **Cold Start**: ~1ms for newMicroPython()
- **Eval Performance**: ~0.1ms for simple expressions
- **Memory Allocation**: One-time heap allocation at startup

### Optimization Tips
1. **Reuse instances**: Create once, eval multiple times
2. **Batch operations**: Use multi-line code for complex logic
3. **Avoid imports**: Stick to built-in functions when possible
4. **Memory management**: Always call close() or use defer

## Current Limitations

The current MicroPython integration provides:
- ✅ Python code evaluation
- ✅ Output capture from print statements  
- ✅ Variable persistence across eval() calls
- ✅ Multi-line code execution
- ✅ Interactive REPL with readline support
- ✅ Command history and line editing  
- ✅ Tab completion for Python keywords
- ✅ Proper Ctrl+C/Ctrl+D handling (Ctrl+D exits, Ctrl+C interrupts)
- ⚠️  Known limitation: Tab completion cursor positioning (use Ctrl+E to jump to end)

**Not yet implemented:**
- ❌ Function registration (calling Nim functions from Python)
- ❌ Rich type conversions between Nim and Python
- ❌ Native bridging capabilities
- ❌ Custom module loading

## Future Enhancements

### Planned Features
- [ ] **Function Registration**: Python calling Nim functions
- [ ] **Type Conversions**: Rich data type mapping between Nim and Python
- [ ] **Module Loading**: Custom Python modules from filesystem
- [ ] **Async Support**: Non-blocking evaluation
- [ ] **Error Recovery**: Better exception handling and recovery

### Research Areas
- [ ] **Bytecode Compilation**: Pre-compile Python to bytecode
- ✅ **REPL Integration**: Interactive Python shell with readline support
- [ ] **Threading Support**: Multi-threaded Python execution
- [ ] **Performance Optimization**: JIT compilation and caching

## Contributing

When working with MicroPython integration:

1. **Follow Patterns**: Match the QuickJS wrapper's API design
2. **Test Thoroughly**: Include both unit and integration tests
3. **Document Examples**: Provide clear, working code samples
4. **Handle Errors**: Graceful degradation for unsupported features
5. **Memory Safety**: Always test memory cleanup and leak prevention

## License

MIT License - same as the main Burrito project. MicroPython itself is also MIT licensed.

---

**Note**: This implementation uses the official MicroPython embedding API for maximum stability and compatibility. While some advanced Python features are limited compared to CPython, the core language functionality is fully supported for most scripting use cases.
