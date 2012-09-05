
canvas = document.getElementById("canvas")
gl = canvas.getContext("experimental-webgl", {premultipliedAlpha: false})

window.renderer = renderer = flatRenderer(gl)



errorLines = []
refresh = () ->
  # clear previous error lines
  for line in errorLines
    cm.setLineClass(line, null, null)
    cm.clearMarker(line)
  errorLines = []
  
  err = renderer.loadFragmentShader(cm.getValue())
  if err
    errors = parseShaderError(err)
    
    for error in errors
      line = cm.getLineHandle(error.lineNum - 1)
      errorLines.push(line)
      cm.setLineClass(line, null, "errorLine")
      cm.setMarker(line, "%N%", "errorMarker")
  else
    renderer.link()
    renderer.draw()





cm = CodeMirror(document.getElementById("rasterCode"), {
  value: """
  precision mediump float;

  varying vec2 position;

  void main() {
    gl_FragColor.r = position.x;
    gl_FragColor.g = 0.0;
    gl_FragColor.b = 0.0;
    gl_FragColor.a = 1.0;
  }
  """
  mode: "text/x-glsl"
  lineNumbers: true
  onChange: refresh
})

refresh()