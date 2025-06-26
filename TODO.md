# Burrito - TODO List

This document tracks cleanup items and future enhancements for the Burrito project.

## Next Release (v0.3.1) - Priority 1

### Documentation
- [ ] **README.md improvements**
  - Add MicroPython quick start section
  - Update file paths in examples
  - Add dual-engine usage example

### Testing & CI
- [ ] **Expand MicroPython test coverage**
  - Add unit tests beyond REPL testing
  - Test error handling and edge cases
  - Memory leak testing

- [ ] **GitHub Actions CI**
  - Automated builds for both engines
  - Cross-platform testing (macOS, Linux)
  - Example validation

## Future Enhancements (v0.4.0) - Priority 2

### MicroPython Features
- [ ] **Nim function registration**
  - registerFunction() API like QuickJS
  - Type conversion utilities
  - Error propagation

- [ ] **Enhanced REPL**
  - Syntax highlighting
  - Command history
  - Tab completion

### Advanced Integration
- [ ] **Cross-engine communication**
  - Data sharing between JS and Python
  - Unified event system
  - Shared memory buffers

- [ ] **Performance optimization**
  - Bytecode caching for MicroPython
  - Shared runtime optimization
  - Memory pool management

### Build System
- [ ] **Package management**
  - Nimble package publication
  - Dependency version locking
  - Pre-built binaries

## Long-term Vision - Priority 3

### Language Support
- [ ] **Additional engines**
  - Lua integration
  - Duktape (JS) integration
  - Janet integration
  - PicoRuby?

### Developer Experience
- [ ] **IDE integration**
  - VSCode extension?
  - Syntax highlighting for embedded code
  - Debugger support

### Production Features
- [ ] **Security sandboxing**
  - Resource limits
  - API restrictions
  - Secure eval modes

## Development Guidelines

When working on these items:

1. **Maintain API consistency** between engines
2. **Test on multiple platforms**
3. **Update documentation** as you go
4. **Consider backwards compatibility**
5. **Follow existing code patterns**

## Notes

- Priority 1 items should be completed before next release
- Check GitHub issues for community requests
- This list is updated as work progresses
