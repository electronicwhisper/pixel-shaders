ko = require("knockout")
$ = require("jquery")
_ = require("underscore")

# ======================================================= Canvas Util

clear = (ctx) ->
  w = ctx.canvas.width
  h = ctx.canvas.height
  ctx.clearRect(0, 0, w, h)

sizeCanvas = (canvas) ->
  w = $(canvas).width()
  h = $(canvas).height()
  canvas.width = w
  canvas.height = h

# ======================================================= Animation Util

rafAnimate = (callback) ->
  animate = () ->
    require("raf")(animate)
    callback()
  animate()

# ======================================================= drawGrid

ko.bindingHandlers.drawGrid = {
  init: (element, valueAccessor) ->
    o = valueAccessor()
    sizeCanvas(element)
    ctx = element.getContext("2d")
    draw = () ->
      clear(ctx)
      bounds = o.bounds()
      opts = {
        ctx: ctx
        minX: bounds.minX
        maxX: bounds.maxX
        minY: bounds.minY
        maxY: bounds.maxY
        flipY: true
        color: "0,0,0"
        shadow: false
      }
      if o.color == "white"
        opts.color = "255,255,255"
        opts.shadow = true
      else if o.color == "black"
        opts.color = "0,0,0"
        opts.shadow = false
      require("graph-grid")(opts)
    ko.computed(draw)
}

# ======================================================= panAndZoom

ko.bindingHandlers.panAndZoom = {
  init: (element, valueAccessor) ->
    o = valueAccessor()
    pz = require("pan-zoom")({
      element: element
      flipY: true
    })
    ko.computed () ->
      bounds = o.bounds()
      pz.minX = bounds.minX
      pz.maxX = bounds.maxX
      pz.minY = bounds.minY
      pz.maxY = bounds.maxY
    pz.on("update", () ->
      o.bounds({
        minX: pz.minX
        maxX: pz.maxX
        minY: pz.minY
        maxY: pz.maxY
      })
    )
}

# ======================================================= editorShader

# TODO: this probably wants to be its own file
XRegExp = require('xregexp').XRegExp
parseUniforms = (src) ->
  regex = XRegExp('uniform +(?<type>[^ ]+) +(?<name>[^ ;]+) *;', 'g')
  
  uniforms = {}
  XRegExp.forEach(src, regex, (match) ->
    uniforms[match.name] = {
      type: match.type
    }
  )
  return uniforms

ko.bindingHandlers.editorShader = {
  init: (element, valueAccessor) ->
    o = valueAccessor()
    editor = require("editor")({
      div: element
      src: o.src()
      multiline: true
    })
    
    editor.on "change", () ->
      o.compiled(false)
      o.src(editor.src())
    
    # compile and mark errors
    ko.computed () ->
      src = o.src()
      errors = require("glsl-error")(src)
      editor.set({
        errors: errors
      })
      
      compiled = !_.some(errors)
      o.compiled(compiled)
    
    # update uniforms
    ko.computed () ->
      if o.compiled()
        src = o.src()
        # TODO: make it not clear set values, we'll need to .peek() at uniforms
        o.uniforms(parseUniforms(src))
    
    # # annotate based on uniforms
    # ko.computed () ->
    #   if o.compiled()
    #     uniforms = o.uniforms()
    #     for own name, uniform of uniforms
    #       if name == "time"
    #         lines = o.src.peek().split("\n")
    #         line = lines.indexOf("uniform float time;")
    #         editor.set({
    #           annotations: [{line: line, message: uniform.value}]
    #         })
}


# ======================================================= editorLine

ko.bindingHandlers.editorLine = {
  init: (element, valueAccessor) ->
    o = valueAccessor()
    editor = require("editor")({
      div: element
      src: o.src()
      multiline: false
    })
    
    editor.on "change", () ->
      o.src(editor.src())
}


# ======================================================= drawShader

vertexShaderSource = """
precision mediump float;

attribute vec3 vertexPosition;
varying vec2 position;
uniform vec2 boundsMin;
uniform vec2 boundsMax;

void main() {
  gl_Position = vec4(vertexPosition, 1.0);
  position = mix(boundsMin, boundsMax, (vertexPosition.xy + 1.0) * 0.5);
}
"""

ko.bindingHandlers.drawShader = {
  init: (element, valueAccessor) ->
    o = valueAccessor()
    
    shader = require("shader")({
      canvas: element
      vertex: vertexShaderSource
      fragment: o.src()
    })
    
    draw = () ->
      shader.draw()
    
    # src updates
    ko.computed () ->
      if o.compiled()
        shader.set({fragment: o.src()})
        draw()
    
    # bounds updates
    ko.computed () ->
      uniformValues = {}
      uniformValues.boundsMin = [o.bounds().minX, o.bounds().minY]
      uniformValues.boundsMax = [o.bounds().maxX, o.bounds().maxY]
      shader.set({uniforms: uniformValues})
      draw()
    
    # uniforms updates
    ko.computed () ->
      uniforms = o.uniforms()
      uniformValues = {}
      for own name, uniform of uniforms
        if uniform.value != undefined
          uniformValues[name] = uniform.value
      shader.set({uniforms: uniformValues})
      draw()
}



# TODO: this will be part of the uniform itself, so we can have separate, controllable timelines
startTime = Date.now()
updateUniforms = (uniformsObservable) ->
  uniforms = uniformsObservable()
  changed = false
  
  for own name, uniform of uniforms
    if name == "time" && uniform.type == "float"
      uniform.value = (Date.now() - startTime) / 1000
      changed = true
    else if name == "webcam" && uniform.type == "sampler2D"
      uniform.value = require("webcam")()
      changed = true
  
  if changed
    uniformsObservable(uniforms)












templates = {
  shaderExample: """
  <div class="book-view-edit">
    <div class="book-view" data-bind="panAndZoom: {bounds: bounds}">
      <canvas data-bind="drawShader: {bounds: bounds, src: src, compiled: compiled, uniforms: uniforms}"></canvas>
      <canvas class="book-grid" data-bind="drawGrid: {bounds: bounds, color: 'white'}"></canvas>
    </div>
    <div class="book-edit book-editor" data-bind="editorShader: {src: src, compiled: compiled, uniforms: uniforms}">
    </div>
  </div>
  """
  
}

# TODO
makeShaderExample = (src) ->
  fragmentShaderSource = """
  precision mediump float;
  
  varying vec2 position;
  
  void main() {
    gl_FragColor.r = position.x;
    gl_FragColor.g = position.y;
    gl_FragColor.b = 0.0;
    gl_FragColor.a = 1.0;
  }
  """
  
  model = {
    bounds: ko.observable({
      minX: 0
      minY: 0
      maxX: 1
      maxY: 1
    })
    src: ko.observable(fragmentShaderSource)
    compiled: ko.observable(false)
    uniforms: ko.observable({})
  }
  rafAnimate () ->
    updateUniforms(model.uniforms)




floatToString = (n, significantDigits) ->
  n.toPrecision(significantDigits)
vecToString = (x, significantDigits) ->
  fts = (n) ->
    floatToString(n, significantDigits)
  
  if x.length == 1
    fts(x[0])
  else
    s = (fts(n) for n in x).join(", ")
    return "vec#{x.length}(#{s})"


do ->
  model = {
    src: ko.observable("3. + 5.")
    result: ko.observable("")
  }
  
  ko.computed () ->
    src = model.src()
    try
      ast = require("parse-glsl").parse(src, "assignment_expression")
      console.log ast
      require("interpret")({}, ast)
      
      
      result = vecToString(ast.evaluated, 3)
      console.log result
      model.result(result)
  
  ko.applyBindings(model)