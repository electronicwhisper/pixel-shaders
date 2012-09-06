parseShaderError = (error) ->
  # Based on https://github.com/mrdoob/glsl-sandbox/blob/master/static/index.html
  
  # Remove trailing linefeed, for FireFox's benefit.
  while ((error.length > 1) && (error.charCodeAt(error.length - 1) < 32))
    error = error.substring(0, error.length - 1)
  
  parsed = []
  index = 0
  while index >= 0
    index = error.indexOf("ERROR: 0:", index)
    if index < 0
      break
    index += 9;
    indexEnd = error.indexOf(':', index)
    if (indexEnd > index)
      lineNum = parseInt(error.substring(index, indexEnd))
      index = indexEnd + 1
      indexEnd = error.indexOf("ERROR: 0:", index)
      lineError = if indexEnd > index then error.substring(index, indexEnd) else error.substring(index)
      parsed.push({
        lineNum: lineNum
        error: lineError
      })
  return parsed


buildEnv = (src, inspectorHint) ->
  env = $("<div class='env'><canvas></canvas><div class='code'></div></div>")
  
  $("body").append(env)
  
  canvas = env.find("canvas")[0]
  code = env.find(".code")[0]
  
  gl = canvas.getContext("experimental-webgl", {premultipliedAlpha: false})
  
  renderer = flatRenderer(gl)
  
  
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
  
  cm = CodeMirror(code, {
    value: src
    mode: "text/x-glsl"
    lineNumbers: true
    onChange: refresh
  })
  
  refresh()
  
  if inspectorHint
    
    makeSpaces = (num) -> (" " for i in [0...num]).join("")
    convert = (n) ->
      if typeof n == "number"
        return n.toFixed(4)
      else if typeof n == "string"
        return n
      else
        return "vec#{n.length}(#{n.map((x) -> x.toFixed(4)).join(', ')})"
    
    originalValue = src
    
    update = (x, y) ->
      lines = originalValue.split("\n")
      
      maxLength = 0
      for line in lines
        if line.length > maxLength
          maxLength = line.length
      
      newLines = []
      if originalValue == src
        hints = inspectorHint(x, y)
      else
        hints = ["This mockup can only show line-by-line", "evaluation on the original code."]
      for line, i in lines
        if hints[i] || hints[i] == 0
          newLines.push("#{line}#{makeSpaces(maxLength - line.length)}  // #{convert(hints[i])}")
        else
          newLines.push(line)
      
      cm.setValue(newLines.join("\n"))
    
    $canvas = $(canvas)
    updateWithEvent = (e) ->
      offset = $canvas.offset()
      x = (e.pageX - offset.left) / $canvas.width()
      y = (1 - (e.pageY - offset.top) / $canvas.height())
      update(x, y)
    $canvas.mouseover (e) ->
      originalValue = cm.getValue()
    $canvas.mousemove (e) ->
      updateWithEvent(e)
    $canvas.mouseout (e) ->
      cm.setValue(originalValue)
    $canvas.click (e) ->
      cm.setValue(src)
      originalValue = src
      updateWithEvent(e)



buildEnv("""
  precision mediump float;
  
  varying vec2 position;
  
  void main() {
    gl_FragColor.r = position.x;
    gl_FragColor.g = 0.0;
    gl_FragColor.b = 0.0;
    gl_FragColor.a = 1.0;
  }
  """,
  (x, y) ->
    [
      false,
      false,
      [x, y],
      false,
      false,
      x,
      0,
      0,
      1,
      false
    ]
)


#
buildEnv("""
  precision mediump float;
  
  varying vec2 position;
  
  void main() {
    gl_FragColor.r = position.x;
    gl_FragColor.g = 0.0;
    gl_FragColor.b = position.y;
    gl_FragColor.a = 1.0;
  }
  """,
  (x, y) ->
    [
      false,
      false,
      [x, y],
      false,
      false,
      x,
      0,
      y,
      1,
      false
    ]
)
