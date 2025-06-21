## QuickJS Nim Wrapper
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
  JSRuntime* = ptr object
  JSContext* = ptr object
  JSAtom* = uint32
  JSClassID* = uint32
  
  # Import JSValue as opaque struct from C  
  JSValue* {.importc, header: "quickjs/quickjs.h".} = object
  JSValueConst* = JSValue

  # Function pointer type for JavaScript C functions
  JSCFunction* = proc(ctx: JSContext, thisVal: JSValueConst, argc: int32, argv: ptr JSValueConst): JSValue {.cdecl.}

# Core QuickJS API bindings
{.push importc, header: "quickjs/quickjs.h".}

proc JS_NewRuntime*(): JSRuntime
proc JS_FreeRuntime*(rt: JSRuntime)
proc JS_NewContext*(rt: JSRuntime): JSContext
proc JS_FreeContext*(ctx: JSContext)

# Value operations
proc JS_NewInt32*(ctx: JSContext, val: int32): JSValue
proc JS_NewFloat64*(ctx: JSContext, val: float64): JSValue
proc JS_NewString*(ctx: JSContext, str: cstring): JSValue
proc JS_NewBool*(ctx: JSContext, val: int32): JSValue
proc JS_NewObject*(ctx: JSContext): JSValue

# Getting values from JSValue
proc JS_ToInt32*(ctx: JSContext, pres: ptr int32, val: JSValueConst): int32
proc JS_ToFloat64*(ctx: JSContext, pres: ptr float64, val: JSValueConst): int32
proc JS_ToCString*(ctx: JSContext, val: JSValueConst): cstring
proc JS_FreeCString*(ctx: JSContext, str: cstring)
proc JS_ToBool*(ctx: JSContext, val: JSValueConst): int32

# Function and property operations
proc JS_NewCFunction*(ctx: JSContext, `func`: JSCFunction, name: cstring, length: int32): JSValue
proc JS_DefinePropertyValueStr*(ctx: JSContext, thisObj: JSValueConst, prop: cstring, val: JSValue, flags: int32): int32

# Evaluation
proc JS_Eval*(ctx: JSContext, input: cstring, inputLen: csize_t, filename: cstring, evalFlags: int32): JSValue

# Memory management
proc JS_FreeValue*(ctx: JSContext, v: JSValue)
proc JS_DupValue*(ctx: JSContext, v: JSValueConst): JSValue

# Global object
proc JS_GetGlobalObject*(ctx: JSContext): JSValue

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

# Constants as procs that call the C macros
proc jsUndefined*(ctx: JSContext): JSValue =
  ## Return JavaScript undefined value
  {.emit: "return JS_UNDEFINED;".}

proc jsNull*(ctx: JSContext): JSValue =
  ## Return JavaScript null value
  {.emit: "return JS_NULL;".}

proc jsTrue*(ctx: JSContext): JSValue =
  ## Return JavaScript true value
  {.emit: "return JS_TRUE;".}

proc jsFalse*(ctx: JSContext): JSValue =
  ## Return JavaScript false value
  {.emit: "return JS_FALSE;".}

# High-level wrapper types
type
  QuickJS* = object
    runtime*: JSRuntime
    context*: JSContext
    
  JSException* = object of CatchableError
    jsValue*: JSValue

# Value conversion helpers
proc toNimString*(ctx: JSContext, val: JSValueConst): string =
  let cstr = JS_ToCString(ctx, val)
  if cstr != nil:
    result = $cstr
    JS_FreeCString(ctx, cstr)  # Important: free the C string
  else:
    result = ""

proc toNimInt*(ctx: JSContext, val: JSValueConst): int32 =
  discard JS_ToInt32(ctx, addr result, val)

proc toNimFloat*(ctx: JSContext, val: JSValueConst): float64 =
  discard JS_ToFloat64(ctx, addr result, val)

proc toNimBool*(ctx: JSContext, val: JSValueConst): bool =
  JS_ToBool(ctx, val) != 0

# Core QuickJS wrapper
proc newQuickJS*(): QuickJS =
  ## Create a new QuickJS instance with runtime and context
  let rt = JS_NewRuntime()
  if rt == nil:
    raise newException(JSException, "Failed to create QuickJS runtime")
  
  let ctx = JS_NewContext(rt)
  if ctx == nil:
    JS_FreeRuntime(rt)
    raise newException(JSException, "Failed to create QuickJS context")
  
  result = QuickJS(runtime: rt, context: ctx)

proc close*(js: var QuickJS) =
  ## Clean up QuickJS instance
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
  
  result = toNimString(js.context, val)

# Simplified function registration without complex bridging
# For the initial version, we'll demonstrate the concept
proc evalWithGlobals*(js: QuickJS, code: string, globals: Table[string, string] = initTable[string, string]()): string =
  ## Evaluate JavaScript code with some global variables set as strings
  ## This is a simplified approach for the basic wrapper
  
  # Set global variables as strings
  for key, value in globals:
    let jsVal = JS_NewString(js.context, value.cstring)
    let globalObj = JS_GetGlobalObject(js.context)
    discard JS_DefinePropertyValueStr(js.context, globalObj, key.cstring, jsVal, 
                                     JS_PROP_WRITABLE or JS_PROP_CONFIGURABLE)
    JS_FreeValue(js.context, globalObj)
  
  # Evaluate the code
  return js.eval(code)

# Basic function to demonstrate setting a JavaScript function from Nim
proc setJSFunction*(js: QuickJS, name: string, value: string) =
  ## Set a JavaScript function as a string in the global scope
  ## This is a simple approach - the function is defined as JS code
  let code = name & " = " & value
  discard js.eval(code)