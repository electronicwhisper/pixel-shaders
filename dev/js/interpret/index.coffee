###
Data types
  floats are an array (length 1) of a number
  vectors are arrays of numbers
###


zip = (f) ->
  (params...) ->
    maxLength = 0
    for param in params
      maxLength = Math.max(maxlength, param.length)
    return for i in [0...maxLength]
      numbers = param[i % param.length] for param in params
      f(numbers...)

vec = (size) ->
  (params...) ->
    result = []
    while result.length < size
      for param in params
        for component in param
          result.push(component)
    result.slice(0, size)

n = {
  add: zip (x, y) -> x + y
  sub: zip (x, y) -> x - y
  mul: zip (x, y) -> x * y
  div: zip (x, y) -> x / y
}

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
  clamp: zip (x, minVal, maxVal) -> min(max(x, minVal), maxVal)
  exp: zip Math.exp
  pow: zip Math.pow
  sqrt: zip Math.sqrt
  fract: zip (x) -> x - floor(x)
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

# goes through an ast, adding evaluated properties
evaluate = (env, ast) ->
  type = ast.type
  
  if type == "identifier"
    name = ast.name
    ast.evaluated = env.get(name)
  
  else if type == "float"
    ast.evaluated = [ast.value]
  
  else if type == "unary"
    operator = ast.operator.operator
    evaluate(env, ast.expression)
    if operator == "-"
      ast.evaluated = n.mul(-1, ast.expression.evaluated)
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
      evaluatedParameters = for parameter in parameters
        evaluate(env, parameter)
        parameter.evaluated
      ast.evaluated = builtin[function_name](evaluatedParameters...)
    else
      throw "Unsupported function: #{function_name}"
  
  else
    throw "Unsupported type: #{type}"


module.exports = evaluate