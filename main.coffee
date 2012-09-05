vertexShaderSource = """
precision mediump float;

attribute vec3 vertexPosition;
varying vec2 position;

void main() {
  gl_Position = vec4(vertexPosition, 1.0);
  position = (vertexPosition.xy + 1.0) * 0.5;
}
"""


fragmentShaderSource = """
precision mediump float;

varying vec2 position;

void main() {
  gl_FragColor = vec4(1, 0, 0, 1);
}
"""


compileShader = (gl, shaderSource, shaderType) ->
  shader = gl.createShader(shaderType)
  gl.shaderSource(shader, shaderSource)
  gl.compileShader(shader)
  return shader

getShaderError = (gl, shader) ->
  compiled = gl.getShaderParameter(shader, gl.COMPILE_STATUS)
  if !compiled
    return gl.getShaderInfoLog(shader)
  else
    return null

bufferAttribute = (gl, program, attrib, data, size=2) ->
  location = gl.getAttribLocation(program, attrib)
  buffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(data), gl.STATIC_DRAW)
  gl.enableVertexAttribArray(location)
  gl.vertexAttribPointer(location, size, gl.FLOAT, false, 0, 0)


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


makeFlatRenderer = (gl) ->
  program = gl.createProgram()
  
  shaders = {} # used to keep track of the shaders we've attached to program, so that we can detach them later
  
  shaders[gl.VERTEX_SHADER] = compileShader(gl, vertexShaderSource, gl.VERTEX_SHADER)
  shaders[gl.FRAGMENT_SHADER] = compileShader(gl, fragmentShaderSource, gl.FRAGMENT_SHADER)
  
  gl.attachShader(program, shaders[gl.VERTEX_SHADER])
  gl.attachShader(program, shaders[gl.FRAGMENT_SHADER])
  
  gl.linkProgram(program)
  
  gl.useProgram(program)
  
  bufferAttribute(gl, program, "vertexPosition", [
    -1.0, -1.0, 
     1.0, -1.0, 
    -1.0,  1.0, 
    -1.0,  1.0, 
     1.0, -1.0, 
     1.0,  1.0
  ])
  
  replaceShader = (shaderSource, shaderType) ->
    shader = compileShader(gl, shaderSource, shaderType)
    err = getShaderError(gl, shader)
    if err
      gl.deleteShader(shader)
      return err
    else
      # detach and delete old shader
      gl.detachShader(program, shaders[shaderType])
      gl.deleteShader(shaders[shaderType])
      
      # attach new shader, keep track of it in shaders
      gl.attachShader(program, shader)
      shaders[shaderType] = shader
      
      return null
  
  
  return {
    loadFragmentShader: (shaderSource) ->
      replaceShader(shaderSource, gl.FRAGMENT_SHADER)
    
    link: () ->
      gl.linkProgram(program)
      # TODO check for errors
      return null
    
    draw: () ->
      gl.drawArrays(gl.TRIANGLES, 0, 6)
  }


canvas = document.getElementById("canvas")
gl = canvas.getContext("experimental-webgl", {premultipliedAlpha: false})

renderer = makeFlatRenderer(gl)



errorLines = []
draw = () ->
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
    
    # document.getElementById("status").innerHTML = err
  else
    document.getElementById("status").innerHTML = ""
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
  onChange: draw
})

draw()