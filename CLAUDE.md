# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains **Burrito**, a Nim wrapper for the QuickJS JavaScript engine (version 2025-04-26). QuickJS is a small and embeddable JavaScript engine that supports ES2023 specification.

**🎯 THE KILLER FEATURE:** Burrito's primary value proposition is the ability to embed a complete JavaScript REPL with syntax highlighting, command history, and custom Nim function exposure into your applications with just a few lines of code.

The Burrito wrapper is located in `src/burrito.nim` and provides a comprehensive, idiomatic Nim interface to QuickJS with automatic memory management and extensive API coverage.

## Quick Start

### Installation
```bash
# Clone and setup Burrito
git clone https://github.com/tapsterbot/burrito.git
cd burrito

# Download and build QuickJS
nimble get_quickjs
nimble build_quickjs

# Test installation
nimble example
```

### Basic Usage Example
```nim
import burrito

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

### Embedded REPL Example
```nim
import burrito

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
nimble example          # Run basic example
nimble examples         # Run all examples  
nimble repl            # Start REPL with custom Nim functions
nimble test_report     # Run test suite with summary
nimble compile_repl_bytecode  # Compile repl.js to bytecode
```

### QuickJS Management
```bash
nimble get_quickjs     # Download QuickJS source
nimble build_quickjs   # Build QuickJS library
nimble delete_quickjs  # Remove QuickJS source
nimble clean_all       # Clean all build artifacts
```

### Documentation
```bash
nimble docs           # Generate API documentation
nimble serve_docs     # Serve docs locally at http://localhost:8000
```

## Project Structure

### Core Files
- `src/burrito.nim` - Main wrapper library with comprehensive QuickJS bindings
- `burrito.nimble` - Package configuration with all development tasks
- `nim.cfg` - Build configuration (outputs to build/bin/)
- `docs/index.html` - Modern landing page with sunset gradient theme
- `docs/burrito.html` - Generated API documentation

### Examples
- `examples/basic_example.nim` - Simple JavaScript evaluation
- `examples/call_nim_from_js.nim` - Exposing Nim functions to JavaScript
- `examples/bytecode_basic.nim` - Basic bytecode compilation and execution
- `examples/bytecode_comprehensive.nim` - Complete bytecode feature showcase
- `examples/repl.nim` - Standalone REPL implementation
- `examples/repl_with_nim_function.nim` - REPL with one custom function (simple)
- `examples/repl_with_nim_functions.nim` - REPL with custom functions (longer)
- `examples/repl_bytecode.nim` - REPL from embedded bytecode (no external files)
- `examples/advanced_native_bridging.nim` - Complex type marshaling
- `examples/comprehensive_features.nim` - Feature showcase
- `examples/idiomatic_patterns.nim` - Idiomatic usage patterns
- `examples/type_system.nim` - Type system examples
- `examples/module_example.nim` - ES6 module usage

### Testing
- `tests/test_basic.nim` - Basic functionality tests
- `tests/test_repl.nim` - REPL testing wrapper (includes bytecode REPL tests)
- `tests/test_repl.exp` - Expect script for interactive REPL testing
- `tests/test_repl_bytecode.exp` - Expect script for bytecode REPL testing

## Key Features

### Automatic Memory Management
- JSValue arguments are automatically freed by function trampolines
- Scoped templates for safe property and array access
- No manual JS_FreeValue calls needed for function parameters

### Idiomatic Nim Interface
- Type-safe conversions between Nim and JavaScript types
- Generic property accessors with automatic type detection
- Method-style syntax for common operations

### Configuration Options
- `defaultConfig()` - Basic JavaScript engine
- `configWithStdLib()` - Includes std module
- `configWithOsLib()` - Includes os module  
- `configWithBothLibs()` - Full standard library support

### Function Registration
- Support for 0-3 fixed arguments plus variadic functions
- Automatic exception handling and conversion
- Function overloading by argument count

### Bytecode Support
- Compile JavaScript to bytecode with `compileToBytecode()`
- Execute bytecode with `evalBytecode()` - faster startup, no compilation
- Works with both isolated (defaultConfig) and full-featured (configWithBothLibs) configurations
- Smart detection: automatically chooses optimal execution path
- Pre-compile REPL to bytecode for embedding in binary
- No external file dependencies when using bytecode
- Variables persist across bytecode executions (global scope preservation)

## QuickJS Build Commands

### Basic Build
```bash
cd quickjs
make
```

This builds the main executables:
- `qjs` - JavaScript interpreter
- `qjsc` - JavaScript compiler  
- `libquickjs.a` - Static library
- Examples and shared libraries (if supported)

### Clean Build
```bash
cd quickjs
make clean
```

### Testing
```bash
cd quickjs
make test          # Run built-in tests
make microbench    # Run microbenchmarks
make test2         # Run Test262 suite (if installed)
make testall       # Run all available tests
```

### Documentation
```bash
cd quickjs
make build_doc     # Build PDF and HTML documentation
```

### Installation
```bash
cd quickjs
make install PREFIX=/usr/local
```

## Architecture

### Core Components

- **quickjs.c/quickjs.h** - Main JavaScript engine implementation
- **quickjs-libc.c/quickjs-libc.h** - Standard library bindings
- **qjs.c** - Command-line interpreter with REPL
- **qjsc.c** - JavaScript to bytecode compiler
- **repl.c** - Interactive REPL implementation

### Runtime Architecture

- **JSRuntime** - JavaScript runtime environment
- **JSContext** - JavaScript execution context
- **JSValue** - JavaScript value representation
- Garbage collector with reference counting and cycle detection
- Bytecode compilation and execution engine

### Library Structure

- **cutils.c/cutils.h** - C utility functions
- **libregexp.c/libregexp.h** - Regular expression engine
- **libunicode.c/libunicode.h** - Unicode support
- **dtoa.c/dtoa.h** - Double to ASCII conversion

### Build System

The Makefile supports multiple configurations:
- Cross-compilation (CONFIG_WIN32, CROSS_PREFIX)
- Optimization levels (CONFIG_LTO, CONFIG_M32)
- Sanitizers (CONFIG_ASAN, CONFIG_MSAN, CONFIG_UBSAN)
- Platform-specific builds (CONFIG_DARWIN, CONFIG_FREEBSD)

### Examples and Testing

- **examples/** - Static compilation examples, C modules
- **tests/** - JavaScript test suites
- **Test262** support for ECMAScript conformance testing

## Development Notes

### Burrito Wrapper Development
- Main module: `src/burrito.nim` - Comprehensive QuickJS bindings
- Build configuration: `nim.cfg` - Outputs to build/bin/
- Run examples: `nimble example` or `nim r examples/basic_example.nim`
- REPL development: `nimble repl` for interactive testing
- Testing: `nimble test_report` for comprehensive test suite

### Working Directory
- QuickJS build commands should be run from the `quickjs/` subdirectory
- Nim/Burrito commands should be run from the repository root
- Build outputs go to `build/bin/` and `build/nimcache/`

### Documentation System
- API docs: Generated via `nimble docs` to `docs/burrito.html`
- Landing page: Modern `docs/index.html` with sunset gradient theme
- GitHub Pages: Automatically serves from docs/ directory
- Local serving: `nimble serve_docs` at http://localhost:8000

### Testing Strategy
- Unit tests: `tests/test_basic.nim` for core functionality
- Interactive tests: `tests/test_repl.exp` using expect for REPL testing
- Integration tests: All examples serve as integration tests
- Memory management: Automatic JSValue cleanup testing

### REPL Implementation
- Uses official QuickJS `repl.js` for full feature support
- Syntax highlighting and command history included
- Custom Nim function exposure via `registerFunction`
- Event loop processing via `processStdLoop()` and `runPendingJobs()`
- Examples: `examples/repl.nim` and `examples/repl_with_nim_functions.nim`

### Static Compilation
QuickJS supports compiling JavaScript to standalone executables using `qjsc` with various optimization flags for minimal runtime dependencies.

### Module System
- Supports both CommonJS-style modules and ES6 modules
- C extension modules via shared libraries
- Module loading via `evalModule()` for ES6 imports
- Standard library modules (std, os) available with appropriate configs