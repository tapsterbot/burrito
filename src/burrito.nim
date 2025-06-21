## Burrito - QuickJS Nim Wrapper
## 
## A lightweight wrapper for the QuickJS JavaScript engine.
## This module provides basic functionality to create JS contexts,
## evaluate JavaScript code, and expose Nim functions to JavaScript.

import std/tables

const 
  quickjsPath = when defined(windows): 
    "quickjs/libquickjs.a"
  else: 
    "quickjs/libquickjs.a"

{.passL: quickjsPath.}
{.passL: "-lm".}

type
  JSRuntime* {.importc: "struct JSRuntime", header: "quickjs/quickjs.h".} = object
  JSContext* {.importc: "struct JSContext", header: "quickjs/quickjs.h".} = object
  JSAtom* = uint32
  JSClassID* = uint32
  
  # Pointer types for runtime and context
  JSRuntimePtr* = ptr JSRuntime
  JSContextPtr* = ptr JSContext
  
  # Import JSValue as opaque struct from C  
  JSValue* {.importc, header: "quickjs/quickjs.h".} = object
  JSValueConst* = JSValue

  # Function pointer type for JavaScript C functions
  JSCFunction* = proc(ctx: ptr JSContext, thisVal: JSValueConst, argc: cint, argv: ptr JSValueConst): JSValue {.cdecl.}
  JSCFunctionMagic* = proc(ctx: ptr JSContext, thisVal: JSValueConst, argc: cint, argv: ptr JSValueConst, magic: cint): JSValue {.cdecl.}
  JSCFunctionData* = proc(ctx: ptr JSContext, thisVal: JSValueConst, argc: cint, argv: ptr JSValueConst, magic: cint, data: ptr JSValue): JSValue {.cdecl.}

# Core QuickJS API bindings
{.push importc, header: "quickjs/quickjs.h".}

proc JS_NewRuntime*(): ptr JSRuntime
proc JS_FreeRuntime*(rt: ptr JSRuntime)
proc JS_NewContext*(rt: ptr JSRuntime): ptr JSContext
proc JS_FreeContext*(ctx: ptr JSContext)

# Value operations
proc JS_NewInt32*(ctx: ptr JSContext, val: int32): JSValue
proc JS_NewFloat64*(ctx: ptr JSContext, val: float64): JSValue
proc JS_NewStringLen*(ctx: ptr JSContext, str: cstring, len: csize_t): JSValue
proc JS_NewBool*(ctx: ptr JSContext, val: cint): JSValue
proc JS_NewObject*(ctx: ptr JSContext): JSValue

# Getting values from JSValue
proc JS_ToInt32*(ctx: ptr JSContext, pres: ptr int32, val: JSValueConst): cint
proc JS_ToFloat64*(ctx: ptr JSContext, pres: ptr float64, val: JSValueConst): cint
proc JS_ToCString*(ctx: ptr JSContext, val: JSValueConst): cstring
proc JS_FreeCString*(ctx: ptr JSContext, str: cstring)
proc JS_ToBool*(ctx: ptr JSContext, val: JSValueConst): cint

# Function and property operations
proc JS_NewCFunction*(ctx: ptr JSContext, `func`: JSCFunction, name: cstring, length: cint): JSValue
proc JS_NewCFunction2*(ctx: ptr JSContext, `func`: JSCFunction, name: cstring, length: cint, cproto: cint, magic: cint): JSValue
proc JS_NewCFunctionMagic*(ctx: ptr JSContext, `func`: JSCFunctionMagic, name: cstring, length: cint, cproto: cint, magic: cint): JSValue
proc JS_NewCFunctionData*(ctx: ptr JSContext, `func`: JSCFunctionData, length: cint, magic: cint, dataLen: cint, data: ptr JSValue): JSValue
proc JS_DefinePropertyValueStr*(ctx: ptr JSContext, thisObj: JSValueConst, prop: cstring, val: JSValue, flags: cint): cint

# Context opaque data operations
proc JS_SetContextOpaque*(ctx: ptr JSContext, opaque: pointer)
proc JS_GetContextOpaque*(ctx: ptr JSContext): pointer

# Evaluation
proc JS_Eval*(ctx: ptr JSContext, input: cstring, inputLen: csize_t, filename: cstring, evalFlags: cint): JSValue

# Memory management
proc JS_FreeValue*(ctx: ptr JSContext, v: JSValue)
proc JS_DupValue*(ctx: ptr JSContext, v: JSValueConst): JSValue

# Exception handling
proc JS_IsException*(v: JSValueConst): cint
proc JS_GetException*(ctx: ptr JSContext): JSValue

# Global object
proc JS_GetGlobalObject*(ctx: ptr JSContext): JSValue

{.pop.}

# JavaScript evaluation flags
const
  JS_EVAL_TYPE_GLOBAL* = 0
  JS_EVAL_TYPE_MODULE* = 1
  JS_EVAL_FLAG_STRICT* = (1 shl 3)
  JS_EVAL_FLAG_STRIP* = (1 shl 5)

# Property flags  
const
  JS_PROP_CONFIGURABLE* = (1 shl 0)
  JS_PROP_WRITABLE* = (1 shl 1)
  JS_PROP_ENUMERABLE* = (1 shl 2)

# C Function types
const
  JS_CFUNC_generic* = 0
  JS_CFUNC_generic_magic* = 1

# Constants as procs that call the C macros
proc jsUndefined*(ctx: ptr JSContext): JSValue =
  ## Return JavaScript undefined value
  {.emit: "return JS_UNDEFINED;".}

proc jsNull*(ctx: ptr JSContext): JSValue =
  ## Return JavaScript null value
  {.emit: "return JS_NULL;".}

proc jsTrue*(ctx: ptr JSContext): JSValue =
  ## Return JavaScript true value
  {.emit: "return JS_TRUE;".}

proc jsFalse*(ctx: ptr JSContext): JSValue =
  ## Return JavaScript false value
  {.emit: "return JS_FALSE;".}

# High-level wrapper types
type
  # Nim function signatures that can be registered (context-aware)
  # 
  # IMPORTANT: JSValue Memory Management
  # All JSValue arguments passed to these functions are duplicated (JS_DupValue)
  # and the user's Nim function is responsible for calling JS_FreeValue on them
  # when they are no longer needed, unless their ownership is transferred to
  # another QuickJS object (e.g., by storing them in a JS object or array).
  #
  # Example:
  #   proc myFunc(ctx: ptr JSContext, arg: JSValue): JSValue =
  #     let str = toNimString(ctx, arg)
  #     JS_FreeValue(ctx, arg)  # Must free the argument
  #     return nimStringToJS(ctx, "processed: " & str)
  #
  NimFunction0* = proc(ctx: ptr JSContext): JSValue {.nimcall.}
  NimFunction1* = proc(ctx: ptr JSContext, arg: JSValue): JSValue {.nimcall.}
  NimFunction2* = proc(ctx: ptr JSContext, arg1, arg2: JSValue): JSValue {.nimcall.}
  NimFunction3* = proc(ctx: ptr JSContext, arg1, arg2, arg3: JSValue): JSValue {.nimcall.}
  NimFunctionVariadic* = proc(ctx: ptr JSContext, args: seq[JSValue]): JSValue {.nimcall.}
  
  # Function registry entry
  NimFunctionKind* = enum
    nimFunc0 = 0, nimFunc1, nimFunc2, nimFunc3, nimFuncVar
    
  NimFunctionEntry* = object
    case kind*: NimFunctionKind
    of nimFunc0: func0*: NimFunction0
    of nimFunc1: func1*: NimFunction1
    of nimFunc2: func2*: NimFunction2
    of nimFunc3: func3*: NimFunction3
    of nimFuncVar: funcVar*: NimFunctionVariadic
    
  # Context data to pass to C callbacks
  BurritoContextData* = object
    functions*: Table[cint, NimFunctionEntry]
    context*: ptr JSContext
  
  QuickJS* = object
    ## QuickJS wrapper object containing runtime and context
    ## 
    ## ⚠️  THREAD SAFETY WARNING:
    ## QuickJS instances are NOT thread-safe. You must either:
    ## 1. Access each QuickJS instance from only one thread (recommended), OR
    ## 2. Use external synchronization (Lock/Mutex) around ALL QuickJS method calls
    ##    if sharing an instance across threads
    ##
    ## Each thread should ideally have its own QuickJS instance for best performance.
    runtime*: ptr JSRuntime
    context*: ptr JSContext
    contextData*: ptr BurritoContextData
    nextFunctionId*: cint
    
  JSException* = object of CatchableError
    jsValue*: JSValue

# Value conversion helpers
proc toNimString*(ctx: ptr JSContext, val: JSValueConst): string =
  let cstr = JS_ToCString(ctx, val)
  if cstr != nil:
    result = $cstr
    JS_FreeCString(ctx, cstr)  # Important: free the C string
  else:
    result = ""

proc toNimInt*(ctx: ptr JSContext, val: JSValueConst): int32 =
  var res: int32
  if JS_ToInt32(ctx, addr res, val) != 0: # Check for error
    # Consider getting more specific error info if possible, or a generic conversion error
    raise newException(JSException, "Failed to convert JSValue to int32")
  result = res

proc toNimFloat*(ctx: ptr JSContext, val: JSValueConst): float64 =
  var res: float64
  if JS_ToFloat64(ctx, addr res, val) != 0: # Check for error
    raise newException(JSException, "Failed to convert JSValue to float64")
  result = res

proc toNimBool*(ctx: ptr JSContext, val: JSValueConst): bool =
  JS_ToBool(ctx, val) != 0

# Conversion from Nim types to JSValue
proc nimStringToJS*(ctx: ptr JSContext, str: string): JSValue =
  JS_NewStringLen(ctx, str.cstring, str.len.csize_t)

proc nimIntToJS*(ctx: ptr JSContext, val: int32): JSValue =
  JS_NewInt32(ctx, val)

proc nimFloatToJS*(ctx: ptr JSContext, val: float64): JSValue =
  JS_NewFloat64(ctx, val)

proc nimBoolToJS*(ctx: ptr JSContext, val: bool): JSValue =
  JS_NewBool(ctx, if val: 1 else: 0)

# Convert JSValue arguments to a sequence
proc jsArgsToSeq*(ctx: ptr JSContext, argc: cint, argv: ptr JSValueConst): seq[JSValue] =
  result = newSeq[JSValue](argc)
  for i in 0..<argc:
    result[i] = JS_DupValue(ctx, cast[ptr UncheckedArray[JSValueConst]](argv)[i])

# Generic C function trampoline for Nim function calls
proc nimFunctionTrampoline(ctx: ptr JSContext, thisVal: JSValueConst, argc: cint, argv: ptr JSValueConst, magic: cint): JSValue {.cdecl.} =
  ## Generic trampoline that calls registered Nim functions from JavaScript
  ## Uses magic parameter as function ID to lookup the actual Nim function
  try:
    let contextData = cast[ptr BurritoContextData](JS_GetContextOpaque(ctx))
    if contextData == nil:
      return jsUndefined(ctx)
    
    if magic notin contextData.functions:
      return jsUndefined(ctx)
    
    let funcEntry = contextData.functions[magic]
    
    case funcEntry.kind
    of nimFunc0:
      # No arguments
      return funcEntry.func0(ctx)
    of nimFunc1:
      # One argument
      if argc >= 1:
        let arg = cast[ptr UncheckedArray[JSValueConst]](argv)[0]
        return funcEntry.func1(ctx, JS_DupValue(ctx, arg))
      else:
        return funcEntry.func1(ctx, jsUndefined(ctx))
    of nimFunc2:
      # Two arguments
      let arg1 = if argc >= 1: JS_DupValue(ctx, cast[ptr UncheckedArray[JSValueConst]](argv)[0]) else: jsUndefined(ctx)
      let arg2 = if argc >= 2: JS_DupValue(ctx, cast[ptr UncheckedArray[JSValueConst]](argv)[1]) else: jsUndefined(ctx)
      return funcEntry.func2(ctx, arg1, arg2)
    of nimFunc3:
      # Three arguments
      let arg1 = if argc >= 1: JS_DupValue(ctx, cast[ptr UncheckedArray[JSValueConst]](argv)[0]) else: jsUndefined(ctx)
      let arg2 = if argc >= 2: JS_DupValue(ctx, cast[ptr UncheckedArray[JSValueConst]](argv)[1]) else: jsUndefined(ctx)
      let arg3 = if argc >= 3: JS_DupValue(ctx, cast[ptr UncheckedArray[JSValueConst]](argv)[2]) else: jsUndefined(ctx)
      return funcEntry.func3(ctx, arg1, arg2, arg3)
    of nimFuncVar:
      # Variadic
      let args = jsArgsToSeq(ctx, argc, argv)
      result = funcEntry.funcVar(ctx, args)
      # CRITICAL: Free the duplicated JSValue arguments
      for arg in args:
        JS_FreeValue(ctx, arg)
  except:
    # Return undefined on any exception
    return jsUndefined(ctx)

# Core QuickJS wrapper
proc newQuickJS*(): QuickJS =
  ## Create a new QuickJS instance with runtime and context
  ## 
  ## ⚠️  THREAD SAFETY: The returned QuickJS instance is NOT thread-safe.
  ## Use one instance per thread or implement external locking.
  let rt = JS_NewRuntime()
  if rt == nil:
    raise newException(JSException, "Failed to create QuickJS runtime")
  
  let ctx = JS_NewContext(rt)
  if ctx == nil:
    JS_FreeRuntime(rt)
    raise newException(JSException, "Failed to create QuickJS context")
  
  # Create context data for function registry
  let contextData = cast[ptr BurritoContextData](alloc0(sizeof(BurritoContextData)))
  contextData.functions = initTable[int32, NimFunctionEntry]()
  contextData.context = ctx
  
  # Set context opaque data
  JS_SetContextOpaque(ctx, contextData)
  
  result = QuickJS(runtime: rt, context: ctx, contextData: contextData, nextFunctionId: 1)

proc close*(js: var QuickJS) =
  ## Clean up QuickJS instance
  if js.contextData != nil:
    dealloc(js.contextData)
    js.contextData = nil
  if js.context != nil:
    JS_FreeContext(js.context)
    js.context = nil
  if js.runtime != nil:
    JS_FreeRuntime(js.runtime)
    js.runtime = nil

proc eval*(js: QuickJS, code: string, filename: string = "<eval>"): string =
  ## Evaluate JavaScript code and return result as string
  let val = JS_Eval(js.context, code.cstring, code.len.csize_t, filename.cstring, JS_EVAL_TYPE_GLOBAL)
  defer: JS_FreeValue(js.context, val)

  if JS_IsException(val) != 0: # Check if it's an exception
    let exceptionVal = JS_GetException(js.context)
    defer: JS_FreeValue(js.context, exceptionVal)
    let errorStr = toNimString(js.context, exceptionVal) # Use toNimString to get the error message
    raise newException(JSException, "JavaScript Error: " & errorStr)
  else:
    result = toNimString(js.context, val)

proc evalWithGlobals*(js: QuickJS, code: string, globals: Table[string, string] = initTable[string, string]()): string =
  ## Evaluate JavaScript code with some global variables set as strings
  # Set global variables as strings
  for key, value in globals:
    let jsVal = JS_NewStringLen(js.context, value.cstring, value.len.csize_t)
    let globalObj = JS_GetGlobalObject(js.context)
    discard JS_DefinePropertyValueStr(js.context, globalObj, key.cstring, jsVal, 
                                     JS_PROP_WRITABLE or JS_PROP_CONFIGURABLE)
    JS_FreeValue(js.context, globalObj)
  
  # Evaluate the code
  return js.eval(code)

proc setJSFunction*(js: QuickJS, name: string, value: string) =
  ## Set a JavaScript function as a string in the global scope
  let code = name & " = " & value
  discard js.eval(code)

# Native C function registration methods
proc registerFunction*(js: var QuickJS, name: string, nimFunc: NimFunction0) =
  ## Register a Nim function with no arguments to be callable from JavaScript
  ## 
  ## Note: Since this function takes no arguments, no JSValue memory management is required.
  let functionId = js.nextFunctionId
  js.nextFunctionId += 1
  
  js.contextData.functions[functionId] = NimFunctionEntry(kind: nimFunc0, func0: nimFunc)
  
  let jsFunc = JS_NewCFunctionMagic(js.context, cast[JSCFunctionMagic](nimFunctionTrampoline), 
                                   name.cstring, 0, JS_CFUNC_generic_magic, functionId)
  let globalObj = JS_GetGlobalObject(js.context)
  discard JS_DefinePropertyValueStr(js.context, globalObj, name.cstring, jsFunc, 
                                   JS_PROP_WRITABLE or JS_PROP_CONFIGURABLE)
  JS_FreeValue(js.context, globalObj)

proc registerFunction*(js: var QuickJS, name: string, nimFunc: NimFunction1) =
  ## Register a Nim function with one argument to be callable from JavaScript
  ## 
  ## IMPORTANT: The JSValue argument passed to your function is duplicated and must be
  ## freed with JS_FreeValue(ctx, arg) unless ownership is transferred elsewhere.
  let functionId = js.nextFunctionId
  js.nextFunctionId += 1
  
  js.contextData.functions[functionId] = NimFunctionEntry(kind: nimFunc1, func1: nimFunc)
  
  let jsFunc = JS_NewCFunctionMagic(js.context, cast[JSCFunctionMagic](nimFunctionTrampoline), 
                                   name.cstring, 1, JS_CFUNC_generic_magic, functionId)
  let globalObj = JS_GetGlobalObject(js.context)
  discard JS_DefinePropertyValueStr(js.context, globalObj, name.cstring, jsFunc, 
                                   JS_PROP_WRITABLE or JS_PROP_CONFIGURABLE)
  JS_FreeValue(js.context, globalObj)

proc registerFunction*(js: var QuickJS, name: string, nimFunc: NimFunction2) =
  ## Register a Nim function with two arguments to be callable from JavaScript
  ## 
  ## IMPORTANT: The JSValue arguments passed to your function are duplicated and must be
  ## freed with JS_FreeValue(ctx, argN) unless ownership is transferred elsewhere.
  let functionId = js.nextFunctionId
  js.nextFunctionId += 1
  
  js.contextData.functions[functionId] = NimFunctionEntry(kind: nimFunc2, func2: nimFunc)
  
  let jsFunc = JS_NewCFunctionMagic(js.context, cast[JSCFunctionMagic](nimFunctionTrampoline), 
                                   name.cstring, 2, JS_CFUNC_generic_magic, functionId)
  let globalObj = JS_GetGlobalObject(js.context)
  discard JS_DefinePropertyValueStr(js.context, globalObj, name.cstring, jsFunc, 
                                   JS_PROP_WRITABLE or JS_PROP_CONFIGURABLE)
  JS_FreeValue(js.context, globalObj)

proc registerFunction*(js: var QuickJS, name: string, nimFunc: NimFunction3) =
  ## Register a Nim function with three arguments to be callable from JavaScript
  ## 
  ## IMPORTANT: The JSValue arguments passed to your function are duplicated and must be
  ## freed with JS_FreeValue(ctx, argN) unless ownership is transferred elsewhere.
  let functionId = js.nextFunctionId
  js.nextFunctionId += 1
  
  js.contextData.functions[functionId] = NimFunctionEntry(kind: nimFunc3, func3: nimFunc)
  
  let jsFunc = JS_NewCFunctionMagic(js.context, cast[JSCFunctionMagic](nimFunctionTrampoline), 
                                   name.cstring, 3, JS_CFUNC_generic_magic, functionId)
  let globalObj = JS_GetGlobalObject(js.context)
  discard JS_DefinePropertyValueStr(js.context, globalObj, name.cstring, jsFunc, 
                                   JS_PROP_WRITABLE or JS_PROP_CONFIGURABLE)
  JS_FreeValue(js.context, globalObj)

proc registerFunction*(js: var QuickJS, name: string, nimFunc: NimFunctionVariadic) =
  ## Register a Nim function with variadic arguments to be callable from JavaScript
  ## 
  ## IMPORTANT: The JSValue arguments in the args sequence are duplicated and must be
  ## freed with JS_FreeValue(ctx, arg) for each arg unless ownership is transferred elsewhere.
  ## Note: The variadic case is handled automatically by the trampoline - you don't need
  ## to free the args sequence elements manually.
  let functionId = js.nextFunctionId
  js.nextFunctionId += 1
  
  js.contextData.functions[functionId] = NimFunctionEntry(kind: nimFuncVar, funcVar: nimFunc)
  
  let jsFunc = JS_NewCFunctionMagic(js.context, cast[JSCFunctionMagic](nimFunctionTrampoline), 
                                   name.cstring, -1, JS_CFUNC_generic_magic, functionId)
  let globalObj = JS_GetGlobalObject(js.context)
  discard JS_DefinePropertyValueStr(js.context, globalObj, name.cstring, jsFunc, 
                                   JS_PROP_WRITABLE or JS_PROP_CONFIGURABLE)
  JS_FreeValue(js.context, globalObj)