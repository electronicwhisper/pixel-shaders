vertexShaderSource = """
attribute vec2 a_position;

void main() {
  gl_Position = vec4(a_position, 0, 1);
}
"""


fragmentShaderSource = """
void main() {
  gl_FragColor = vec4(0,1,0,1);  // green
}
"""




canvas = document.getElementById("canvas")
gl = canvas.getContext("experimental-webgl")

vertexShader = loadShader(gl, vertexShaderSource, gl.VERTEX_SHADER)
fragmentShader = loadShader(gl, fragmentShaderSource, gl.FRAGMENT_SHADER)

program = createProgram(gl, [vertexShader, fragmentShader])
gl.useProgram(program)

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

# draw
gl.drawArrays(gl.TRIANGLES, 0, 6)



window.loadNew = loadNew = () ->
  newFragmentShader = loadShader(gl, cm.getValue(), gl.FRAGMENT_SHADER)
  
  gl.detachShader(program, fragmentShader)
  gl.attachShader(program, newFragmentShader)
  
  gl.linkProgram(program)
  
  fragmentShader = newFragmentShader
  
  gl.drawArrays(gl.TRIANGLES, 0, 6)




#
cm = CodeMirror(document.getElementById("rasterCode"), {
  value: """
  void main() {
    gl_FragColor = vec4(1,1,0,1);  // green
  }
  """
  onChange: loadNew
})