evalInContext = do ->
  abs = Math.abs
  mod = (x, y) -> x - y * Math.floor(x/y)
  floor = Math.floor
  ceil = Math.ceil
  sin = Math.sin
  cos = Math.cos
  tan = Math.tan
  min = Math.min
  max = Math.max
  clamp = (x, minVal, maxVal) -> min(max(x, minVal), maxVal)
  exp = Math.exp
  pow = Math.pow
  sqrt = Math.sqrt
  fract = (x) -> x - floor(x)
  
  return (s) -> eval(s)



hasIntegers = (s) ->
  # for simulating errors on non-floating point numbers
  ret = false
  XRegExp.forEach(s, /([0-9]*\.[0-9]*)|[0-9]+/, (match) ->
    number = match[0]
    if number.indexOf(".") == -1
      ret = true
  )
  return ret

errorValue = {err: true}


module.exports = {
  direct: (s) ->
    outputValue = errorValue
    if !hasIntegers(s)
      try
        outputValue = evalInContext(s)
      catch e
    
    return outputValue
  
  functionOfX: (s) ->
    if hasIntegers(s)
      return errorValue
    evalInContext("(function (x) {return #{s};})")
  
  hasIntegers: hasIntegers
}