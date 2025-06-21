# Burrito 🌯

A Nim wrapper for the [QuickJS JavaScript engine](https://github.com/bellard/quickjs).

## Features

- 📦 **Simple**: Easy-to-use API for embedding JavaScript in Nim
- 🔗 **Two-way**: Run JavaScript from Nim and call Nim functions from JavaScript
- 🔢 **Flexible**: Support for functions with different numbers of arguments
- 🔄 **Type conversion**: Built-in helpers for converting between Nim and JavaScript values

## Installation

### Prerequisites

- Nim >= 2.2.4
- C compiler (gcc/clang)
- Make
- curl (for downloading QuickJS source)
- tar with xz support (usually pre-installed on Linux/macOS)

### Install Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/tapsterbot/burrito.git
   cd burrito
   ```

2. **Download and build QuickJS:**
   ```bash
   nimble get_quickjs
   nimble build_quickjs
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

### Calling Nim Functions from JavaScript (Native C Bridging)

```nim
import burrito
import std/times

# Define Nim functions that work with JSValue directly
proc getTime(ctx: ptr JSContext): JSValue =
  let timeStr = now().format("yyyy-MM-dd HH:mm:ss")
  result = nimStringToJS(ctx, timeStr)

proc getMessage(ctx: ptr JSContext): JSValue =
  let msg = "Hello from Nim! 🌯"
  result = nimStringToJS(ctx, msg)

var js = newQuickJS()
defer: js.close()

# Register functions using native C bridging (no setup needed!)
js.registerFunction("getTime", getTime)
js.registerFunction("getMessage", getMessage)

# Call Nim functions from JavaScript with native performance!
echo js.eval("getTime()")     # "2025-06-21 17:33:00"
echo js.eval("getMessage()")  # "Hello from Nim! 🌯"
```

### Advanced Function Registration

```nim
import burrito

# Different function signatures are supported
proc square(ctx: ptr JSContext, arg: JSValue): JSValue =
  let num = toNimFloat(ctx, arg)
  JS_FreeValue(ctx, arg)  # Must free JSValue arguments
  nimFloatToJS(ctx, num * num)

proc addNumbers(ctx: ptr JSContext, arg1, arg2: JSValue): JSValue =
  let a = toNimFloat(ctx, arg1)
  let b = toNimFloat(ctx, arg2)
  JS_FreeValue(ctx, arg1)  # Must free JSValue arguments
  JS_FreeValue(ctx, arg2)
  nimFloatToJS(ctx, a + b)

proc concatenate(ctx: ptr JSContext, args: seq[JSValue]): JSValue =
  var result_str = ""
  for arg in args:
    result_str.add(toNimString(ctx, arg))
  nimStringToJS(ctx, result_str)

var js = newQuickJS()
defer: js.close()

# Register functions with different arities
js.registerFunction("square", square)           # 1 argument
js.registerFunction("add", addNumbers)          # 2 arguments  
js.registerFunction("concat", concatenate)      # variadic arguments

echo js.eval("square(7)")                       # 49
echo js.eval("add(5, 3)")                       # 8
echo js.eval("concat('Hello', ' ', 'World!')")  # Hello World!
```

## Memory Management

**⚠️ IMPORTANT**: When writing Nim functions that accept JSValue arguments, you **must** call `JS_FreeValue(ctx, arg)` for each JSValue argument after you're done using it, unless you transfer ownership to another QuickJS object.

JSValue arguments are automatically duplicated when passed to your Nim functions, so you're responsible for freeing them:

```nim
proc myFunction(ctx: ptr JSContext, arg: JSValue): JSValue =
  let value = toNimString(ctx, arg)
  JS_FreeValue(ctx, arg)  # ✅ Required! Free the argument
  return nimStringToJS(ctx, "processed: " & value)
```

**Exception**: Variadic functions (`NimFunctionVariadic`) automatically handle freeing the `args` sequence elements - you don't need to free them manually.

## API Reference

### Types

- `QuickJS`: Main wrapper object containing runtime and context
- `JSValue`: JavaScript value type (native QuickJS value)
- `JSException`: Exception type for JavaScript errors
- `NimFunction0*`: Function type with no arguments: `proc(ctx: ptr JSContext): JSValue`
- `NimFunction1*`: Function type with one argument: `proc(ctx: ptr JSContext, arg: JSValue): JSValue`
- `NimFunction2*`: Function type with two arguments: `proc(ctx: ptr JSContext, arg1, arg2: JSValue): JSValue`
- `NimFunction3*`: Function type with three arguments: `proc(ctx: ptr JSContext, arg1, arg2, arg3: JSValue): JSValue`
- `NimFunctionVariadic*`: Function type with variable arguments: `proc(ctx: ptr JSContext, args: seq[JSValue]): JSValue`

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

#### `registerFunction(js: var QuickJS, name: string, nimFunc: NimFunction0|1|2|3|Variadic)`
Registers a Nim function to be callable from JavaScript using native C function bridging. The function type is automatically detected based on the signature. No setup required!

### Value Conversion Helpers

#### JavaScript to Nim
- `toNimString(ctx: ptr JSContext, val: JSValueConst): string`
- `toNimInt(ctx: ptr JSContext, val: JSValueConst): int32`
- `toNimFloat(ctx: ptr JSContext, val: JSValueConst): float64`
- `toNimBool(ctx: ptr JSContext, val: JSValueConst): bool`

#### Nim to JavaScript  
- `nimStringToJS(ctx: ptr JSContext, str: string): JSValue`
- `nimIntToJS(ctx: ptr JSContext, val: int32): JSValue`
- `nimFloatToJS(ctx: ptr JSContext, val: float64): JSValue`
- `nimBoolToJS(ctx: ptr JSContext, val: bool): JSValue`

## Examples

Run the examples:
```bash
nim c -r examples/basic_example.nim             # Basic JavaScript evaluation
nim c -r examples/call_nim_from_js.nim          # Call Nim functions from JavaScript
nim c -r examples/advanced_native_bridging.nim  # Advanced native function bridging
```

## Contributing

Patches welcome!

## License

MIT License - see LICENSE file for details.

QuickJS is licensed under the MIT license. See `quickjs/LICENSE` for QuickJS license details.

## Related Projects

- [QuickJS](https://github.com/bellard/quickjs) - The underlying JavaScript engine
- [QuickJS Documentation](https://bellard.org/quickjs/) - Official QuickJS documentation

---
