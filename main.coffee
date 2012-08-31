vertexShaderSource = """
precision mediump float;

attribute vec2 a_position;
attribute vec2 a_texCoord;
varying vec2 v_texCoord;

void main() {
  gl_Position = vec4(a_position, 0, 1);
  v_texCoord = a_texCoord;
}
"""


fragmentShaderSource = """
precision mediump float;

varying vec2 v_texCoord;
void main() {
  gl_FragColor = vec4(v_texCoord,0,1);
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




makePixelShader = (gl) ->
  
  vertexShader = compileShader(gl, vertexShaderSource, gl.VERTEX_SHADER)
  fragmentShader = compileShader(gl, fragmentShaderSource, gl.FRAGMENT_SHADER)
  
  program = gl.createProgram()
  
  gl.attachShader(program, vertexShader)
  gl.attachShader(program, fragmentShader)
  
  gl.linkProgram(program)
  
  gl.useProgram(program)
  
  
  # look up where the texture coordinates need to go.
  texCoordLocation = gl.getAttribLocation(program, "a_texCoord")
  # provide texture coordinates for the rectangle.
  texCoordBuffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, texCoordBuffer)
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
      0.0,  0.0,
      1.0,  0.0,
      0.0,  1.0,
      0.0,  1.0,
      1.0,  0.0,
      1.0,  1.0]), gl.STATIC_DRAW)
  gl.enableVertexAttribArray(texCoordLocation)
  gl.vertexAttribPointer(texCoordLocation, 2, gl.FLOAT, false, 0, 0)
  
  # look up where the vertex data needs to go.
  positionLocation = gl.getAttribLocation(program, "a_position")
  # Create a buffer and put a single clipspace rectangle in it (2 triangles)
  buffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
  gl.bufferData(
      gl.ARRAY_BUFFER, 
      new Float32Array([
          -1.0, -1.0, 
           1.0, -1.0, 
          -1.0,  1.0, 
          -1.0,  1.0, 
           1.0, -1.0, 
           1.0,  1.0]), 
      gl.STATIC_DRAW)
  gl.enableVertexAttribArray(positionLocation)
  gl.vertexAttribPointer(positionLocation, 2, gl.FLOAT, false, 0, 0)
  
  
  return {
    loadFragmentShader: (source) ->
      shader = compileShader(gl, source, gl.FRAGMENT_SHADER)
      err = getShaderError(gl, shader)
      if err
        return err
      else
        # detach and delete old shader
        gl.detachShader(program, fragmentShader)
        gl.deleteShader(fragmentShader)
        
        fragmentShader = shader
        gl.attachShader(program, fragmentShader)
        return null
    
    link: () ->
      gl.linkProgram(program)
      # TODO check for errors
      return null
    
    draw: () ->
      gl.drawArrays(gl.TRIANGLES, 0, 6)
  }


canvas = document.getElementById("canvas")
gl = canvas.getContext("experimental-webgl")

ps = makePixelShader(gl)

draw = () ->
  err = ps.loadFragmentShader(cm.getValue())
  if err
    document.getElementById("status").innerHTML = err
  else
    document.getElementById("status").innerHTML = ""
    ps.link()
    ps.draw()

cm = CodeMirror(document.getElementById("rasterCode"), {
  value: fragmentShaderSource
  mode: "text/x-glsl"
  onChange: draw
})

draw()