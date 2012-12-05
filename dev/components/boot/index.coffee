$ = require('jquery')
_ = require('underscore')
XRegExp = require('xregexp').XRegExp


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


fragmentShaderSource = """
precision mediump float;

varying vec2 position;

void main() {
  gl_FragColor = vec4(position.x, position.y, 0., 1.);
}
"""


parseUniforms = (src) ->
  regex = XRegExp('uniform +(?<type>[^ ]+) +(?<name>[^ ;]+) *;', 'g')
  
  uniforms = []
  XRegExp.forEach(src, regex, (match) ->
    uniforms.push({
      type: match.type
      name: match.name
    })
  )
  return uniforms






do ->
  
  shader = require("shader")({
    canvas: $("#c1")[0]
    vertex: vertexShaderSource
    fragment: fragmentShaderSource
    uniforms: {
      boundsMin: [0, 0]
      boundsMax: [1, 1]
    }
  })
  
  
  pz = require("pan-zoom")({
    element: $("#main")[0]
    minX: 0
    maxX: 1
    minY: 0
    maxY: 1
    flipY: true
  })
  
  
  ctx = $("#c2")[0].getContext("2d")
  
  update = () ->
    shader.draw({
      uniforms: {
        boundsMin: [pz.minX, pz.minY]
        boundsMax: [pz.maxX, pz.maxY]
      }
    })
    
    ctx.clearRect(0, 0, 1000, 1000)
    require("graph-grid")({
      ctx: ctx
      minX: pz.minX
      maxX: pz.maxX
      minY: pz.minY
      maxY: pz.maxY
      flipY: true
      color: "255,255,255"
      shadow: true
    })
  
  pz.on("update", update)
  update()
  
  
  startTime = Date.now()
  animated = false
  uniforms = []
  
  shouldAnimate = () ->
    for uniform in uniforms
      if uniform.name == "time" || uniform.name == "webcam"
        return true
    return false
  
  
  editor = require("editor")({
    div: $("#cm")[0]
    multiline: true
    src: fragmentShaderSource
    errorCheck: require("glsl-error")
  })
  
  editor.on("change", (src) ->
    uniforms = parseUniforms(src)
    animated = shouldAnimate()
    
    shader.draw({
      fragment: src
    })
  )
  
  animate = () ->
    require("raf")(animate)
    if animated
      sendUniforms = {}
      for uniform in uniforms
        if uniform.name == "time"
          sendUniforms.time = (Date.now() - startTime) / 1000
        if uniform.name == "webcam"
          sendUniforms.webcam = require("webcam")()
      shader.draw({
        uniforms: sendUniforms
      })
  animate()

















do ->
  src = "x"
  f = require("evaluate").functionOfX(src)
  
  ctx = $("#c3")[0].getContext("2d")
  
  pz = require("pan-zoom")({
    element: $("#linegraph")[0]
    minX: -2
    maxX: 2
    minY: -2
    maxY: 2
    flipY: true
  })
  
  graphEditor = require("editor")({
    div: $("#graph-cm")
    multiline: false
    src: "x"
    errorCheck: (src) ->
      f = require("evaluate").functionOfX(src)
      if f.err || src == ""
        return [{lineNum: 0, error: ""}]
      else
        return false
  })
  
  draw = () ->
    ctx.clearRect(0, 0, 1000, 1000)
    
    require("graph-grid")({
      ctx: ctx
      minX: pz.minX
      maxX: pz.maxX
      minY: pz.minY
      maxY: pz.maxY
      flipY: true
      color: "0,0,0"
      shadow: false
    })
    
    require("graph-line")({
      ctx: ctx
      f: f
      minX: pz.minX
      maxX: pz.maxX
      minY: pz.minY
      maxY: pz.maxY
      flipY: true
    })
  
  pz.on("update", draw)
  graphEditor.on("change", (src) ->
    require("deconstruct")({
      div: $("#substitution")
      src: src
    })
    
    f = require("evaluate").functionOfX(src)
    draw()
  )
  graphEditor.emit("change", graphEditor.src())
  
  
  $("#substitution").on("mouseenter", ".deconstruct-node", () ->
    s = $(this).text()
    f = require("evaluate").functionOfX(s)
    draw()
  )