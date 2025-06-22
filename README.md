# Burrito 🌯

A Nim wrapper for the [QuickJS JavaScript engine](https://github.com/bellard/quickjs).

## Features

- 📦 **Simple**: Easy-to-use API for embedding JavaScript in Nim
- 🔗 **Two-way**: Run JavaScript from Nim and call Nim functions from JavaScript
- 🔢 **Flexible**: Support for functions with different numbers of arguments
- 🔄 **Type marshaling**: Comprehensive conversion between Nim and JavaScript data structures
- 🚀 **Performance**: Native C function bridging with zero overhead
- 🧠 **Smart**: Support for sequences, tables, tuples, and custom object types

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
  nimFloatToJS(ctx, num * num)

proc addNumbers(ctx: ptr JSContext, arg1, arg2: JSValue): JSValue =
  let a = toNimFloat(ctx, arg1)
  let b = toNimFloat(ctx, arg2)
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

## Standard Library Modules (std/os)

Burrito supports QuickJS's built-in `std` and `os` modules for file I/O, environment access, and system operations:

### Basic std Module Usage

```nim
import burrito

# Enable std module
var js = newQuickJS(configWithStdLib())
defer: js.close()

# Access environment variables and printf functionality
discard js.evalModule("""
  import * as std from "std";

  let shell = std.getenv("SHELL") || "unknown";
  std.out.printf("Current shell: %s\n", shell);
""")
```

### Basic os Module Usage

```nim
import burrito

# Enable os module
var js = newQuickJS(configWithOsLib())
defer: js.close()

# Get current directory and system info
discard js.evalModule("""
  import * as os from "os";

  let [cwd, err] = os.getcwd();
  if (!err) {
    console.log("Working directory:", cwd);
    console.log("Platform:", os.platform);
  }
""")
```

### Using Both Modules

```nim
import burrito

# Enable both std and os modules
var js = newQuickJS(configWithBothLibs())
defer: js.close()

# Combine functionality from both modules
discard js.evalModule("""
  import * as std from "std";
  import * as os from "os";

  let [cwd] = os.getcwd();
  let shell = std.getenv("SHELL") || "unknown";

  std.out.printf("Running %s in %s\n",
                 shell.split('/').pop(),
                 cwd.split('/').pop());
""")
```

**Available configurations:**
- `newQuickJS()` - Default (no modules)
- `newQuickJS(configWithStdLib())` - std module only
- `newQuickJS(configWithOsLib())` - os module only
- `newQuickJS(configWithBothLibs())` - Both modules

**Note:** ES6 modules correctly return `undefined` per specification. Use module side effects (like `printf`, `console.log`) or `export default` for return values.

## Memory Management

Burrito is memory-safe by design. All JavaScript values are automatically managed - just write your functions naturally:

```nim
proc processText(ctx: ptr JSContext, text: JSValue): JSValue =
  let input = toNimString(ctx, text)
  return nimStringToJS(ctx, input.toUpper())
```

Memory cleanup happens automatically when functions return. Property access and array helpers also handle their own cleanup.

## Thread Safety

**⚠️ IMPORTANT**: QuickJS instances are **NOT thread-safe**. You have two options:

### Option 1: One Instance Per Thread (Recommended)
```nim
# Each thread should create its own QuickJS instance
proc workerThread() {.thread.} =
  var js = newQuickJS()  # Create instance in this thread
  defer: js.close()
  echo js.eval("2 + 2")  # Safe - only this thread uses this instance
```

### Option 2: External Synchronization
If you must share an instance across threads, use locks:
```nim
import std/locks

var
  js = newQuickJS()
  jsLock: Lock

initLock(jsLock)

proc safeEval(code: string): string =
  withLock jsLock:
    return js.eval(code)  # Protected by lock
```

## API Reference

### Types

- `QuickJS`: Main wrapper object containing runtime and context (⚠️ NOT thread-safe)
- `JSValue`: JavaScript value type (native QuickJS value)
- `JSException`: Exception type for JavaScript errors
- `NimFunction0*`: Function type with no arguments: `proc(ctx: ptr JSContext): JSValue`
- `NimFunction1*`: Function type with one argument: `proc(ctx: ptr JSContext, arg: JSValue): JSValue`
- `NimFunction2*`: Function type with two arguments: `proc(ctx: ptr JSContext, arg1, arg2: JSValue): JSValue`
- `NimFunction3*`: Function type with three arguments: `proc(ctx: ptr JSContext, arg1, arg2, arg3: JSValue): JSValue`
- `NimFunctionVariadic*`: Function type with variable arguments: `proc(ctx: ptr JSContext, args: seq[JSValue]): JSValue`

### Core Functions

#### `newQuickJS(config: QuickJSConfig = defaultConfig()): QuickJS`
Creates a new QuickJS instance with runtime and context. **Not thread-safe** - use one instance per thread or external locking.

**Configuration options:**
- `defaultConfig()` - Basic QuickJS (no std/os modules)
- `configWithStdLib()` - Enable std module
- `configWithOsLib()` - Enable os module
- `configWithBothLibs()` - Enable both std and os modules

#### `close(js: var QuickJS)`
Properly cleans up QuickJS instance (called automatically with `defer`).

#### `eval(js: QuickJS, code: string, filename: string = "<eval>"): string`
Evaluates JavaScript code and returns the result as a string.

#### `evalModule(js: QuickJS, code: string, filename: string = "<module>"): string`
Evaluates JavaScript code as an ES6 module (enables import/export syntax). Returns `undefined` per ES6 specification - use for side effects or `export default`.

#### `evalWithGlobals(js: QuickJS, code: string, globals: Table[string, string]): string`
Evaluates JavaScript code with global variables set from Nim.

#### `setJSFunction(js: QuickJS, name: string, value: string)`
Sets a JavaScript function in the global scope from a string definition.

#### `registerFunction(js: var QuickJS, name: string, nimFunc: NimFunction0|1|2|3|Variadic)`
Registers a Nim function to be callable from JavaScript using native C function bridging. The function type is automatically detected based on the signature. No setup required!

#### `canUseStdLib(js: QuickJS): bool`
Check if std module is available in this QuickJS instance.

#### `canUseOsLib(js: QuickJS): bool`
Check if os module is available in this QuickJS instance.

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

### Type Checking Functions

- `isUndefined(ctx: ptr JSContext, val: JSValueConst): bool`
- `isNull(ctx: ptr JSContext, val: JSValueConst): bool`
- `isBool(ctx: ptr JSContext, val: JSValueConst): bool`
- `isNumber(ctx: ptr JSContext, val: JSValueConst): bool`
- `isString(ctx: ptr JSContext, val: JSValueConst): bool`
- `isObject(ctx: ptr JSContext, val: JSValueConst): bool`
- `isArray(ctx: ptr JSContext, val: JSValueConst): bool`
- `isFunction(ctx: ptr JSContext, val: JSValueConst): bool`

### Object and Array Manipulation

#### Object Operations
- `getProperty(ctx: ptr JSContext, obj: JSValueConst, key: string): JSValue`
- `setProperty(ctx: ptr JSContext, obj: JSValueConst, key: string, value: JSValue): bool`

#### Array Operations
- `newArray(ctx: ptr JSContext): JSValue`
- `getArrayElement(ctx: ptr JSContext, arr: JSValueConst, index: uint32): JSValue`
- `setArrayElement(ctx: ptr JSContext, arr: JSValueConst, index: uint32, value: JSValue): bool`
- `getArrayLength(ctx: ptr JSContext, arr: JSValueConst): uint32`

### Auto-Memory Management Helpers

These functions automatically handle `JS_FreeValue` for you, making memory management effortless:

#### Direct Value Access
- `getPropertyValue[T](ctx: ptr JSContext, obj: JSValueConst, key: string, target: typedesc[T]): T`
- `getArrayElementValue[T](ctx: ptr JSContext, arr: JSValueConst, index: uint32, target: typedesc[T]): T`
- `setGlobalProperty[T](ctx: ptr JSContext, name: string, value: T): bool`
- `getGlobalProperty[T](ctx: ptr JSContext, name: string, target: typedesc[T]): T`

#### Scoped Access Templates
- `withGlobalObject(ctx, globalVar, body)` - Auto-manage global object lifetime
- `withProperty(ctx, obj, key, propVar, body)` - Auto-manage property lifetime
- `withArrayElement(ctx, arr, index, elemVar, body)` - Auto-manage array element lifetime

#### High-level Iteration
- `iterateArray(ctx: ptr JSContext, arr: JSValueConst, callback)` - Iterate with auto memory management
- `collectArray[T](ctx: ptr JSContext, arr: JSValueConst, target: typedesc[T]): seq[T]` - Collect to sequence

**Examples:**
```nim
# Old way (manual memory management)
let globalObj = JS_GetGlobalObject(ctx)
let nameVal = getProperty(ctx, globalObj, "userName")
defer:
  JS_FreeValue(ctx, globalObj)
  JS_FreeValue(ctx, nameVal)
let name = toNimString(ctx, nameVal)

# New ways (automatic memory management + idiomatic syntax)
let name = ctx.getString("userName")          # Type-specific method
let name = ctx.get("userName", string)       # Generic method
ctx["userName"] = "Alice"                    # Idiomatic assignment
```

### Idiomatic Syntax Helpers

Burrito provides beautiful, Nim-like syntax for common operations:

#### Global Property Access
```nim
# Type-specific methods (recommended)
let name = ctx.getString("userName")
let age = ctx.getInt("userAge")
let score = ctx.getFloat("userScore")
let active = ctx.getBool("isActive")

# Generic method
let name = ctx.get("userName", string)

# Assignment (works with any type)
ctx["userName"] = "Alice"
ctx["userAge"] = 30
ctx.set("userScore", 95.5)
```

### Comprehensive Type Marshaling

Burrito provides advanced type marshaling capabilities for seamless conversion between Nim data structures and JavaScript values.

#### Sequence and Array Conversions
- `seqToJS[T](ctx: ptr JSContext, s: seq[T]): JSValue` - Convert Nim sequence to JavaScript array
  - Supports: `string`, `int`/`int32`, `float`/`float64`, `bool`, and complex types (via string representation)

#### Table and Object Conversions
- `tableToJS[K,V](ctx: ptr JSContext, t: Table[K,V]): JSValue` - Convert Nim Table to JavaScript object
  - Key types: Any type convertible to string
  - Value types: `string`, `int`/`int32`, `float`/`float64`, `bool`, and complex types (via string representation)

#### Tuple Conversions
- `nimTupleToJSArray[T](ctx: ptr JSContext, tup: T): JSValue` - Convert Nim tuple to JavaScript array
  - Supported tuple types: `(string, int)`, `(string, string)`, `(int, int)`

#### Custom Object Type Support
Create your own conversion functions for custom Nim object types:

```nim
type
  Person = object
    name: string
    age: int
    email: string

proc personToJS(ctx: ptr JSContext, person: Person): JSValue =
  let obj = JS_NewObject(ctx)
  discard setProperty(ctx, obj, "name", nimStringToJS(ctx, person.name))
  discard setProperty(ctx, obj, "age", nimIntToJS(ctx, person.age.int32))
  discard setProperty(ctx, obj, "email", nimStringToJS(ctx, person.email))
  return obj

proc jsToPerson(ctx: ptr JSContext, jsObj: JSValueConst): Person =
  let nameVal = getProperty(ctx, jsObj, "name")
  let ageVal = getProperty(ctx, jsObj, "age")
  let emailVal = getProperty(ctx, jsObj, "email")
  defer:
    JS_FreeValue(ctx, nameVal)
    JS_FreeValue(ctx, ageVal)
    JS_FreeValue(ctx, emailVal)

  result = Person(
    name: toNimString(ctx, nameVal),
    age: toNimInt(ctx, ageVal).int,
    email: toNimString(ctx, emailVal)
  )
```

#### Practical Type Marshaling Example

```nim
import burrito
import std/tables

# Create QuickJS instance
var js = newQuickJS()
defer: js.close()

# Convert Nim data structures to JavaScript
let fruits = @["apple", "banana", "cherry"]
let config = {"host": "localhost", "port": "8080"}.toTable()
let point = (x: 100, y: 200)

# Set them as global JavaScript variables
let globalObj = JS_GetGlobalObject(js.context)
defer: JS_FreeValue(js.context, globalObj)

discard setProperty(js.context, globalObj, "fruits", seqToJS(js.context, fruits))
discard setProperty(js.context, globalObj, "config", tableToJS(js.context, config))
discard setProperty(js.context, globalObj, "point", nimTupleToJSArray(js.context, point))

# Use them in JavaScript
echo js.eval("fruits.length")                    # 3
echo js.eval("fruits.join(', ')")               # apple, banana, cherry
echo js.eval("config.host + ':' + config.port") # localhost:8080
echo js.eval("point[0] + point[1]")             # 300
```

## Examples

Burrito includes comprehensive examples showcasing all features from beginner-friendly to advanced:

### Core Examples
```bash
nim c -r examples/basic_example.nim             # Basic JavaScript evaluation
nim c -r examples/call_nim_from_js.nim          # Call Nim functions from JavaScript
nim c -r examples/advanced_native_bridging.nim  # Advanced native function bridging
```

### More Feature Examples
```bash
nim c -r examples/comprehensive_features.nim    # ALL features from high-level to low-level
nim c -r examples/idiomatic_patterns.nim        # Beautiful idiomatic Nim syntax patterns
nim c -r examples/type_system.nim               # Advanced type marshaling and safety
```

**Example Descriptions:**
- **`comprehensive_features.nim`** - Complete demonstration from high-level type inference and idiomatic syntax down to low-level manual memory management
- **`idiomatic_patterns.nim`** - Focus on beautiful Nim syntax patterns, type inference magic, and automatic memory management
- **`type_system.nim`** - Advanced type marshaling, custom object conversion, and type safety demonstrations
- **`module_example.nim`** - QuickJS std/os module functionality: environment access, file operations, and system information

Or run all examples at once:
```bash
nimble examples
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
