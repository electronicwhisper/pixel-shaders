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
      equations = [{
        color: "#006"
        f: srcFun
      }]
      graph.draw({equations: equations})
    else
      $code.addClass("error")
  
  cm = CodeMirror($code[0], {
    value: src
    mode: "text/x-glsl"
    # lineNumbers: true
    onChange: refreshCode
  })
  cm.setSize("100%", $code.innerHeight())
  
  refreshCode()
  
  return {
    graph: graph
    get: () -> src
    compiled: () -> compiled
    substitute: (x) ->
      src.replace(/\bx\b/g, x)
    valueAt: (x) ->
      srcFun(x)
  }