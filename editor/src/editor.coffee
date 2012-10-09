flatRenderer = require("flatRenderer")
util = require("util")


startTime = Date.now()


makeEditor = (opts) ->
  
  src = opts.src
  $output = $(opts.output)
  $code = $(opts.code)
  
  $canvas = $("<canvas />")
  canvas = $canvas[0]
  $output.append($canvas)
  util.expandCanvas($canvas)
  ctx = $canvas[0].getContext("experimental-webgl", {premultipliedAlpha: false})
  
  renderer = flatRenderer(ctx)
  
  drawEveryFrame = false
  
  changeCallback = null
  
  draw = () ->
    renderer.draw({
      time: (Date.now() - startTime)/1000
      resolution: [canvas.width, canvas.height]
    })
  
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
    if changeCallback
      changeCallback(src)
  
  
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
  
  # redraw when the window gains focus (to eliminate glitches)
  $(window).focus(draw)
  
  editor = {
    get: () -> src
    set: (newSrc) ->
      cm.setValue(newSrc)
    snapshot: (width, height) ->
      canvas = $canvas[0]
      # if width is specified, resize the canvas (temporarily)
      if width
        oldWidth = canvas.width
        oldHeight = canvas.height
        canvas.width = width
        canvas.height = height
        ctx.viewport(0, 0, width, height)
      # take the snapshot
      draw()
      data = canvas.toDataURL('image/png')
      # reset width and height
      if width
        canvas.width = oldWidth
        canvas.height = oldHeight
        ctx.viewport(0, 0, oldWidth, oldHeight)
        draw()
      return data
    readPixels: renderer.readPixels
    onchange: (callback) ->
      changeCallback = callback
  }
  
  # for debugging
  $canvas.data("editor", editor)
  
  return editor



$(".errorMarker").tipsy({
  live: true
  gravity: "e"
  opacity: 1.0
  title: () -> $(this).find(".errorMessage").text()
});



module.exports = makeEditor