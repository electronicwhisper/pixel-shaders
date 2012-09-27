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
  
  drawEveryFrame = false
  
  draw = () ->
    renderer.setUniform("time", (Date.now() - startTime)/1000)
    renderer.draw()
  
  findUniforms = () ->
    newUniforms = require("parse").uniforms(src)
    drawEveryFrame = false
    for u in newUniforms
      if u.name == "time"
        drawEveryFrame = true
  
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
      findUniforms()
      renderer.link()
      if !drawEveryFrame
        draw()
  
  
  cm = CodeMirror($code[0], {
    value: src
    mode: "text/x-glsl"
    lineNumbers: true
    onChange: refreshCode
  })
  cm.setSize("100%", $code.innerHeight())
  
  refreshCode()
  
  update = () ->
    if drawEveryFrame
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