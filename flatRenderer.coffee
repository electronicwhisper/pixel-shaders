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
    
    setUniform: (name, value, size) ->
      location = gl.getUniformLocation(program, name)
      if typeof value == "number"
        value = [value]
      if !size
        size = value.length
      switch size
        when 1 then gl.uniform1fv(location, value)
        when 2 then gl.uniform2fv(location, value)
        when 3 then gl.uniform3fv(location, value)
        when 4 then gl.uniform4fv(location, value)
    
    draw: () ->
      gl.drawArrays(gl.TRIANGLES, 0, 6)
  }



window.flatRenderer = makeFlatRenderer