flatRenderer = require("flatRenderer")


startTime = Date.now()


expandCanvas = (canvas) ->
  $canvas = $(canvas)
  $canvas.attr({width: $canvas.innerWidth(), height: $canvas.innerHeight()})

makeEditor = (opts) ->
  
  src = opts.src
  $output = $(opts.output)
  $code = $(opts.code)
  
  $canvas = $("<canvas />")
  $output.append($canvas)
  expandCanvas($canvas)
  ctx = $canvas[0].getContext("experimental-webgl", {premultipliedAlpha: false})
  
  renderer = flatRenderer(ctx)
  
  draw = () ->
    renderer.setUniform("time", (Date.now() - startTime)/1000)
    renderer.draw()
  
  errorLines = []
  markErrors = (errors) ->
    # clear previous error lines
    for line in errorLines
      cm.setLineClass(line, null, null)
      cm.clearMarker(line)
    errorLines = []
    $.fn.tipsy.revalidate()
    
    # mark new errors
    for error in errors
      line = cm.getLineHandle(error.lineNum - 1)
      errorLines.push(line)
      cm.setLineClass(line, null, "errorLine")
      cm.setMarker(line, "<div class='errorMessage'>#{error.error}</div>%N%", "errorMarker")
  
  refreshCode = () ->
    src = cm.getValue()
    err = renderer.loadFragmentShader(src)
    if err
      errors = require("parse").shaderError(err)
      markErrors(errors)
    else
      markErrors([])
      renderer.link()
      # draw()
  
  
  cm = CodeMirror($code[0], {
    value: src
    mode: "text/x-glsl"
    lineNumbers: true
    onChange: refreshCode
  })
  cm.setSize("100%", $code.innerHeight())
  
  refreshCode()
  
  update = () ->
    draw()
    requestAnimationFrame(update)
  update()
  
  return {
    set: (newSrc) ->
      cm.setValue(newSrc)
  }



$(".errorMarker").tipsy({
  live: true
  gravity: "e"
  opacity: 1.0
  title: () -> $(this).find(".errorMessage").text()
});



module.exports = makeEditor