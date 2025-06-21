# Changelog

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