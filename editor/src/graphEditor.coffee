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
  
  
  
  refreshCode = () ->
    src = cm.getValue()
    worked = true
    try
      srcFun = evaluate.functionOfX(src)
      srcFun(0); # test it once while in try-catch land
    catch e
      worked = false
    if worked
      equations = [{
        color: "#006"
        f: srcFun
      }]
      graph.draw({equations: equations})
  
  cm = CodeMirror($code[0], {
    value: src
    mode: "text/x-glsl"
    # lineNumbers: true
    onChange: refreshCode
  })
  cm.setSize("100%", $code.innerHeight())
  
  refreshCode()