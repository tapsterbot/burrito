import ../src/burrito
import std/[tables, json, strutils]

# Define some custom Nim types for testing
type
  Person* = object
    name*: string
    age*: int
    email*: string
    
  Company* = object
    name*: string
    employees*: seq[Person]
    founded*: int
    
  Config* = object
    database*: Table[string, string]
    features*: seq[string]
    limits*: tuple[maxUsers: int, maxStorage: int]

# Define conversions for our custom types
proc personToJS*(ctx: ptr JSContext, person: Person): JSValue =
  let obj = JS_NewObject(ctx)
  discard setProperty(ctx, obj, "name", nimStringToJS(ctx, person.name))
  discard setProperty(ctx, obj, "age", nimIntToJS(ctx, person.age.int32))
  discard setProperty(ctx, obj, "email", nimStringToJS(ctx, person.email))
  return obj

proc jsToPersonOverArg*(ctx: ptr JSContext, jsObj: JSValue, person: var Person) =
  # Extract person data from JavaScript object
  let nameVal = getProperty(ctx, jsObj, "name")
  let ageVal = getProperty(ctx, jsObj, "age") 
  let emailVal = getProperty(ctx, jsObj, "email")
  defer:
    JS_FreeValue(ctx, jsObj)
    JS_FreeValue(ctx, nameVal)
    JS_FreeValue(ctx, ageVal)
    JS_FreeValue(ctx, emailVal)
  
  person.name = toNimString(ctx, nameVal)
  person.age = toNimInt(ctx, ageVal).int
  person.email = toNimString(ctx, emailVal)

proc jsToPerson*(ctx: ptr JSContext, jsObj: JSValueConst): Person =
  let nameVal = getProperty(ctx, jsObj, "name")
  let ageVal = getProperty(ctx, jsObj, "age") 
  let emailVal = getProperty(ctx, jsObj, "email")
  defer:
    JS_FreeValue(ctx, nameVal)
    JS_FreeValue(ctx, ageVal)
    JS_FreeValue(ctx, emailVal)
  
  result = Person(
    name: toNimString(ctx, nameVal),
    age: toNimInt(ctx, ageVal).int,
    email: toNimString(ctx, emailVal)
  )

proc companyToJS*(ctx: ptr JSContext, company: Company): JSValue =
  let obj = JS_NewObject(ctx)
  discard setProperty(ctx, obj, "name", nimStringToJS(ctx, company.name))
  discard setProperty(ctx, obj, "founded", nimIntToJS(ctx, company.founded.int32))
  
  # Convert employees array
  let employeesArr = newArray(ctx)
  for i, employee in company.employees:
    discard setArrayElement(ctx, employeesArr, i.uint32, personToJS(ctx, employee))
  discard setProperty(ctx, obj, "employees", employeesArr)
  
  return obj

# Nim functions that work with marshaled types
proc processPersonData(ctx: ptr JSContext, personObj: JSValue): JSValue =
  let person = jsToPerson(ctx, personObj)
  JS_FreeValue(ctx, personObj)
  
  # Process the person data
  let processedPerson = Person(
    name: person.name.toUpper(),
    age: person.age,
    email: person.email.toLower()
  )
  
  # Add computed fields
  result = JS_NewObject(ctx)
  discard setProperty(ctx, result, "originalName", nimStringToJS(ctx, person.name))
  discard setProperty(ctx, result, "processedName", nimStringToJS(ctx, processedPerson.name))
  discard setProperty(ctx, result, "age", nimIntToJS(ctx, person.age.int32))
  discard setProperty(ctx, result, "email", nimStringToJS(ctx, processedPerson.email))
  discard setProperty(ctx, result, "isAdult", nimBoolToJS(ctx, person.age >= 18))
  discard setProperty(ctx, result, "category", nimStringToJS(ctx,
    if person.age < 13: "child"
    elif person.age < 20: "teenager"
    else: "adult"
  ))
  
  return result

proc createPersonArray(ctx: ptr JSContext, count: JSValue): JSValue =
  let n = toNimInt(ctx, count)
  JS_FreeValue(ctx, count)
  
  let arr = newArray(ctx)
  for i in 0..<n:
    let person = Person(
      name: "Person" & $i,
      age: 20 + (i * 5),
      email: "person" & $i & "@example.com"
    )
    discard setArrayElement(ctx, arr, i.uint32, personToJS(ctx, person))
  
  return arr

proc processCompany(ctx: ptr JSContext, companyData: JSValue): JSValue =
  # Extract company name
  let nameVal = getProperty(ctx, companyData, "name")
  let foundedVal = getProperty(ctx, companyData, "founded")
  let employeesVal = getProperty(ctx, companyData, "employees")
  defer:
    JS_FreeValue(ctx, companyData)
    JS_FreeValue(ctx, nameVal)
    JS_FreeValue(ctx, foundedVal)
    JS_FreeValue(ctx, employeesVal)
  
  let companyName = toNimString(ctx, nameVal)
  let founded = toNimInt(ctx, foundedVal).int
  let employeeCount = getArrayLength(ctx, employeesVal)
  
  # Calculate company stats
  var totalAge = 0
  var adultCount = 0
  
  for i in 0..<employeeCount:
    let empObj = getArrayElement(ctx, employeesVal, i.uint32)
    let ageVal = getProperty(ctx, empObj, "age")
    defer:
      JS_FreeValue(ctx, empObj)
      JS_FreeValue(ctx, ageVal)
    
    let age = toNimInt(ctx, ageVal).int
    totalAge += age
    if age >= 18: adultCount += 1
  
  let avgAge = if employeeCount > 0: totalAge div employeeCount.int else: 0
  let currentYear = 2024
  let companyAge = currentYear - founded
  
  # Create result object
  result = JS_NewObject(ctx)
  discard setProperty(ctx, result, "companyName", nimStringToJS(ctx, companyName))
  discard setProperty(ctx, result, "employeeCount", nimIntToJS(ctx, employeeCount.int32))
  discard setProperty(ctx, result, "averageEmployeeAge", nimIntToJS(ctx, avgAge.int32))
  discard setProperty(ctx, result, "adultEmployees", nimIntToJS(ctx, adultCount.int32))
  discard setProperty(ctx, result, "companyAge", nimIntToJS(ctx, companyAge.int32))
  discard setProperty(ctx, result, "founded", nimIntToJS(ctx, founded.int32))
  
  return result

proc testSequenceConversions() =
  echo "Sequence and Array Conversions"
  echo "=============================="
  
  var js = newQuickJS()
  defer: js.close()
  
  # Test string sequence
  let fruits = @["apple", "banana", "cherry", "date"]
  echo "Original Nim sequence: ", fruits
  
  # Convert to JS and back
  let globalObj = JS_GetGlobalObject(js.context)
  defer: JS_FreeValue(js.context, globalObj)
  
  let fruitsJS = seqToJS(js.context, fruits)
  discard setProperty(js.context, globalObj, "fruits", fruitsJS)
  
  echo "In JavaScript: ", js.eval("JSON.stringify(fruits)")
  echo "JS Array length: ", js.eval("fruits.length")
  echo "First element: ", js.eval("fruits[0]")
  
  # Test number sequence
  let numbers = @[1, 2, 3, 4, 5]
  let numbersJS = seqToJS(js.context, numbers)
  discard setProperty(js.context, globalObj, "numbers", numbersJS)
  
  echo "\nNumber sequence: ", numbers
  echo "In JavaScript: ", js.eval("JSON.stringify(numbers)")
  echo "Sum via JS: ", js.eval("numbers.reduce((a, b) => a + b, 0)")
  
  # Test mixed operations
  echo "\nMixed operations:"
  echo "Fruits reversed: ", js.eval("JSON.stringify(fruits.slice().reverse())")
  echo "Numbers doubled: ", js.eval("JSON.stringify(numbers.map(x => x * 2))")

proc testTableConversions() =
  echo "\nTable and Object Conversions"
  echo "============================"
  
  var js = newQuickJS()
  defer: js.close()
  
  # Test Table[string, string]
  var config = initTable[string, string]()
  config["host"] = "localhost"
  config["port"] = "8080"
  config["protocol"] = "https"
  config["version"] = "1.0"
  
  echo "Original Nim table: ", config
  
  let globalObj = JS_GetGlobalObject(js.context)
  defer: JS_FreeValue(js.context, globalObj)
  
  let configJS = tableToJS(js.context, config)
  discard setProperty(js.context, globalObj, "config", configJS)
  
  echo "In JavaScript: ", js.eval("JSON.stringify(config)")
  echo "Host: ", js.eval("config.host")
  echo "Port: ", js.eval("config.port")
  
  # Test Table[string, int]
  var stats = initTable[string, int]()
  stats["users"] = 1000
  stats["posts"] = 5000
  stats["comments"] = 12000
  
  let statsJS = tableToJS(js.context, stats)
  discard setProperty(js.context, globalObj, "stats", statsJS)
  
  echo "\nStats table: ", stats
  echo "In JavaScript: ", js.eval("JSON.stringify(stats)")
  echo "Total users: ", js.eval("stats.users")

proc testCustomObjectConversions() =
  echo "\nCustom Object Type Conversions"
  echo "=============================="
  
  var js = newQuickJS()
  defer: js.close()
  
  # Register our custom conversion functions
  js.registerFunction("processPersonData", processPersonData)
  js.registerFunction("createPersonArray", createPersonArray)
  js.registerFunction("processCompany", processCompany)
  
  # Test Person object conversion
  let person = Person(
    name: "Alice Johnson",
    age: 30,
    email: "ALICE@EXAMPLE.COM"
  )
  
  echo "Original Person: ", person
  
  let globalObj = JS_GetGlobalObject(js.context)
  defer: JS_FreeValue(js.context, globalObj)
  
  let personJS = personToJS(js.context, person)
  discard setProperty(js.context, globalObj, "person", personJS)
  
  echo "Person in JavaScript: ", js.eval("JSON.stringify(person)")
  echo "Processed person: ", js.eval("JSON.stringify(processPersonData(person))")
  
  # Test Company with multiple employees
  let company = Company(
    name: "Tech Innovations Inc",
    founded: 2010,
    employees: @[
      Person(name: "Alice", age: 30, email: "alice@tech.com"),
      Person(name: "Bob", age: 25, email: "bob@tech.com"),
      Person(name: "Charlie", age: 35, email: "charlie@tech.com"),
      Person(name: "Diana", age: 28, email: "diana@tech.com")
    ]
  )
  
  echo "\nOriginal Company: ", company.name, " (", company.employees.len, " employees)"
  
  let companyJS = companyToJS(js.context, company)
  discard setProperty(js.context, globalObj, "company", companyJS)
  
  echo "Company in JavaScript: ", js.eval("JSON.stringify(company)")
  echo "Company analysis: ", js.eval("JSON.stringify(processCompany(company))")
  
  # Test array creation from Nim
  echo "\nCreated person array: ", js.eval("JSON.stringify(createPersonArray(3))")

proc testTupleConversions() =
  echo "\nTuple Conversions"
  echo "================="
  
  var js = newQuickJS()
  defer: js.close()
  
  let globalObj = JS_GetGlobalObject(js.context)
  defer: JS_FreeValue(js.context, globalObj)
  
  # Test (string, int) tuple
  let coordinates: (string, int) = ("latitude", 45)
  let coordJS = nimTupleToJSArray(js.context, coordinates)
  discard setProperty(js.context, globalObj, "coordinates", coordJS)
  
  echo "Tuple (string, int): ", coordinates
  echo "In JavaScript: ", js.eval("JSON.stringify(coordinates)")
  
  # Test (string, string) tuple
  let keyValue: (string, string) = ("username", "alice123")
  let kvJS = nimTupleToJSArray(js.context, keyValue)
  discard setProperty(js.context, globalObj, "keyValue", kvJS)
  
  echo "Tuple (string, string): ", keyValue
  echo "In JavaScript: ", js.eval("JSON.stringify(keyValue)")
  
  # Test (int, int) tuple
  let point: (int, int) = (100, 200)
  let pointJS = nimTupleToJSArray(js.context, point)
  discard setProperty(js.context, globalObj, "point", pointJS)
  
  echo "Tuple (int, int): ", point
  echo "In JavaScript: ", js.eval("JSON.stringify(point)")

proc main() =
  echo "Comprehensive Type Marshaling Examples"
  echo "======================================"
  
  testSequenceConversions()
  testTableConversions()
  testCustomObjectConversions()
  testTupleConversions()
  
  echo "\n🎉 All type marshaling examples completed successfully!"

when isMainModule:
  main()