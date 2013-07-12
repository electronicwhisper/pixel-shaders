module.exports = {
  shaderError: (error) ->
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
  
  uniforms: (src) ->
    regex = XRegExp('uniform +(?<type>[^ ]+) +(?<name>[^ ;]+) *;', 'g')
    
    uniforms = []
    XRegExp.forEach(src, regex, (match) ->
      uniforms.push({
        type: match.type
        name: match.name
      })
    )
    return uniforms
}