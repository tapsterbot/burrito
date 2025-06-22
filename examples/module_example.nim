## Example demonstrating ES6 module usage in Burrito
## 
## This example shows how to:
## 1. Create a QuickJS instance with module support
## 2. Use ES6 import syntax to load built-in modules
## 3. Execute module code with evalModule()
## 4. Handle module-related errors gracefully
##
## QuickJS supports ES6 modules with import/export syntax,
## allowing you to use modern JavaScript module patterns.

import ../src/burrito

proc basicModuleImport() =
  echo "=== Basic ES6 Module Import (std) ==="
  
  # Create QuickJS instance with std library support
  var js = newQuickJS(configWithStdLib())
  defer: js.close()
  
  # Use ES6 import syntax to load the std module
  let code = """
    import * as std from 'std';
    
    // Use the imported module
    std.out.printf('Hello from ES6 module!\n');
    
    // Return a value to Nim
    'Module import successful';
  """
  
  try:
    discard js.evalModule(code)
    echo "Module executed successfully"
    # Note: evalModule returns a Promise, actual result handling would require async support
  except Exception as e:
    echo "Error: ", e.msg

proc namedImports() =
  echo "\n=== Named Imports Example (std) ==="
  
  var js = newQuickJS(configWithStdLib())
  defer: js.close()
  
  # Import specific functions from the std module
  let code = """
    import { getenv, sprintf, out } from 'std';
    
    // Use imported functions directly
    let shell = getenv('SHELL') || 'unknown';
    let message = sprintf('Current shell: %s', shell);
    
    out.printf('%s\n', message);
  """
  
  try:
    discard js.evalModule(code)
    echo "Module executed successfully"
  except Exception as e:
    echo "Error: ", e.msg

proc multipleModuleImports() =
  echo "\n=== Multiple Module Imports (std, os) ==="
  
  # Create instance with both std and os modules
  var js = newQuickJS(configWithBothLibs())
  defer: js.close()
  
  let code = """
    import * as std from 'std';
    import * as os from 'os';
    
    // Use both modules together
    let [cwd, err] = os.getcwd();
    if (!err) {
      std.out.printf('Working directory: %s\n', cwd);
    }
    
    // Get system information
    let platform = os.platform || 'unknown';
    std.out.printf('Platform: %s\n', platform);
  """
  
  try:
    discard js.evalModule(code)
    echo "Module executed successfully"
  except Exception as e:
    echo "Error: ", e.msg

proc moduleErrorHandling() =
  echo "\n=== Module Error Handling ==="
  
  # Try to import a module without proper configuration
  var js = newQuickJS()  # Default config without modules
  defer: js.close()
  
  let code = """
    import * as std from 'std';
    'This should not execute';
  """
  
  try:
    # This will fail because std module is not available
    discard js.evalModule(code)
    echo "This should not be reached"
  except Exception as e:
    echo "Expected error: ", e.msg
    echo "This is normal - std module requires configWithStdLib()"

proc customModuleExample() =
  echo "\n=== Custom Module Definition ==="
  
  var js = newQuickJS()
  defer: js.close()
  
  # Define and use a custom module pattern
  let code = """
    // Create a module-like object
    const myModule = {
      version: '1.0.0',
      greet: function(name) {
        return 'Hello, ' + name + '!';
      },
      calculate: function(a, b) {
        return {
          sum: a + b,
          product: a * b
        };
      }
    };
    
    // Use the module
    let greeting = myModule.greet('Burrito');
    let calc = myModule.calculate(5, 3);
    
    greeting + ' Sum: ' + calc.sum + ', Product: ' + calc.product;
  """
  
  try:
    # Note: Using eval() for custom modules, evalModule() for ES6 imports
    let result = js.eval(code)
    echo "Result: ", result
  except Exception as e:
    echo "Error: ", e.msg

when isMainModule:
  echo "Burrito ES6 Module Example"
  echo "========================="
  echo ""
  
  basicModuleImport()
  namedImports()
  multipleModuleImports()
  moduleErrorHandling()
  customModuleExample()
  
  echo "\nExample completed!"
