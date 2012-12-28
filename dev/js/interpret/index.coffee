# http://www.khronos.org/registry/gles/specs/2.0/GLSL_ES_Specification_1.0.17.pdf

###
Data types
  floats are an array (length 1) of a number
  vectors are arrays of numbers
###


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

n = {
  add: zip (x, y) -> x + y
  sub: zip (x, y) -> x - y
  mul: zip (x, y) -> x * y
  div: zip (x, y) -> x / y
}

clamp = (x, minVal, maxVal) -> min(max(x, minVal), maxVal)
builtin = {
  float: vec(1)
  vec2: vec(2)
  vec3: vec(3)
  vec4: vec(4)
  
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
  
  if type == "identifier"
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
      ast.evaluated = n.mul([-1], ast.expression.evaluated)
    else if operator == "+"
      ast.evaluated = ast.expression.evaluated
    else
      throw "Unsupported unary operator: #{operator}"
  
  else if type == "binary"
    operator = ast.operator.operator
    # TODO: don't evaluate left side if operator is =, etc.
    evaluate(env, ast.left)
    evaluate(env, ast.right)
    if operator == "+"
      ast.evaluated = n.add(ast.left.evaluated, ast.right.evaluated)
    else if operator == "-"
      ast.evaluated = n.sub(ast.left.evaluated, ast.right.evaluated)
    else if operator == "*"
      ast.evaluated = n.mul(ast.left.evaluated, ast.right.evaluated)
    else if operator == "/"
      ast.evaluated = n.div(ast.left.evaluated, ast.right.evaluated)
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