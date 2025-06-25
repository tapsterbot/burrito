# MicroPython ROM Configuration Levels Analysis

Based on the analysis of the MicroPython codebase, here's a comprehensive overview of the different MICROPY_CONFIG_ROM_LEVEL options and their features.

## ROM Level Definitions

The ROM levels are defined in `py/mpconfig.h` with the following numeric values:

```c
// Disable all optional features (i.e. minimal port).
#define MICROPY_CONFIG_ROM_LEVEL_MINIMUM (0)
// Only enable core features (constrained flash, e.g. STM32L072)
#define MICROPY_CONFIG_ROM_LEVEL_CORE_FEATURES (10)
// Enable most common features (small on-device flash, e.g. STM32F411)
#define MICROPY_CONFIG_ROM_LEVEL_BASIC_FEATURES (20)
// Enable convenience features (medium on-device flash, e.g. STM32F405)
#define MICROPY_CONFIG_ROM_LEVEL_EXTRA_FEATURES (30)
// Enable all common features (large/external flash, rp2, unix)
#define MICROPY_CONFIG_ROM_LEVEL_FULL_FEATURES (40)
// Enable everything (e.g. coverage)
#define MICROPY_CONFIG_ROM_LEVEL_EVERYTHING (50)
```

## Feature Matrix by ROM Level

### CORE_FEATURES Level (10) and above
Basic essential features for constrained environments:

- `MICROPY_GC_ALLOC_THRESHOLD` - Garbage collection allocation threshold
- `MICROPY_ENABLE_COMPILER` - Python bytecode compiler
- `MICROPY_COMP_CONST_FOLDING` - Constant folding optimization
- `MICROPY_COMP_CONST_TUPLE` - Constant tuple optimization
- `MICROPY_COMP_CONST_LITERAL` - Constant literal optimization
- `MICROPY_COMP_CONST` - General constant optimization
- `MICROPY_COMP_DOUBLE_TUPLE_ASSIGN` - Double tuple assignment
- `MICROPY_ENABLE_EXTERNAL_IMPORT` - External module import support
- `MICROPY_CPYTHON_COMPAT` - CPython compatibility features
- `MICROPY_FULL_CHECKS` - Full runtime checks
- `MICROPY_MODULE_GETATTR` - Module attribute access
- `MICROPY_BUILTIN_METHOD_CHECK_SELF_ARG` - Built-in method self argument checking
- `MICROPY_MULTIPLE_INHERITANCE` - Multiple inheritance support
- `MICROPY_PY_ASYNC_AWAIT` - async/await syntax
- `MICROPY_PY_ASSIGN_EXPR` - Assignment expressions (:= operator)
- `MICROPY_PY_GENERATOR_PEND_THROW` - Generator pending throw
- `MICROPY_PY_BUILTINS_STR_COUNT` - String count method

### BASIC_FEATURES Level (20) and above
Additional features for small on-device flash:

- `MICROPY_PY_BUILTINS_NEXT2` - Enhanced next() builtin
- `MICROPY_MODULE___ALL__` - Module `__all__` support
- `MICROPY_PY_TIME` - Time module

### EXTRA_FEATURES Level (30) and above
Convenience features for medium flash environments:

- `MICROPY_COMP_MODULE_CONST` - Module constant optimization
- `MICROPY_COMP_TRIPLE_TUPLE_ASSIGN` - Triple tuple assignment
- `MICROPY_COMP_RETURN_IF_EXPR` - Return if expression
- `MICROPY_OPT_LOAD_ATTR_FAST_PATH` - Fast attribute loading
- `MICROPY_OPT_MAP_LOOKUP_CACHE` - Map lookup caching
- `MICROPY_OPT_MPZ_BITWISE` - MPZ bitwise operations optimization
- `MICROPY_OPT_MATH_FACTORIAL` - Math factorial optimization
- `MICROPY_ENABLE_FINALISER` - Object finalizers
- `MICROPY_STACK_CHECK` - Stack overflow checking
- `MICROPY_KBD_EXCEPTION` - Keyboard interrupt exception
- `MICROPY_HELPER_REPL` - REPL helper functions
- `MICROPY_REPL_EMACS_KEYS` - Emacs-style REPL key bindings
- `MICROPY_REPL_AUTO_INDENT` - Automatic indentation in REPL
- `MICROPY_ENABLE_SOURCE_LINE` - Source line tracking
- `MICROPY_STREAMS_NON_BLOCK` - Non-blocking streams
- `MICROPY_MODULE_ATTR_DELEGATION` - Module attribute delegation
- `MICROPY_MODULE_BUILTIN_INIT` - Built-in module initialization
- `MICROPY_CAN_OVERRIDE_BUILTINS` - Allow overriding built-ins

### FULL_FEATURES Level (40) and above
All common features for large/external flash:

- `MICROPY_PY_FUNCTION_ATTRS_CODE` - Function code attributes
- `MICROPY_PY_DEFLATE_COMPRESS` - Deflate compression support

### EVERYTHING Level (50) - Additional Features
Features exclusive to the highest configuration level:

#### REPL Enhancements
- `MICROPY_REPL_EMACS_WORDS_MOVE` - Advanced Emacs word movement in REPL
- `MICROPY_REPL_EMACS_EXTRA_WORDS_MOVE` - Extra Emacs word movement features

#### Advanced Data Types
- `MICROPY_FLOAT_HIGH_QUALITY_HASH` - High-quality float hashing
- `MICROPY_PY_BUILTINS_MEMORYVIEW_ITEMSIZE` - Memoryview itemsize support
- `MICROPY_PY_BUILTINS_RANGE_BINOP` - Range binary operations
- `MICROPY_PY_ALL_INPLACE_SPECIAL_METHODS` - All in-place special methods

#### Module System
- `MICROPY_MODULE_BUILTIN_SUBPACKAGES` - Built-in subpackage support

#### Collections and Data Structures
- `MICROPY_PY_COLLECTIONS_NAMEDTUPLE__ASDICT` - namedtuple._asdict() method
- `MICROPY_PY_MARSHAL` - Marshal module for serialization

#### I/O and System
- `MICROPY_PY_IO_BUFFEREDWRITER` - Buffered writer I/O
- `MICROPY_PY_SYS_INTERN` - sys.intern() function
- `MICROPY_PY_SYS_GETSIZEOF` - sys.getsizeof() function
- `MICROPY_PY_SYS_TRACEBACKLIMIT` - sys.tracebacklimit support
- `MICROPY_PY_MICROPYTHON_HEAP_LOCKED` - Heap lock functionality

#### Regular Expressions
- `MICROPY_PY_RE_DEBUG` - Regular expression debugging
- `MICROPY_PY_RE_MATCH_GROUPS` - Match groups support
- `MICROPY_PY_RE_MATCH_SPAN_START_END` - Match span, start, and end methods

## Usage Examples

### Minimal Configuration (e.g., minimal port)
```c
#define MICROPY_CONFIG_ROM_LEVEL (MICROPY_CONFIG_ROM_LEVEL_MINIMUM)
```

### Typical Embedded Configuration (e.g., ESP32)
```c
#define MICROPY_CONFIG_ROM_LEVEL (MICROPY_CONFIG_ROM_LEVEL_EXTRA_FEATURES)
```

### Full Development/Testing Configuration (e.g., Unix coverage)
```c
#define MICROPY_CONFIG_ROM_LEVEL (MICROPY_CONFIG_ROM_LEVEL_EVERYTHING)
```

## Key Differences: EVERYTHING vs EXTRA_FEATURES

The EVERYTHING level adds approximately 18 additional features beyond EXTRA_FEATURES:

1. **Enhanced REPL functionality** with advanced Emacs-style editing
2. **More comprehensive built-in type support** (memoryview, range operations)
3. **Complete special method support** for all in-place operations
4. **Advanced system introspection** (getsizeof, intern, tracebacklimit)
5. **Full regular expression debugging** and advanced matching
6. **Marshal module** for object serialization
7. **Buffered I/O writer** support
8. **High-quality float hashing** algorithms
9. **Built-in subpackage support** for module organization
10. **Advanced heap management** with locking mechanisms

These additional features are primarily useful for:
- Development and debugging environments
- Full CPython compatibility testing
- Advanced applications requiring complete Python feature sets
- Educational or research platforms where all Python features are needed

The EVERYTHING level is typically used in Unix builds for testing coverage and development, rather than in resource-constrained embedded environments.