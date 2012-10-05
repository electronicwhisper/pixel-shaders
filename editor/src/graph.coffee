util = require("util")
evaluate = require("evaluate")

module.exports = (opts) ->
  src = opts.src
  $output = $(opts.output)
  $code = $(opts.code)
  domain = opts.domain || [-1.6, 1.6]
  range = opts.range || [-1.6, 1.6]
  label = opts.label || 0.5
  
  labelSize = 5
  
  $canvas = $("<canvas />")
  $output.append($canvas)
  util.expandCanvas($canvas)
  ctx = $canvas[0].getContext("2d")
  
  width = $canvas[0].width
  height = $canvas[0].height
  
  toCanvasCoords = ([x, y]) ->
    cx = (x - domain[0]) / (domain[1] - domain[0]) * width
    cy = (y - range[0]) / (range[1] - range[0]) * height
    [cx, height - cy]
  
  fromCanvasCoords = ([cx, cy]) ->
    x = (cx / width) * (domain[1] - domain[0]) + domain[0]
    y = ((height-cy) / height) * (range[1] - range[0]) + range[0]
    [x, y]
  
  srcFun = evaluate.functionOfX(src)
  
  draw = () ->
    # reset
    ctx.setTransform(1, 0, 0, 1, 0, 0)
    ctx.clearRect(0, 0, width, height)
    
    # draw axes
    origin = toCanvasCoords([0, 0])
    ctx.strokeStyle = "#999"
    ctx.lineWidth = 0.5
    ctx.beginPath()
    ctx.moveTo(origin[0], 0)
    ctx.lineTo(origin[0], height)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(0, origin[1])
    ctx.lineTo(height, origin[1])
    ctx.stroke()
    
    # draw labels
    ctx.font = "12px verdana"
    ctx.fillStyle = "#666"
    [xmin, ymin] = fromCanvasCoords([0, height])
    [xmax, ymax] = fromCanvasCoords([width, 0])
    
    ctx.textAlign = "center"
    ctx.textBaseline = "top"
    for xi in [Math.ceil(xmin/label) .. Math.floor(xmax/label)]
      if xi != 0
        x = xi * label
        [cx, cy] = toCanvasCoords([x, 0])
        ctx.beginPath()
        ctx.moveTo(cx, cy-labelSize)
        ctx.lineTo(cx, cy+labelSize)
        ctx.stroke()
        ctx.fillText(""+x, cx, cy+labelSize*1.5)
    
    ctx.textAlign = "left"
    ctx.textBaseline = "middle"
    for yi in [Math.ceil(ymin/label) .. Math.floor(ymax/label)]
      if yi != 0
        y = yi * label
        [cx, cy] = toCanvasCoords([0, y])
        ctx.beginPath()
        ctx.moveTo(cx-labelSize, cy)
        ctx.lineTo(cx+labelSize, cy)
        ctx.stroke()
        ctx.fillText(""+y, cx+labelSize*1.5, cy)
    
    
    # console.log xmin, ymin, xmax, ymax
    
    # draw graph
    ctx.strokeStyle = "#006"
    ctx.lineWidth = 2
    ctx.beginPath()
    # ctx.moveTo(-100, 0)
    
    resolution = 0.25
    for i in [0..(width/resolution)]
      cx = i * resolution
      x = fromCanvasCoords([cx, 0])[0]
      # x = (cx / width) * (domain[1] - domain[0]) + domain[0]
      y = srcFun(x)
      cy = toCanvasCoords([x, y])[1]
      ctx.lineTo(cx, cy)
    
    ctx.stroke()
  
  refreshCode = () ->
    src = cm.getValue()
    worked = true
    try
      srcFun = evaluate.functionOfX(src)
    catch e
      worked = false
    if worked
      draw()
  
  
  cm = CodeMirror($code[0], {
    value: src
    mode: "text/x-glsl"
    # lineNumbers: true
    onChange: refreshCode
  })
  cm.setSize("100%", $code.innerHeight())
  
  refreshCode()























