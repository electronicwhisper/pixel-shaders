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
        lineNum: lineNum - 1 # for 0-based line numbering
        error: lineError
      })
  return parsed


# dummy webgl context for compiling and checking errors
canvas = document.createElement("canvas")
gl = canvas.getContext("experimental-webgl")

module.exports = (src) ->
  
  shader = gl.createShader(gl.FRAGMENT_SHADER)
  gl.shaderSource(shader, src)
  gl.compileShader(shader)
  
  compiled = gl.getShaderParameter(shader, gl.COMPILE_STATUS)
  if !compiled
    log = gl.getShaderInfoLog(shader)
    return parseShaderError(log)
  else
    return false
  