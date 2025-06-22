import unittest
import ../src/burrito

suite "Basic Burrito Example":
  test "Full usage example":

    var js = newQuickJS()
    defer: js.close()

    # Simple math
    let mathRes = js.eval("2 + 3")
    check mathRes == "5"

    # String operations  
    let strRes = js.eval("'Hello ' + 'World!'")
    check strRes == "Hello World!"

    # Built-in functions
    let sqrtRes = js.eval("Math.sqrt(16)")
    check sqrtRes == "4"

