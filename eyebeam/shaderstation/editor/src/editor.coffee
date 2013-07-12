flatRenderer = require("flatRenderer")
util = require("util")


window.startTime = Date.now()


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

  uniforms = {}





  # hacked in
  gl = ctx
  texture = gl.createTexture()
  gl.bindTexture(gl.TEXTURE_2D, texture)
  gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true)
  # Set the parameters so we can render any size image.
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

  updateWebcam = () ->
    webcamVideo = require("webcam")()
    if webcamVideo
      # Upload the image into the texture.
      try
        gl.activeTexture(gl.TEXTURE0)
        gl.bindTexture(gl.TEXTURE_2D, texture)
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, webcamVideo)







  draw = () ->

    if uniforms.webcam
      # hack
      updateWebcam()
      renderer.hackSetUniformInt("webcam", 0)


    renderer.draw({
      time: (Date.now() - window.startTime)/1000
      resolution: [canvas.width, canvas.height]
    })

  findUniforms = () ->
    uniforms = {}
    newUniforms = require("parse").uniforms(src)
    drawEveryFrame = false
    for u in newUniforms
      uniforms[u.name] = u.type
      if u.name == "time" || u.name == "webcam"
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

    $(".errorDiv").remove()
    $(".errorMarker").each ->
      $el = $(this)
      offset = $el.offset()

      $errorDiv = $("""
      <div class="errorDiv" style="position: absolute; width: 400px; margin-left: -400px; font-size: 13px; font-family: monospace; background-color: rgba(0, 0, 0, 0.9); color: #fff;">
      #{$el.find(".errorMessage").text()}
      </div>
      """)

      $errorDiv.css({left: offset.left, top: offset.top})

      $("body").append($errorDiv)

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
    matchBrackets: true
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