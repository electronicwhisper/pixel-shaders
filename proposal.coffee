tex0 = new Image()




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


parseUniforms = (src) ->
  regex = XRegExp('uniform +(?<type>[^ ]+) +(?<name>[^ ;]+) *;', 'g')
  
  uniforms = []
  XRegExp.forEach(src, regex, (match) ->
    uniforms.push({
      type: match.type
      name: match.name
    })
  )
  return uniforms






buildEnv = (opts) ->
  
  src = opts.src
  appendDiv = $(opts.append || "body")
  inspectorHint = opts.inspector
  supplement = opts.supplement
  supplementOff = opts.supplementOff
  
  env = $("""
    <div class='env'>
      <div class='canvas'>
        <canvas class='maincanvas' width='300' height='300'></canvas>
        <canvas class='supplementcanvas' width='300' height='300'></canvas>
      </div>
      <div class='uniforms'></div>
      <div class='code'></div>
    </div>
    """)
  
  appendDiv.append(env)
  
  canvas = env.find(".maincanvas")[0]
  code = env.find(".code")[0]
  $uniforms = env.find(".uniforms")
  
  gl = canvas.getContext("experimental-webgl", {premultipliedAlpha: false})
  
  renderer = flatRenderer(gl)
  
  
  uniforms = []
  uniformGetters = {}
  errorLines = []
  
  draw = () ->
    # set uniforms
    for own name, getter of uniformGetters
      renderer.setUniform(name, getter())
    
    renderer.draw()
  
  codeChange = () ->
    # make uniforms html
    newUniforms = parseUniforms(cm.getValue())
    if !_.isEqual(uniforms, newUniforms)
      uniforms = newUniforms
      uniformGetters = {}
      $uniforms.html("")
      uniforms.forEach (u) ->
        if u.type == "float"
          input = $("<input type='range' min='0' max='1' step='.0001'>")
          input.change(draw)
          getter = () -> parseFloat(input.val())
        else if u.type == "sampler2D"
          input = $("<img src='tex0.jpg' width='60' height='60'>")
          getter = false
        
        $u = $("""
          <div class="uniform">
            <div class="name">#{u.name}</div>
            <div class="input"></div>
          </div>
        """)
        $u.find(".input").append(input)
        $uniforms.append($u)
        
        if getter
          uniformGetters[u.name] = getter
        
    
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
        cm.setMarker(line, "<div class='errorMessage'>#{error.error}</div>%N%", "errorMarker")
    else
      renderer.link()
      draw()
  
  
  cm = CodeMirror(code, {
    value: src
    mode: "text/x-glsl"
    lineNumbers: true
    onChange: codeChange
  })
  
  codeChange()
  
  if inspectorHint
    
    makeSpaces = (num) -> (" " for i in [0...num]).join("")
    round = (n) -> Math.round(n * 10000) / 10000
    convert = (n) ->
      if typeof n == "number"
        return round(n)
      else if typeof n == "string"
        return n
      else
        return "vec#{n.length}(#{n.map(round).join(', ')})"
    
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
        hints = ["(This mockup only shows line-by-line", "evaluation on the original code.)"]
      for line, i in lines
        if hints[i] || hints[i] == 0
          newLines.push("#{line}#{makeSpaces(maxLength - line.length)}  // #{convert(hints[i])}")
        else
          newLines.push(line)
      
      cm.setValue(newLines.join("\n"))
    
    $canvas = env.find(".canvas")
    updateWithEvent = (e) ->
      offset = $canvas.offset()
      x = (e.pageX - offset.left + 0.5) / $canvas.width()
      y = (1 - (e.pageY - offset.top + 0.5) / $canvas.height())
      update(x, y)
      
      if supplement
        supplementCtx = env.find(".supplementcanvas")[0].getContext("2d")
        supplement(cm, supplementCtx, x, y)
    $canvas.mouseover (e) ->
      originalValue = cm.getValue()
    $canvas.mousemove (e) ->
      updateWithEvent(e)
    $canvas.mouseout (e) ->
      cm.setValue(originalValue)
      if supplementOff
        supplementCtx = env.find(".supplementcanvas")[0].getContext("2d")
        supplementOff(cm, supplementCtx)
    $canvas.click (e) ->
      cm.setValue(src)
      originalValue = src
      updateWithEvent(e)






start = () ->
  
  
  buildEnv({
    append: "#example-live-code"
    src: """
      precision mediump float;
      
      varying vec2 position;
      
      void main() {
        gl_FragColor.r = position.x;
        gl_FragColor.g = 0.0;
        gl_FragColor.b = position.y;
        gl_FragColor.a = 1.0;
      }
      """
  })
  
  
  buildEnv({
    append: "#example-line-by-line"
    src: """
    precision mediump float;
    
    varying vec2 position;
    
    void main() {
      vec2 p = position - vec2(0.5, 0.5);
      
      float radius = length(p);
      float angle = atan(p.y, p.x);
      
      gl_FragColor.r = radius;
      gl_FragColor.g = 0.0;
      gl_FragColor.b = abs(angle / 3.14159);
      gl_FragColor.a = 1.0;
    }
    """
    inspector: (x, y) ->
      p = [x - 0.5, y - 0.5]
      radius = Math.sqrt(p[0]*p[0] + p[1]*p[1])
      angle = Math.atan2(p[1], p[0])
      [
        false,
        false,
        [x, y],
        false,
        false,
        p,
        false,
        radius,
        angle,
        false,
        radius,
        0,
        Math.abs(angle / 3.14159),
        1,
        false
      ]
    supplement: (cm, ctx, x, y) ->
      cm.setLineClass(7, null, "iso-1")
      cm.setMarker(7, "%N%", "iso-1")
      cm.setLineClass(8, null, "iso-2")
      cm.setMarker(8, "%N%", "iso-2")
      
      ctx.clearRect(0, 0, 300, 300)
      
      x = x - 0.5
      y = 1 - y - 0.5
      
      r = Math.sqrt(x*x + y*y)
      a = Math.atan(y, x)
      
      ctx.strokeStyle = "#f00"
      ctx.beginPath()
      ctx.arc(150, 150, r*300, 0, Math.PI*2, false)
      ctx.stroke()
      
      ctx.strokeStyle = "#0f0"
      ctx.beginPath()
      ctx.moveTo(150, 150)
      ctx.lineTo(150 + x * 600/r, 150 + y * 600/r)
      ctx.stroke()
    supplementOff: (cm, ctx) ->
      cm.setLineClass(7, null, null)
      cm.clearMarker(7)
      cm.setLineClass(8, null, null)
      cm.clearMarker(8)
      
      ctx.clearRect(0, 0, 300, 300)
  })


tex0.onload = start
tex0.src = "tex0.jpg"




# $(document).mousemove (e) ->
#   offset = $(".red").offset()
#   offset.left
