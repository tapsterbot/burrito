# Getting Started with Burrito 🌯

Welcome to Burrito! If you're a JavaScript or Python developer curious about native programming, or if you're wondering why you'd want to embed scripting languages in native apps, you're in the right place.

## What is Burrito?

Burrito is a Nim library that makes it incredibly easy to embed JavaScript (via QuickJS) and Python (via MicroPython) into your native applications. Think of it as a bridge between the performance of native code and the flexibility of scripting languages.

## Why Nim for Native Apps?

If you're coming from JavaScript or Python, you might wonder: "Why learn another language?" You've probably never heard of Nim - and that's exactly why it's such a hidden gem!

**Nim is a modern systems programming language** that combines performance and expressiveness, influenced by academic ideas but developed independently. While languages like Go, Rust, and Zig get more attention, Nim has been steadily solving real-world problems since 2008. It's the secret weapon used by companies building everything from game engines to financial trading systems.

Here's why Nim is special:

### 🚀 **Speed of C, Syntax Like Python**
```nim
# Nim code looks familiar if you know Python
proc calculateDistance(x1, y1, x2, y2: float): float =
  let dx = x2 - x1
  let dy = y2 - y1
  return sqrt(dx*dx + dy*dy)
```

**But here's the magic**: This readable, Python-like code compiles directly to optimized C and runs at native speed! No virtual machine, no interpreter overhead - just blazing fast machine code.

### 📦 **Deploy Anywhere, No Dependencies**
- **Single binary**: Your entire app compiles to one executable file
- **No runtime required**: Users don't need to install Node.js, Python, or JVM
- **Cross-platform**: Same code runs on Windows, macOS, Linux, and embedded systems
- **Tiny footprint**: Minimal binary size compared to other compiled languages

### 🔗 **Seamless C Integration**
- **Zero-friction FFI**: Call C libraries directly without binding generators
- **Existing ecosystem**: Leverage decades of C libraries instantly
- **Hardware access**: Perfect for IoT, robotics, and system programming
- **Legacy integration**: Wrap existing C/C++ codebases effortlessly

### 🛡️ **Safe and Predictable**
- **Memory safety**: Automatic memory management without garbage collection pauses
- **Zero-cost abstractions**: High-level features with no runtime overhead
- **Deterministic performance**: Perfect for real-time applications and games
- **Safe by default**: Catch errors at compile time, not runtime

### ⚡ **What Makes Nim Extraordinary**
- **Metaprogramming**: Powerful macros that generate code at compile time
- **Multiple paradigms**: Object-oriented, functional, procedural - pick your style
- **Incremental adoption**: Start with small modules, gradually replace performance bottlenecks
- **Developer happiness**: Expressive syntax that makes complex code readable

## Why Embed Scripting?

You might think: "If Nim is so great, why not write everything in Nim?" Here's why embedded scripting is powerful:

- **🤖 Robotics**: Fast hardware control in Nim, interactive testing in Python
- **🎮 Games**: High-performance engine in Nim, user mods in JavaScript
- **🌐 Web Services**: Efficient HTTP in Nim, flexible business rules in JavaScript

**The pattern**: Performance-critical code in Nim, flexible logic in scripts.

## Your First Burrito App

Let's build something together! We'll create a simple calculator where the core math is in Nim (fast) and user formulas can be in JavaScript or Python (flexible).

### Step 1: Installation

First, make sure you have Nim installed:
```bash
# Install Nim (if you haven't already)
curl https://nim-lang.org/choosenim/init.sh -sSf | sh

# Clone Burrito
git clone https://github.com/tapsterbot/burrito.git
cd burrito

# Setup dependencies
nimble get_quickjs
nimble build_quickjs
nimble get_micropython
nimble build_micropython
```

### Step 2: Your First JavaScript Integration

Create `my_calculator.nim`:
```nim
import burrito/qjs

# Native Nim function - compiled, fast
proc factorial(n: int): int =
  if n <= 1: 1
  else: n * factorial(n - 1)

# Create JavaScript engine
var js = newQuickJS()
defer: js.close()

# Register our Nim function with JavaScript
proc jsFactorial(ctx: ptr JSContext, n: JSValue): JSValue =
  let nimN = toNimInt(ctx, n)
  let result = factorial(nimN)
  return nimIntToJS(ctx, result)

js.registerFunction("factorial", jsFactorial)

# Now JavaScript can call our fast Nim code!
echo js.eval("factorial(10)")  # Output: 3628800
echo js.eval("'Factorial of 5 is: ' + factorial(5)")  # Output: Factorial of 5 is: 120
```

Run it:
```bash
nim r my_calculator.nim
```

### Step 3: Add Python Support

Add to your `my_calculator.nim`:
```nim
import burrito/mpy

# Create Python engine
var py = newMicroPython()
defer: py.close()

# Python can do flexible string formatting
echo py.eval("""
result = 42 * 37
print(f'The answer is {result}')
""")

# Let's do some data analysis
echo py.eval("""
data = [1, 2, 3, 4, 5, 10, 100]
average = sum(data) / len(data)
print(f'Average: {average:.2f}')
print(f'Max: {max(data)}')
print(f'Min: {min(data)}')
""")
```

### Step 4: Interactive REPL

Want to experiment? Burrito includes interactive REPLs:

```bash
# JavaScript REPL with your Nim functions
nimble repl_js

# Python REPL
nimble repl_mpy

# Both engines together
nimble dual_engines
```

Try this in the JavaScript REPL:
```javascript
>>> 2 + 3
5
>>> "Hello " + "Burrito!"
Hello Burrito!
>>> Math.sqrt(16)
4
```

And in the Python REPL:
```python
>>> print("Hello from Python!")
Hello from Python!
>>> [x*2 for x in range(5)]
[0, 2, 4, 6, 8]
>>> len("Burrito")
7
```

### Step 5: Building Something Real - Valet Network Nodes

At [Tapster](https://tapster.io/), we're building the Valet Network in Nim and using Burrito to **experiment and prototype with [Nostr](https://nostr.com/)** for our nodes. This shows how Burrito helps with:
- **Valet Studio** - Desktop app for node management
- **Valet Hardware ([Valet Link](https://tapster.io/valet-link-by-tapster-robotics-specifications-and-features))** - Raspberry Pi nodes

```nim
# Fast Nostr relay communication in Nim
proc connectToNostr*(relay: string): WebSocket =
  result = newWebSocket(relay)

proc publishEvent*(ws: WebSocket, event: NostrEvent) =
  # Fast JSON serialization and WebSocket send
  ws.send(event.toJson())

proc parseJobFromNostr*(event: NostrEvent): TestJob =
  # Efficient parsing of test job from Nostr event
  result = parseJson(event.content).to(TestJob)

# Expose to JavaScript via Burrito
```

```javascript
// Node behavior - hot-swappable without restarting!
function handleTestJob(job) {  // job from Nim Nostr parsing
  // Connect to test target
  driver.get(job.website);

  // Run the test
  const screenshot = takeScreenshot();  // Fast Nim capture
  const isUp = driver.getTitle() && !screenshot.contains("Error");

  // Report results back to Nostr
  publishEvent(createResultEvent({
    jobId: job.id,
    status: isUp ? "success" : "failed",
    screenshot: screenshot,
    nodeLocation: "raspberry-pi-home"
  }));
}

// Prototype new node behaviors without recompiling!
```

**Why This Works for Valet Network**:
- **⚡ Fast [Nostr](https://nostr.com/)**: WebSocket handling and JSON parsing in compiled Nim
- **🔧 Flexible Logic**: Test execution and node behavior in hot-swappable JavaScript
- **🎯 Rapid Prototyping**: Experiment with [Nostr](https://nostr.com/) protocols without rebuilding the entire node

## What Makes This Powerful?

### 🎯 **Best of Both Worlds**
- **Nim**: Fast file I/O, memory management, system calls
- **Scripts**: Flexible logic, easy to modify, user-customizable

### 🔄 **Rapid Iteration**
- Change script behavior without recompiling
- Test new ideas in the REPL
- Hot-reload configuration

### 👥 **User Empowerment**
- Users can extend your app without C/Nim knowledge
- Safe sandbox - scripts can't crash your native code
- Familiar languages (JS/Python) for widespread adoption

### 🚀 **Performance Where It Matters**
- Critical paths in compiled Nim (memory management, I/O, algorithms)
- Flexible paths in scripts (business logic, UI, configuration)

## Next Steps

Ready to dive deeper? Here's what to explore next:

### 📚 **Learn More**
- [API Documentation](burrito.html) - Complete function reference
- [QuickJS Examples](https://github.com/tapsterbot/burrito/tree/main/examples/qjs) - JavaScript integration patterns
- [MicroPython Examples](https://github.com/tapsterbot/burrito/tree/main/examples/mpy) - Python integration patterns

### 🛠 **Try More Examples**
```bash
# Run QuickJS examples
nimble example

# Try MicroPython
nimble example_mpy

# Experiment with both engines
nimble dual_engines
```

### 🌟 **Join the Community**
- [GitHub Repository](https://github.com/tapsterbot/burrito) - Source code and issues
- Share your use cases and get help
- Contribute examples and improvements

### 💡 **Build Something Amazing**
Now that you understand the power of native + scripting, what will you create?

- **Game with modding support?**
- **Data processing pipeline with user scripts?**
- **IoT device with scriptable behavior?**
- **Desktop app with plugin system?**

The combination of Nim's performance and JavaScript/Python's flexibility opens up endless possibilities. Welcome to the Burrito community - we can't wait to see what you build! 🌯✨

---

*Questions? Found a bug? Want to contribute? Visit our [GitHub repository](https://github.com/tapsterbot/burrito) or check out the [API documentation](burrito.html).*
