## MicroPython wrapper for Nim using the official embedding API
##
## This module provides a clean, idiomatic Nim interface to MicroPython
## using the official embedding API from micropython/examples/embedding.
##
## Basic usage:
## ```nim
## import burrito/mpy
##
## var py = newMicroPython()
## defer: py.close()
## 
## echo py.eval("print(2 + 3)")  # Output: 5
## echo py.eval("'Hello ' + 'World!'")  # Output: Hello World!
## ```
##
## REPL usage:
## ```nim
## import burrito/mpy
##
## var py = newMicroPython()
## defer: py.close()
## echo "🌯 Burrito - MicroPython wrapper"
## py.startRepl()  # Interactive REPL
## ```

import std/[strutils]

const
  DEFAULT_HEAP_SIZE = 64 * 1024  # 64KB heap for MicroPython

# MicroPython embedding API bindings
{.push header: "port/micropython_embed.h".}
proc mp_embed_init(gc_heap: pointer, gc_heap_size: csize_t, stack_top: pointer) {.importc.}
proc mp_embed_deinit() {.importc.}
proc mp_embed_exec_str(src: cstring) {.importc.}
proc mp_embed_exec_mpy(mpy: ptr uint8, len: csize_t) {.importc.}
{.pop.}

# Global state for output capture
var capturedOutput: string = ""

# Custom output function to capture MicroPython print statements
proc mp_hal_stdout_tx_strn_cooked(str: cstring, len: csize_t) {.exportc.} =
  ## Override MicroPython's output function to capture printed text
  if len > 0:
    let s = newString(len)
    copyMem(addr s[0], str, len)
    capturedOutput.add(s)

# MicroPython instance type
type
  MicroPython* = ref object
    heap: seq[byte]
    initialized: bool

proc newMicroPython*(heapSize: int = DEFAULT_HEAP_SIZE): MicroPython =
  ## Create a new MicroPython instance with the specified heap size
  result = MicroPython(
    heap: newSeq[byte](heapSize),
    initialized: false
  )
  
  # Initialize MicroPython with our heap
  var stackTop: int
  mp_embed_init(addr result.heap[0], heapSize.csize_t, addr stackTop)
  result.initialized = true

proc close*(py: MicroPython) =
  ## Clean up the MicroPython instance
  if py.initialized:
    mp_embed_deinit()
    py.initialized = false

proc eval*(py: MicroPython, code: string): string =
  ## Evaluate Python code and return any printed output
  if not py.initialized:
    raise newException(ValueError, "MicroPython instance not initialized")
  
  # Clear previous output
  capturedOutput = ""
  
  # Execute the Python code
  mp_embed_exec_str(code.cstring)
  
  # Return captured output
  result = capturedOutput.strip()

proc evalBytecode*(py: MicroPython, bytecode: openArray[uint8]): string =
  ## Execute pre-compiled MicroPython bytecode
  if not py.initialized:
    raise newException(ValueError, "MicroPython instance not initialized")
  
  # Clear previous output
  capturedOutput = ""
  
  # Execute the bytecode
  mp_embed_exec_mpy(unsafeAddr bytecode[0], bytecode.len.csize_t)
  
  # Return captured output
  result = capturedOutput.strip()

proc startRepl*(py: MicroPython) =
  ## Start an interactive MicroPython REPL
  if not py.initialized:
    raise newException(ValueError, "MicroPython instance not initialized")
  
  echo "MicroPython REPL (embedding mode)"
  echo "Use Ctrl+D to exit"
  echo ""
  
  # Simple REPL loop
  while true:
    try:
      write(stdout, ">>> ")
      let line = readLine(stdin)
      
      if line.len == 0:
        continue
        
      # Clear previous output
      capturedOutput = ""
      
      # Execute the line
      mp_embed_exec_str(line.cstring)
      
      # Print any output
      if capturedOutput.len > 0:
        echo capturedOutput.strip()
        
    except EOFError:
      # Ctrl+D pressed - exit REPL
      echo ""
      break
    except:
      echo "Error: ", getCurrentExceptionMsg()

# Type conversion helpers (for future use)
proc toNimString*(py: MicroPython, val: pointer): string =
  ## Convert MicroPython value to Nim string (placeholder)
  result = "MicroPython value"

proc nimStringToMP*(py: MicroPython, s: string): pointer =
  ## Convert Nim string to MicroPython value (placeholder)
  result = nil