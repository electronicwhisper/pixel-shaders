map = (x, dMin, dMax, rMin, rMax) ->
  ratio = (x - dMin) / (dMax - dMin)
  ratio * (rMax - rMin) + rMin

module.exports = (opts) ->
  ctx = opts.ctx
  f = opts.f
  
  # bounds
  minX = opts.minX
  maxX = opts.maxX
  minY = opts.minY
  maxY = opts.maxY
  sizeX = maxX - minX
  sizeY = maxY - minY
  
  canvas = ctx.canvas
  width = canvas.width
  height = canvas.height
  
  cMinX = 0
  cMaxX = width
  cMinY = 0
  cMaxY = height
  
  if opts.flipX
    [cMinX, cMaxX] = [cMaxX, cMinX]
  if opts.flipY
    [cMinY, cMaxY] = [cMaxY, cMinY]
  
  ctx.lineWidth = 2
  ctx.strokeStyle = "#006"
  
  ctx.beginPath()
  
  resolution = 0.25
  for i in [0..(width/resolution)]
    cx = i * resolution
    x = map(cx, cMinX, cMaxX, minX, maxX)
    y = f(x)
    cy = map(y, minY, maxY, cMinY, cMaxY)
    ctx.lineTo(cx, cy)
  
  ctx.stroke()