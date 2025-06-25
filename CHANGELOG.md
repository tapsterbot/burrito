# Changelog

## [0.3.0] - 2025-06-25

### Added
- **MicroPython integration**: Full Python 3 support via embedding API
- **Unified import patterns**: `import burrito`, `import burrito/qjs`, `import burrito/mpy`
- **Multi-engine support**: Run JavaScript and Python in the same application
- **More examples**: 8 MicroPython examples, dual-engine example
- **API documentation**: Separate docs for both engines (qjs.html, mpy.html)
- **Test framework**: Interactive REPL tests for both engines using expect

### Changed
- **Breaking**: Reorganized file structure - examples and tests now in subdirectories
  - Examples: `examples/qjs/`, `examples/mpy/`, `examples/multi/`
  - Tests: `tests/qjs/`, `tests/mpy/`
- **Breaking**: Main wrapper modules moved to `src/burrito/` directory
- Improved build system with MicroPython-specific tasks

### MicroPython Features
- ROM_LEVEL_EVERYTHING configuration for maximum Python compatibility
- 64KB default heap with configurable size
- Output capture for print statements
- Multi-line code execution support
- Variable persistence across eval() calls

### Migration from 0.2.0
```nim
# File paths have changed:
# Before: examples/basic_example.nim
# After:  examples/qjs/basic_example.nim

# Import patterns (all work):
import burrito           # Both engines
import burrito/qjs       # QuickJS only
import burrito/mpy       # MicroPython only
```

## [0.2.0] - 2025-06-21

### Changed
- **Native C bridging**: Direct JavaScript-to-Nim function calls (no more string parsing)
- **Breaking**: Functions now take `ctx: ptr JSContext` and return `JSValue`
- **Breaking**: Removed `setupNimBridge()` - no setup needed
- Support for functions with 0-3 arguments plus variadic functions

### Migration from 0.1.0
```nim
# Before
proc getMessage(): string = "Hello!"
js.setupNimBridge()

# After
proc getMessage(ctx: ptr JSContext): JSValue = nimStringToJS(ctx, "Hello!")
# No setup needed
```

## [0.1.0] - 2025-06-20

### Added
- Initial QuickJS wrapper
- Basic JavaScript evaluation
- String-based function bridging
