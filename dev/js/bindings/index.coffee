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

# ======================================================= String Util

srcTrim = (s) ->
  lines = s.split("\n")
  indent = Infinity
  for line in lines
    lineIndent = line.search(/[^ ]/)
    indent = Math.min(indent, lineIndent) if lineIndent != -1
  if indent != Infinity
    lines = for line in lines
      line.substr(indent)
  return lines.join("\n").trim()


# TODO finish moving this to interpret
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

ko.bindingHandlers.editorShader = {
  init: (element, valueAccessor) ->
    o = valueAccessor()
    editor = require("editor")({
      div: element
      src: o.src()
      multiline: o.multiline
    })
    
    editor.on "change", () ->
      o.src(editor.src())
    
    if o.errors
      ko.computed () ->
        editor.set({
          errors: o.errors()
        })
    
    if o.annotations
      ko.computed () ->
        editor.set({
          annotations: o.annotations()
        })
}


# ======================================================= syntaxHighlight

# TODO: figure out why runMode is making .int and .float instead of .cm-int and .cm-float
ko.bindingHandlers.syntaxHighlight = {
  update: (element, valueAccessor) ->
    v = ko.utils.unwrapObservable(valueAccessor())
    require("codemirror").runMode(v, "text/x-glsl", element)
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













buildShaderExample = ($replace) ->
  src = srcTrim($replace.text())
  
  $div = $("""
  <div class="book-view-edit">
    <div class="book-view" data-bind="panAndZoom: {bounds: bounds}">
      <canvas data-bind="drawShader: {bounds: bounds, src: compiledSrc, uniforms: uniforms}"></canvas>
      <canvas class="book-grid" data-bind="drawGrid: {bounds: bounds, color: 'white'}"></canvas>
    </div>
    <div class="book-edit book-editor" data-bind="editorShader: {src: src, multiline: true, errors: errors, annotations: annotations}">
    </div>
  </div>
  """)
  
  model = {
    bounds: ko.observable({
      minX: 0
      minY: 0
      maxX: 1
      maxY: 1
    })
    src: ko.observable(src)
    compiledSrc: ko.observable(src)
    errors: ko.observable([])
    annotations: ko.observable([])
    uniforms: ko.observable({})
  }
  
  rafAnimate () ->
    updateUniforms(model.uniforms)
  
  # compile and mark errors
  ko.computed () ->
    src = model.src()
    errors = require("glsl-error")(src)
    model.errors(errors)
    
    if !_.some(errors)
      model.compiledSrc(src)
  
  # update uniforms
  ko.computed () ->
    src = model.compiledSrc()
    # TODO: make it not clear set values, we'll need to .peek() at uniforms
    model.uniforms(parseUniforms(src))
  
  
  # # annotate based on uniforms
  # (ko.computed () ->
  #   uniforms = model.uniforms()
  #   for own name, uniform of uniforms
  #     if name == "time"
  #       lines = model.compiledSrc.peek().split("\n")
  #       line = lines.indexOf("uniform float time;")
  #       model.annotations([{line: line, message: uniform.value}])
  # ).extend({ throttle: 1 })
  # # TODO: do I really need this throttle?
  
  ko.computed () ->
    src = model.compiledSrc()
    try
      ast = require("parse-glsl").parse(src, "fragment_start")
      window.debug = ast
      require("interpret")({
        gl_FragColor: [0, 0, 0, 0]
        position: [0.5, 0.5]
      }, ast)
      annotations = require("interpret").extractStatements(ast)
      model.annotations(annotations)
    catch e
      console.log ast
      throw e
      
      model.annotations([])
  
  
  $replace.replaceWith($div)
  
  ko.applyBindings(model, $div[0]) # for sizing, this has to be after the div has been added to the body







buildEvaluator = ($replace) ->
  src = srcTrim($replace.text())
  $div = $("""
  <div class="book-editor" data-bind="editorShader: {src: src, multiline: false, annotations: annotations, errors: errors}"></div>
  """)
  
  model = {
    src: ko.observable(src)
    annotations: ko.observable([])
    errors: ko.observable([])
  }
  
  ko.computed () ->
    src = model.src()
    try
      ast = require("parse-glsl").parse(src, "assignment_expression")
      # console.log ast
      require("interpret")({}, ast)
      
      result = vecToString(ast.evaluated, 3)
      # console.log result
      model.annotations([{line: 0, message: result}])
      model.errors([])
    catch e
      model.annotations([])
      model.errors([{line: 0, message: ""}])
  
  $replace.replaceWith($div)
  
  ko.applyBindings(model, $div[0])




build = ($selection, buildFunction) ->
  $selection.each () ->
    buildFunction($(this))


#
do ->
  build($(".shader-example"), buildShaderExample)
  build($(".evaluator"), buildEvaluator)










