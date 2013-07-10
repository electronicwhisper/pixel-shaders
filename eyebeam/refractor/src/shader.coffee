###
opts
  canvas: Canvas DOM element
  vertex: glsl source string
  fragment: glsl source string
  uniforms: a hash of names to values, the type is inferred as follows:
    Number or [Number]: float
    [Number, Number]: vec2
    [Number, Number, Number]: vec3
    [Number, Number, Number, Number]: vec4
    DOMElement: Sampler2D (e.g. Image/Video/Canvas)
    TODO: a way to force an arbitrary type


to set uniforms,

###

# _ = require("underscore")






module.exports = (opts) ->
  # =============================================
  # public state
  # =============================================
  o = {
    vertex: null
    fragment: null
    uniforms: {}
    canvas: opts.canvas
  }


  # =============================================
  # internal state
  # =============================================
  gl = null
  program = null
  shaders = {} # maps gl.VERTEX_SHADER and gl.FRAGMENT_SHADER to their respective attached shaders
  textures = [] # an array mapping texture unit indices to objects:
    # {
    #   i: index of texture unit (0 - 31)
    #   texture: gl texture, i.e. created by gl.createTexture()
    #   element: DOMElement
    # }


  # =============================================
  # methods
  # =============================================
  getTexture = (element) ->
    for t in textures
      if t.element == element
        return t

    # if we got here, we need to make a new texture
    i = textures.length # TODO: instead find the first empty texture (i.e. one that's been deleted)
    texture = gl.createTexture()
    textures[i] = {
      element: element,
      texture: texture
      i: i
    }
    gl.activeTexture(gl.TEXTURE0 + i)
    gl.bindTexture(gl.TEXTURE_2D, texture)

    # Set these things...
    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

    return textures[i]


  replaceShader = (src, type) ->
    if shaders[type]
      gl.detachShader(program, shaders[type])

    shader = gl.createShader(type)
    gl.shaderSource(shader, src)
    gl.compileShader(shader)
    gl.attachShader(program, shader)
    gl.deleteShader(shader)
    shaders[type] = shader


  bufferAttribute = (attrib, data, size=2) ->
    location = gl.getAttribLocation(program, attrib)
    buffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(data), gl.STATIC_DRAW)
    gl.enableVertexAttribArray(location)
    gl.vertexAttribPointer(location, size, gl.FLOAT, false, 0, 0)


  setUniform = (name, value) ->
    # find the location for the uniform
    location = gl.getUniformLocation(program, name)

    # set the uniform based on value's type
    if _.isNumber(value)
      gl.uniform1fv(location, [value])

    else if _.isArray(value)
      switch value.length
        when 1 then gl.uniform1fv(location, value)
        when 2 then gl.uniform2fv(location, value)
        when 3 then gl.uniform3fv(location, value)
        when 4 then gl.uniform4fv(location, value)
        # TODO: the following is hacky
        when 9 then gl.uniformMatrix3fv(location, false, value)

    else if value.nodeName # looks like a DOM element
      texture = getTexture(value)
      # draw the element into the texture
      gl.activeTexture(gl.TEXTURE0 + texture.i)
      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, value)
      # set the uniform to point to the texture's index
      gl.uniform1i(location, texture.i)

    else if !value
      # value is falsy
      # TODO: delete the uniform
      # TODO: delete the texture from textures
      false


  set = (opts) ->
    if opts.vertex
      o.vertex = opts.vertex
      replaceShader(o.vertex, gl.VERTEX_SHADER)

    if opts.fragment
      o.fragment = opts.fragment
      replaceShader(o.fragment, gl.FRAGMENT_SHADER)

    if opts.vertex || opts.fragment
      gl.linkProgram(program)
      gl.useProgram(program)

    if opts.uniforms
      for own name, value of opts.uniforms
        o.uniforms[name] = value
        setUniform(name, value)

    if opts.vertex || opts.fragment
      # need to refresh uniforms
      for own name, value of o.uniforms
        setUniform(name, value)


  draw = (opts={}) ->
    set(opts)
    gl.drawArrays(gl.TRIANGLES, 0, 6)


  # =============================================
  # initialize
  # =============================================
  gl = opts.canvas.getContext("experimental-webgl", {premultipliedAlpha: false})
  program = gl.createProgram()

  set(opts)

  gl.useProgram(program)
  bufferAttribute("vertexPosition", [
    -1.0, -1.0,
     1.0, -1.0,
    -1.0,  1.0,
    -1.0,  1.0,
     1.0, -1.0,
     1.0,  1.0
  ])

  draw()


  return {
    get: () -> o
    set: set
    draw: draw
    readPixels: () ->
      draw()
      w = gl.drawingBufferWidth
      h = gl.drawingBufferHeight
      arr = new Uint8Array(w * h * 4)
      gl.readPixels(0, 0, w, h, gl.RGBA, gl.UNSIGNED_BYTE, arr)
      return arr
    resize: () ->
      # call this when the canvas's width or height change
      # TODO
    ctx: () -> gl
  }




