abs = (x) -> Math.abs(x)
mod = (x, b) -> x % b

module.exports = {
  direct: (s) -> eval(s)
  functionOfX: (s) -> eval("(function (x) {return #{s};})")
}