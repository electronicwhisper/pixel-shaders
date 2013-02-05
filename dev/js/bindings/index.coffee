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
    if o.position
      pz.on("position", (x, y) ->
        o.position([x, y])
      )
}


ko.bindingHandlers.relPosition = {
  init: (element, valueAccessor) ->
    o = valueAccessor()
    $element = $(element)
    ko.computed () ->
      bounds = o.bounds()
      position = o.position()
      width = $element.parent().width()
      height = $element.parent().height()
      x = width * (position[0] - bounds.minX) / (bounds.maxX - bounds.minX)
      y = height * (1 - (position[1] - bounds.minY)) / (bounds.maxY - bounds.minY) # flipY
      $element.css("left", x)
      $element.css("top", y)
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
    
    o.src.subscribe (newSrc) ->
      if newSrc != editor.src()
        editor.codemirror.setValue(newSrc)
    
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


# ======================================================= drawGraph

ko.bindingHandlers.drawGraph = {
  init: (element, valueAccessor) ->
    o = valueAccessor()
    
    sizeCanvas(element)
    ctx = element.getContext("2d")
    
    ko.computed () ->
      f = o.f()
      bounds = o.bounds()
      
      if f
        clear(ctx)
        require("graph-line")({
          ctx: ctx
          flipY: true
          minX: bounds.minX
          maxX: bounds.maxX
          minY: bounds.minY
          maxY: bounds.maxY
          f: f
        })
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
    element.shader = shader
    
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


