# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains **Burrito** (v0.3.0), a unified Nim wrapper for multiple scripting engines including QuickJS JavaScript engine (version 2025-04-26) and MicroPython. QuickJS is a small and embeddable JavaScript engine that supports ES2023 specification, while MicroPython provides a lean Python implementation using the official embedding API.

**🎯 THE KILLER FEATURE:** Burrito's primary value proposition is the ability to embed complete scripting language REPLs with syntax highlighting, command history, and custom Nim function exposure into your applications with just a few lines of code.

The Burrito wrappers are located in `src/burrito/` and provide comprehensive, idiomatic Nim interfaces with automatic memory management and extensive API coverage for both engines.

## Quick Start

### Installation
```bash
# Clone and setup Burrito
git clone https://github.com/tapsterbot/burrito.git
cd burrito

# Download and build QuickJS
nimble get_quickjs
nimble build_quickjs

# Download and build MicroPython
nimble get_micropython
nimble build_micropython

# Test installation
nimble example
```

### Basic Usage Example
```nim
import burrito/qjs  # or: import burrito/mpy for MicroPython

var js = newQuickJS()
echo js.eval("3 + 4")                    # Output: 7
echo js.eval("'Hello ' + 'World!'")      # Output: Hello World!

proc greet(ctx: ptr JSContext, name: JSValue): JSValue =
  let nameStr = toNimString(ctx, name)
  result = nimStringToJS(ctx, "Hello from Nim, " & nameStr & "!")

js.registerFunction("greet", greet)
echo js.eval("greet('Burrito')")         # Output: Hello from Nim, Burrito!
js.close()
```

### MicroPython Usage Example
```nim
import burrito/mpy

var py = newMicroPython()
echo py.eval("print(3 + 4)")             # Output: 7
echo py.eval("print('Hello ' + 'World!')")  # Output: Hello World!
py.close()
```

### Embedded REPL Example
```nim
import burrito/qjs

var js = newQuickJS(configWithBothLibs())

proc greet(ctx: ptr JSContext, name: JSValue): JSValue =
  let nameStr = toNimString(ctx, name)
  result = nimStringToJS(ctx, "Hello from Nim, " & nameStr & "!")

js.registerFunction("greet", greet)

# Option 1: Load REPL from file
let replCode = readFile("quickjs/repl.js")
discard js.evalModule(replCode, "<repl>")
js.runPendingJobs()
js.processStdLoop()  # Interactive REPL runs here!
js.close()

# Option 2: Use pre-compiled bytecode (faster, no file dependency)
# First run: nimble compile_repl_bytecode
import ../build/src/repl_bytecode
discard js.evalBytecodeModule(qjsc_replBytecode)
js.runPendingJobs()
js.processStdLoop()
js.close()
```

## Nimble Commands

### Development
```bash
nimble example          # Run basic QuickJS example
nimble examples         # Run all QuickJS examples
nimble repl_js          # Start QuickJS REPL with custom Nim functions
nimble test_report      # Run test suite with summary
nimble compile_repl_bytecode  # Compile repl.js to bytecode
```

### QuickJS Management
```bash
nimble get_quickjs     # Download QuickJS source
nimble build_quickjs   # Build QuickJS library
nimble delete_quickjs  # Remove QuickJS source
nimble clean_all       # Clean all build artifacts
```

### MicroPython Management
```bash
nimble get_micropython     # Download MicroPython source
nimble build_micropython   # Build MicroPython embedding library
nimble delete_micropython  # Remove MicroPython source
nimble example_mpy         # Run basic MicroPython example
nimble empy                # Alias for example_mpy

# Multi-engine examples
nimble dual_engines        # Run JavaScript + Python together
```

### Documentation
```bash
nimble docs           # Generate API documentation
nimble serve_docs     # Serve docs locally at http://localhost:8000
```

## Project Structure

### Core Files
- `src/burrito.nim` - Main module that re-exports both QuickJS and MicroPython modules
- `src/burrito/qjs.nim` - QuickJS wrapper with comprehensive bindings
- `src/burrito/mpy.nim` - MicroPython wrapper using embedding API
- `burrito.nimble` - Package configuration with all development tasks
- `nim.cfg` - Build configuration (outputs to build/bin/)
- `docs/index.html` - Modern landing page with sunset gradient theme
- `docs/burrito.html` - Generated API documentation

### QuickJS Examples
- `examples/qjs/basic_example.nim` - Simple JavaScript evaluation
- `examples/qjs/call_nim_from_js.nim` - Exposing Nim functions to JavaScript
- `examples/qjs/bytecode_basic.nim` - Basic bytecode compilation and execution
- `examples/qjs/bytecode_comprehensive.nim` - Complete bytecode feature showcase
- `examples/qjs/repl_qjs.nim` - Standalone REPL implementation
- `examples/qjs/repl_with_nim_function.nim` - REPL with one custom function (simple)
- `examples/qjs/repl_with_nim_functions.nim` - REPL with custom functions (longer)
- `examples/qjs/repl_bytecode.nim` - REPL from embedded bytecode (no external files)
- `examples/qjs/advanced_native_bridging.nim` - Complex type marshaling
- `examples/qjs/comprehensive_features.nim` - Feature showcase
- `examples/qjs/idiomatic_patterns.nim` - Idiomatic usage patterns
- `examples/qjs/type_system.nim` - Type system examples
- `examples/qjs/module_example.nim` - ES6 module usage

### MicroPython Examples
- `examples/mpy/basic_example.nim` - Simple Python evaluation
- `examples/mpy/api_demo.nim` - API consistency demonstration
- `examples/mpy/with_nim_funcs.nim` - Nim function integration patterns (future)
- `examples/mpy/native_integration.nim` - Native C API integration patterns
- `examples/mpy/nim_integration.nim` - Clean Nim-Python integration
- `examples/mpy/simple_integration.nim` - Simple integration patterns
- `examples/mpy/everything_features.nim` - Comprehensive feature showcase
- `examples/mpy/repl_mpy.nim` - MicroPython REPL implementation

### Multi-Engine Examples
- `examples/multi/dual_engines.nim` - Using both JS and Python together

### Testing
- `tests/qjs/test_basic.nim` - Basic QuickJS functionality tests
- `tests/qjs/test_repl.nim` - QuickJS REPL testing wrapper
- `tests/qjs/test_repl.exp` - Expect script for interactive REPL testing
- `tests/qjs/test_repl_bytecode.exp` - Expect script for bytecode REPL testing
- `tests/mpy/test_repl.nim` - MicroPython REPL testing wrapper
- `tests/mpy/test_repl.exp` - Expect script for MicroPython testing

## Key Features

### Automatic Memory Management
- JSValue arguments are automatically freed by function trampolines
- Scoped templates for safe property and array access
- No manual JS_FreeValue calls needed for function parameters
- MicroPython uses automatic heap management with configurable size

### Idiomatic Nim Interface
- Type-safe conversions between Nim and JavaScript/Python types
- Generic property accessors with automatic type detection
- Method-style syntax for common operations
- Consistent API patterns across both engines

### QuickJS Configuration Options
- `defaultConfig()` - Basic JavaScript engine
- `configWithStdLib()` - Includes std module
- `configWithOsLib()` - Includes os module
- `configWithBothLibs()` - Full standard library support

### Function Registration (QuickJS)
- Support for 0-3 fixed arguments plus variadic functions
- Automatic exception handling and conversion
- Function overloading by argument count

### Bytecode Support (QuickJS)
- Compile JavaScript to bytecode with `compileToBytecode()`
- Execute bytecode with `evalBytecode()` - faster startup, no compilation
- Works with both isolated (defaultConfig) and full-featured (configWithBothLibs) configurations
- Smart detection: automatically chooses optimal execution path
- Pre-compile REPL to bytecode for embedding in binary
- No external file dependencies when using bytecode
- Variables persist across bytecode executions (global scope preservation)

## Import Patterns

### Unified Import (Both Engines)
```nim
import burrito  # Imports both QuickJS and MicroPython

# Use QuickJS
var js = newQuickJS()
echo js.eval("2 + 3")
js.close()

# Use MicroPython
var py = newMicroPython()
echo py.eval("print(2 + 3)")
py.close()
```

### Specific Engine Import
```nim
# QuickJS only
import burrito/qjs
var js = newQuickJS()

# MicroPython only
import burrito/mpy
var py = newMicroPython()
```

### Multi-Engine Applications
```nim
import burrito/qjs
import burrito/mpy

var js = newQuickJS()
var py = newMicroPython()

# Use both engines together
let jsResult = js.eval("Math.PI * 2")
echo py.eval("print('Python says:', 3.14159 * 2)")
```

## MicroPython Features

### API Consistency with QuickJS
- Matching function names: `newMicroPython()`, `eval()`, `close()`
- Consistent lifecycle management and error handling
- Similar patterns for code evaluation and memory management
- Unified import and usage patterns

### Core Capabilities
- Python code evaluation with output capture
- Heap management and memory control (configurable 64KB default)
- Integration with existing Nim applications
- String-based result communication
- Multi-line code execution support
- Variable persistence across eval() calls

### MicroPython Configuration
Burrito uses **MICROPY_CONFIG_ROM_LEVEL_EVERYTHING** for maximum Python feature compatibility:
- **Complete built-in function coverage**: `all()`, `any()`, `divmod()`, etc.
- **Advanced data structures**: Dict/list/set comprehensions, generator expressions
- **Enhanced string operations**: Advanced formatting and manipulation methods
- **Full mathematical operations**: Power operations, complex arithmetic
- **Lambda and functional programming**: `map()`, `filter()`, lambda expressions
- **Advanced error handling**: Complete exception hierarchy and debugging
- **Maximum CPython compatibility**: Most Python language features available

### Python Language Limitations
While MICROPY_CONFIG_ROM_LEVEL_EVERYTHING provides extensive compatibility, some limitations exist:
- **No f-strings**: Use string concatenation (`'Hello ' + name`) instead
- **Limited module imports**: Standard library modules may not be available
- **No advanced slicing**: Use `.reverse()` instead of `[::-1]`
- **No decimal exponents**: Use integer arithmetic where possible
- **Limited string formatting**: Use simple concatenation instead of complex formatting

### Integration Approach
- **Embedding API**: Uses official MicroPython embedding API from `micropython/examples/embedding/`
- **Static Library**: Links against `libmicropython_embed.a` (~450KB)
- **Output Capture**: Custom `mp_hal_stdout_tx_strn_cooked()` override for print capture
- **Memory Management**: Configurable heap allocation with automatic cleanup

## Architecture

### QuickJS Components
- **quickjs.c/quickjs.h** - Main JavaScript engine implementation
- **quickjs-libc.c/quickjs-libc.h** - Standard library bindings
- **qjs.c** - Command-line interpreter with REPL
- **qjsc.c** - JavaScript to bytecode compiler
- **repl.c** - Interactive REPL implementation

### MicroPython Components
- **Embedding API**: Official micropython/examples/embedding/ approach
- **Static Library**: libmicropython_embed.a with full language support
- **Headers**: micropython_embed.h for C API access
- **Output Capture**: Custom stdout override for print statement capture

### Runtime Architecture
- **JavaScript**: JSRuntime/JSContext/JSValue with garbage collection
- **Python**: mp_embed_init/exec_str/deinit with heap management
- **Unified Interface**: Consistent Nim wrappers with automatic memory management
- **Multi-Engine**: Both engines can coexist in same application

### Build System
- **QuickJS**: Traditional Makefile with multiple configuration options
- **MicroPython**: Embedding-specific build using micropython_embed.mk
- **Nimble Integration**: Automated download, build, and cleanup tasks
- **Cross-platform**: macOS and Linux support with proper linking

## Development Notes

### Burrito Wrapper Development
- Main modules: `src/burrito/qjs.nim` (QuickJS), `src/burrito/mpy.nim` (MicroPython)
- Unified module: `src/burrito.nim` - Re-exports both engines
- Build configuration: `nim.cfg` - Outputs to build/bin/
- Run examples: `nimble example` or `nim r examples/qjs/basic_example.nim`
- MicroPython examples: Use nimble tasks (e.g., `nimble example_mpy`)
- REPL development: `nimble repl_js` for interactive testing
- Testing: `nimble test_report` for comprehensive test suite
- Import patterns: `import burrito/qjs` or `import burrito/mpy` or `import burrito`

### Working Directory
- QuickJS build commands should be run from the `quickjs/` subdirectory
- MicroPython build commands should be run from the `micropython/examples/embedding/` subdirectory
- Nim/Burrito commands should be run from the repository root
- Build outputs go to `build/bin/` and `build/nimcache/`

### Documentation System
- API docs: Generated via `nimble docs` to `docs/burrito.html`
- Landing page: Modern `docs/index.html` with sunset gradient theme
- GitHub Pages: Automatically serves from docs/ directory
- Local serving: `nimble serve_docs` at http://localhost:8000

### Testing Strategy
- Unit tests: `tests/qjs/test_basic.nim` for core functionality
- Interactive tests: `tests/qjs/test_repl.exp` and `tests/mpy/test_repl.exp` using expect
- Integration tests: All examples serve as integration tests
- Memory management: Automatic cleanup testing for both engines

### MicroPython Build Configuration
- Uses official embedding API (not Unix port)
- **Static Library**: `micropython/examples/embedding/libmicropython_embed.a`
- **Headers**: `micropython/examples/embedding/micropython_embed/`
- **Build Command**: `cd micropython/examples/embedding && make -f micropython_embed.mk`
- **Library Size**: ~450KB with full ROM_LEVEL_EVERYTHING features
- **No external dependencies**: Self-contained static linking

### REPL Implementation
- **QuickJS**: Uses official QuickJS `repl.js` for full feature support
- **MicroPython**: Basic REPL implementation in `examples/mpy/repl_mpy.nim`
- Syntax highlighting and command history (QuickJS)
- Custom Nim function exposure via `registerFunction` (QuickJS)
- Event loop processing via `processStdLoop()` and `runPendingJobs()` (QuickJS)

### Static Compilation
QuickJS supports compiling JavaScript to standalone executables using `qjsc` with various optimization flags for minimal runtime dependencies.

### Module System
- **QuickJS**: Supports both CommonJS-style modules and ES6 modules
- **MicroPython**: Built-in modules available depending on ROM level configuration
- C extension modules via shared libraries (QuickJS)
- Module loading via `evalModule()` for ES6 imports (QuickJS)
- Standard library modules (std, os) available with appropriate configs (QuickJS)

### Error Handling
- **QuickJS**: JavaScript exceptions converted to Nim exceptions
- **MicroPython**: Python exceptions captured in output strings
- **Memory Safety**: Automatic cleanup on errors for both engines
- **Resource Management**: Proper cleanup even when exceptions occur

### Performance Considerations
- **Startup Time**: QuickJS ~0.5ms, MicroPython ~1ms for instance creation
- **Memory Usage**: QuickJS minimal, MicroPython 64KB default heap
- **Execution Speed**: Both engines optimized for embedding scenarios
- **Binary Size**: QuickJS ~1.2MB, MicroPython ~450KB static library overhead
