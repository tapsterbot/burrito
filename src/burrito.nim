## Burrito - Multi-language scripting engine for Nim
##
## This is the main Burrito module that provides access to both QuickJS and MicroPython
## wrappers with a unified interface.
##
## Basic usage:
## ```nim
## import burrito           # Import everything
## import burrito/qjs       # Import just QuickJS
## import burrito/mpy       # Import just MicroPython
## ```

# Re-export everything from both submodules
import burrito/qjs
import burrito/mpy

export qjs, mpy