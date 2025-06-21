# Burrito 🌯

A lightweight and focused Nim wrapper for the [QuickJS JavaScript engine](https://github.com/bellard/quickjs). This wrapper provides an idiomatic Nim interface to embed JavaScript execution and expose Nim functions to JavaScript code.

## Features

- 🚀 **Lightweight**: Minimal overhead wrapper around QuickJS
- 🔗 **Bidirectional**: Evaluate JavaScript from Nim and call Nim functions from JavaScript  
- 🛡️ **Safe**: Proper memory management and error handling
- 📦 **Easy**: Simple API for common use cases
- 🎯 **Focused**: Core functionality without bloat

## Installation

### Prerequisites

- Nim >= 2.2.4
- C compiler (gcc/clang)
- Make

### Install Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/tapsterbot/burrito.git
   cd burrito
   ```

2. **Build QuickJS library:**
   ```bash
   nimble build_lib
   ```
   Or manually:
   ```bash
   cd quickjs && make
   ```

3. **Install the package:**
   ```bash
   nimble install
   ```

4. **Run examples:**
   ```bash
   nimble example
   ```

## Quick Start

### Basic JavaScript Evaluation

```nim
import burrito

# Create a QuickJS instance
var js = newQuickJS()
defer: js.close()

# Evaluate JavaScript code
echo js.eval("2 + 3")                    # 5
echo js.eval("'Hello ' + 'World!'")      # Hello World!
echo js.eval("Math.sqrt(16)")            # 4
```

### Calling Nim Functions from JavaScript

```nim
import burrito
import std/times

# Define Nim functions
proc getTime(): string = now().format("yyyy-MM-dd HH:mm:ss")
proc getMessage(): string = "Hello from Nim! 🌯"

var js = newQuickJS()
defer: js.close()

# Set up the bridge and register functions
js.setupNimBridge()
js.registerFunction("getTime", getTime)
js.registerFunction("getMessage", getMessage)

# Call Nim functions from JavaScript!
echo js.eval("getTime()")     # "2025-06-21 17:33:00"
echo js.eval("getMessage()")  # "Hello from Nim! 🌯"
```

## API Reference

### Types

- `QuickJS`: Main wrapper object containing runtime and context
- `JSValue`: JavaScript value type
- `JSException`: Exception type for JavaScript errors
- `newQuickJS()`: Create a new QuickJS instance
- `eval()`: Evaluate JavaScript code
- `evalWithGlobals()`: Evaluate with Nim variables
- `setJSFunction()`: Define JS functions from strings

### Core Functions

#### `newQuickJS(): QuickJS`
Creates a new QuickJS instance with runtime and context.

#### `close(js: var QuickJS)`
Properly cleans up QuickJS instance (called automatically with `defer`).

#### `eval(js: QuickJS, code: string, filename: string = "<eval>"): string`
Evaluates JavaScript code and returns the result as a string.

#### `evalWithGlobals(js: QuickJS, code: string, globals: Table[string, string]): string`
Evaluates JavaScript code with global variables set from Nim.

#### `setJSFunction(js: QuickJS, name: string, value: string)`
Sets a JavaScript function in the global scope from a string definition.

#### `setupNimBridge(js: var QuickJS)`
Sets up the bridge system to allow JavaScript to call Nim functions.

#### `registerFunction(js: var QuickJS, name: string, nimFunc: NimFunction)`
Registers a Nim function to be callable from JavaScript. Requires `setupNimBridge()` to be called first.

## Examples

Run the examples:
```bash
nim c -r examples/basic_example.nim        # Basic JavaScript evaluation
nim c -r examples/call_nim_from_js.nim     # Call Nim functions from JavaScript
```

## Architecture

This wrapper provides a focused interface to QuickJS:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Nim Code      │    │  QuickJS Wrapper │    │   QuickJS C     │
│                 │◄──►│                  │◄──►│                 │
│ Your Functions  │    │  Type Safety     │    │  JS Engine      │
│ Your Logic      │    │  Memory Mgmt     │    │  Execution      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Limitations & Notes

- **Simplified API**: This wrapper prioritizes simplicity. Complex Nim-JavaScript function bridging is demonstrated but simplified.
- **String-based Interface**: Data exchange happens primarily through strings for simplicity and reliability.
- **Error Handling**: JavaScript exceptions are converted to strings. More sophisticated error handling could be added.
- **Memory Management**: The wrapper handles QuickJS memory management automatically.
- **Performance**: Minimal overhead for most operations. String conversions have some cost.

## Building from Source

1. **Get QuickJS source**: The repository includes QuickJS source in the `quickjs/` directory
2. **Build QuickJS**: `nimble build_lib` or `cd quickjs && make`
3. **Build Nim wrapper**: `nim c src/burrito.nim`
4. **Run tests**: `nimble example` or `nim c -r examples/basic_example.nim`

## Contributing

This is a focused, lightweight wrapper. Contributions should maintain the philosophy of simplicity and essential functionality.

## License

MIT License - see LICENSE file for details.

QuickJS is licensed under the MIT license. See `quickjs/LICENSE` for QuickJS license details.

## Related Projects

- [QuickJS](https://github.com/bellard/quickjs) - The underlying JavaScript engine
- [QuickJS Documentation](https://bellard.org/quickjs/) - Official QuickJS documentation

---
