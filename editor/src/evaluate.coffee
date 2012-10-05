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



module.exports = {
  direct: (s) -> eval(s)
  functionOfX: (s) ->
    eval("(function (x) {return #{s};})")
}