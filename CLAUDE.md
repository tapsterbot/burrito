# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains **Burrito**, a Nim wrapper for the QuickJS JavaScript engine (version 2025-04-26). QuickJS is a small and embeddable JavaScript engine that supports ES2023 specification. QuickJS is a C implementation that can be compiled to native executables and provides both a JavaScript interpreter (`qjs`) and compiler (`qjsc`).

The Burrito wrapper is located in `src/burrito.nim` and provides a lightweight, idiomatic Nim interface to QuickJS.

## Build Commands

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

### Burrito Wrapper
- Main module: `src/burrito.nim`
- Examples: `examples/basic_example.nim`, `examples/advanced_example.nim`
- Build wrapper: `nim c src/burrito.nim`
- Run examples: `nimble example` or `nim c -r examples/basic_example.nim`

### Working Directory
QuickJS build commands should be run from the `quickjs/` subdirectory, not the repository root.
Nim/Burrito commands should be run from the repository root.

### Static Compilation
QuickJS supports compiling JavaScript to standalone executables using `qjsc` with various optimization flags for minimal runtime dependencies.

### Module System
Supports both CommonJS-style modules and ES6 modules, with C extension modules via shared libraries.