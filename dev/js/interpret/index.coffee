# http://www.khronos.org/registry/gles/specs/2.0/GLSL_ES_Specification_1.0.17.pdf

###
Data types
  floats are an array (length 1) of a number
  vectors are arrays of numbers
###


_ = require("underscore")

zip = (f) ->
  (params...) ->
    maxLength = 0
    for param in params
      maxLength = Math.max(maxLength, param.length)
    for i in [0...maxLength]
      numbers = for param in params
        param[i % param.length]
      f(numbers...)

vec = (size) ->
  # TODO: actually it's an error if there are too many or too few components to fill a vector. You can only use a float to fill it. #pg 44
  (params...) ->
    result = []
    while result.length < size
      for param in params
        for component in param
          result.push(component)
    result.slice(0, size)

defaultValue = (type) ->
  defaults = {
    float: [0]
    vec2: [0, 0]
    vec3: [0, 0, 0]
    vec4: [0, 0, 0, 0]
  }
  defaults[type].slice(0) # clone the array

selectionComponents = {
  x: 0
  y: 1
  z: 2
  w: 3
  r: 0
  g: 1
  b: 2
  a: 3
  s: 0
  t: 1
  p: 2
  q: 3
}
select = (x, selection) ->
  # TODO: be more restrictive
  for char in selection
    x[selectionComponents[char]]

# Note: the following 2 functions are a little hacky in that they takes advantage of the mutability of arrays
setSelection = (vec, assign, selection) ->
  # Sets the components of vec to assign based on selection
  # e.g. p.xy = vec2(3., 4.)
  #      vec <= p, assign <= [3, 4], selection <= "xy"
  for char, i in selection
    vec[selectionComponents[char]] = assign[i]

setAll = (vec, assign) ->
  # Sets as in e.g. gl_FragColor = 1.
  for component, i in vec
    vec[i] = assign[i % assign.length]
    # TODO: this is way too lenient, actually you can only set things if they have the same number of components

operators = {
  add: zip (x, y) -> x + y
  sub: zip (x, y) -> x - y
  mul: zip (x, y) -> x * y
  div: zip (x, y) -> x / y
}

builtin = do ->
  clamp = (x, minVal, maxVal) -> min(max(x, minVal), maxVal)
  length = (v) ->
    total = 0
    for component in v
      total += component * component
    [Math.sqrt(total)]
  
  return {
    float: vec(1)
    vec2: vec(2)
    vec3: vec(3)
    vec4: vec(4)
    
    length: length
    distance: (v, w) ->
      length(operators.sub(v, w))
    
    abs: zip Math.abs
    mod: zip (x, y) -> x - y * Math.floor(x/y)
    floor: zip Math.floor
    ceil: zip Math.ceil
    sin: zip Math.sin
    cos: zip Math.cos
    tan: zip Math.tan
    min: zip Math.min
    max: zip Math.max
    clamp: zip clamp
    exp: zip Math.exp
    pow: zip Math.pow
    sqrt: zip Math.sqrt
    fract: zip (x) -> x - Math.floor(x)
    step: zip (edge, x) -> if x < edge then 0 else 1
    smoothstep: zip (edge0, edge1, x) ->
      t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
      return t * t * (3.0 - 2.0 * t)
  }

makeEnv = () ->
  store = {}
  
  env = {}
  env.get = (key) -> store[key]
  env.set = (key, value) -> store[key] = value
  
  return env

makeEnvFromHash = (hash) ->
  env = makeEnv()
  for own k, v of hash
    env.set(k, v)
  return env

# goes through an ast, adding evaluated properties
evaluate = (env, ast) ->
  # console.log "evaluating", ast
  type = ast.type
  
  if type == "root"
    for statement in ast.statements
      evaluate(env, statement)
  
  else if type == "precision"
    # done
  
  else if type == "declarator"
    declaredType = ast.typeAttribute.name
    for declarator in ast.declarators
      name = declarator.name.name
      if env.get(name)
        # it's already defined which means it was passed in as a uniform/varying to the interpreter
        ast.evaluated = env.get(name)
      else
        env.set(name, defaultValue(declaredType)) # set it to the default value
        if declarator.initializer
          evaluate(env, declarator.initializer)
          setAll(env.get(name), declarator.initializer.evaluated)
          ast.evaluated = declarator.initializer.evaluated
  
  else if type == "function_declaration"
    if ast.name == "main"
      evaluate(env, ast.body)
    else
      # TODO add it to the env
  
  else if type == "scope"
    # TODO make a nested env
    for statement in ast.statements
      evaluate(env, statement)
  
  else if type == "expression"
    if ast.expression != "" # handle an empty statement
      evaluate(env, ast.expression)
      ast.evaluated = ast.expression.evaluated
  
  else if type == "identifier"
    name = ast.name
    ast.evaluated = env.get(name)
  
  else if type == "float"
    ast.evaluated = [ast.value]
  
  else if type == "postfix"
    operator_type = ast.operator.type
    if operator_type == "field_selector"
      selection = ast.operator.selection
      evaluate(env, ast.expression)
      ast.evaluated = select(ast.expression.evaluated, selection)
    else
      throw "Unsupported postfix operator: #{operator_type}"
  
  else if type == "unary"
    operator = ast.operator.operator
    evaluate(env, ast.expression)
    if operator == "-"
      ast.evaluated = operators.mul([-1], ast.expression.evaluated)
    else if operator == "+"
      ast.evaluated = ast.expression.evaluated
    else
      throw "Unsupported unary operator: #{operator}"
  
  else if type == "binary"
    operator = ast.operator.operator
    if operator != "="
      evaluate(env, ast.left)
    evaluate(env, ast.right)
    if operator == "="
      if ast.left.type == "postfix"
        name = ast.left.expression.name
        selection = ast.left.operator.selection
        setSelection(env.get(name), ast.right.evaluated, selection)
      else if ast.left.type == "identifier"
        name = ast.left.name
        setAll(env.get(name), ast.right.evaluated)
      ast.evaluated = ast.right.evaluated
    else if operator == "+"
      ast.evaluated = operators.add(ast.left.evaluated, ast.right.evaluated)
    else if operator == "-"
      ast.evaluated = operators.sub(ast.left.evaluated, ast.right.evaluated)
    else if operator == "*"
      ast.evaluated = operators.mul(ast.left.evaluated, ast.right.evaluated)
    else if operator == "/"
      ast.evaluated = operators.div(ast.left.evaluated, ast.right.evaluated)
    else
      throw "Unsupported binary operator: #{operator}"
  
  else if type == "function_call"
    function_name = ast.function_name
    if builtin[function_name]
      evaluatedParameters = for parameter in ast.parameters
        evaluate(env, parameter)
        parameter.evaluated
      ast.evaluated = builtin[function_name](evaluatedParameters...)
    else
      throw "Unsupported function: #{function_name}"
  
  else
    throw "Unsupported type: #{type}"


module.exports = (hash, ast) ->
  env = makeEnvFromHash(hash)
  evaluate(env, ast)



floatToString = (n, significantDigits) ->
  s = "" + n
  # if !s.indexOf(".")
  #   s = s + "."
  # 
  # s = n.toFixed(significantDigits)
  if s.indexOf(".") == -1
    s = s + "."
  # shave 0's off the end
  s.replace(/0+$/, "")
vecToString = (x, significantDigits) ->
  fts = (n) ->
    floatToString(n, significantDigits)
  
  if x.length == 1
    fts(x[0])
  else
    s = (fts(n) for n in x).join(", ")
    return "vec#{x.length}(#{s})"

# takes an evaluated ast and finds the statements, returns a list of {line, message}
extractStatements = (ast, result = []) ->
  if ast.statements
    for statement in ast.statements
      if statement.evaluated
        result.push({
          line: statement.line - 1 # pegjs does 1-based line numbering
          message: vecToString(statement.evaluated, 5)
        })
  
  # recurse
  if _.isObject(ast)
    for own k, v of ast
      extractStatements(v, result)
  else if _.isArray(ast)
    for a in ast
      extractStatements(a, result)
  
  return result



module.exports.extractStatements = extractStatements



















