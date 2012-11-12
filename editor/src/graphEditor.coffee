util = require("util")
evaluate = require("evaluate")

module.exports = (opts) ->
  
  
  o = opts
  
  $output = $(o.output)
  
  
  $canvas = $("<canvas />")
  $output.append($canvas)
  util.expandCanvas($canvas)
  ctx = $canvas[0].getContext("2d")
  
  
  graph = require("graph")(ctx, opts)
  
  
  
  src = o.src
  $code = $(o.code)
  srcFun = evaluate.functionOfX(src)
  compiled = true
  
  
  refreshCode = () ->
    src = cm.getValue()
    compiled = true
    try
      srcFun = evaluate.functionOfX(src)
      srcFun(0); # test it once while in try-catch land
    catch e
      compiled = false
    if compiled
      $code.removeClass("error")
      # equations = [{
      #   color: "#006"
      #   f: srcFun
      # }]
      # equations = evaluate.findAllSubExpressions(src).map (expr) ->
      #   s = _.flatten(expr).join("")
      #   f = evaluate.functionOfX(s)
      #   return {
      #     f: f
      #     color: "rgba(0, 0, 100, 0.05)"
      #   }
      # equations.push({
      #   f: srcFun
      #   color: "rgba(0, 0, 100, 1.0)"
      # })
      # graph.draw({equations: equations})
    else
      $code.addClass("error")
  
  changeCallbacks = [refreshCode]
  fireChangeCallbacks = (args...) ->
    for c in changeCallbacks
      c(args...)
  
  cm = CodeMirror($code[0], {
    value: src
    mode: "text/x-glsl"
    # lineNumbers: true
    onChange: fireChangeCallbacks
  })
  cm.setSize("100%", $code.innerHeight())
  
  refreshCode()
  
  return {
    graph: graph
    cm: cm
    change: (c) -> changeCallbacks.push(c)
    get: () -> src
    compiled: () -> compiled
    substitute: (x) ->
      src.replace(/\bx\b/g, x)
    valueAt: (x) ->
      srcFun(x)
  }