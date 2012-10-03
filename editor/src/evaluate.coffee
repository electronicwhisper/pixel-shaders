abs = (x) -> Math.abs(x)
mod = (x, y) -> x - y * Math.floor(x/y)
floor = (x) -> Math.floor(x)

module.exports = {
  direct: (s) -> eval(s)
  functionOfX: (s) ->
    eval("(function (x) {return #{s};})")
}