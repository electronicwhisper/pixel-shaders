map = (x, dMin, dMax, rMin, rMax) ->
  ratio = (x - dMin) / (dMax - dMin)
  ratio * (rMax - rMin) + rMin


findSpacing = (minSpacing) ->
  ###
  need to determine:
    largeSpacing = {1, 2, or 5} * 10^n
    smallSpacing = divide largeSpacing by 4 (if 1 or 2) or 5 (if 5)
  largeSpacing must be greater than minSpacing
  ###
  div = 4
  largeSpacing = z = Math.pow(10, Math.ceil(Math.log(minSpacing) / Math.log(10)))
  if z / 5 > minSpacing
    largeSpacing = z / 5
  else if z / 2 > minSpacing
    largeSpacing = z / 2
    div = 5
  smallSpacing = largeSpacing / div
  return [largeSpacing, smallSpacing]


ticks = (spacing, min, max) ->
  first = Math.ceil(min / spacing)
  last = Math.floor(max / spacing)
  (x * spacing for x in [first..last])


drawLine = (ctx, [x1, y1], [x2, y2]) ->
  ctx.beginPath()
  ctx.moveTo(x1, y1)
  ctx.lineTo(x2, y2)
  ctx.stroke()


module.exports = (opts) ->
  ctx = opts.ctx
  
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
  
  toLocal = ([cx, cy]) ->
    [map(cx, cMinX, cMaxX, minX, maxX), map(cy, cMinY, cMaxY, minY, maxY)]
  fromLocal = ([x, y]) ->
    [map(x, minX, maxX, cMinX, cMaxX), map(y, minY, maxY, cMinY, cMaxY)]
  
  minPixels = 70
  labelDistance = 5
  color = "255,255,255"
  minorOpacity = 0.2
  majorOpacity = 0.4
  axesOpacity = 1.0
  labelOpacity = 1.0
  minorColor = "rgba(#{color}, #{minorOpacity})"
  majorColor = "rgba(#{color}, #{majorOpacity})"
  axesColor = "rgba(#{color}, #{axesOpacity})"
  labelColor = "rgba(#{color}, #{labelOpacity})"
  textHeight = 12
  
  
  minSpacing = (sizeX / width) * minPixels # TODO: also check in y direction
  [largeSpacing, smallSpacing] = findSpacing(minSpacing)
  
  ctx.save()
  
  ctx.setTransform(1,0,0,1,0,0)
  ctx.lineWidth = 0.5
  
  ctx.shadowColor = "rgba(0,0,0,0.8)"
  ctx.shadowBlur = 3
  
  # draw minor grid lines
  ctx.strokeStyle = minorColor
  for x in ticks(smallSpacing, minX, maxX)
    drawLine(ctx, fromLocal([x, minY]), fromLocal([x, maxY]))
  for y in ticks(smallSpacing, minY, maxY)
    drawLine(ctx, fromLocal([minX, y]), fromLocal([maxX, y]))
  
  # draw major grid lines
  ctx.strokeStyle = majorColor
  for x in ticks(largeSpacing, minX, maxX)
    drawLine(ctx, fromLocal([x, minY]), fromLocal([x, maxY]))
  for y in ticks(largeSpacing, minY, maxY)
    drawLine(ctx, fromLocal([minX, y]), fromLocal([maxX, y]))
  
  # draw axes
  ctx.strokeStyle = axesColor
  drawLine(ctx, fromLocal([0, minY]), fromLocal([0, maxY]))
  drawLine(ctx, fromLocal([minX, 0]), fromLocal([maxX, 0]))
  
  # draw labels
  ctx.font = "#{textHeight}px verdana"
  ctx.fillStyle = labelColor
  ctx.textAlign = "center"
  ctx.textBaseline = "top"
  for x in ticks(largeSpacing, minX, maxX)
    if x != 0
      text = parseFloat(x.toPrecision(12)).toString()
      [cx, cy] = fromLocal([x, 0])
      cy += labelDistance
      if cy < labelDistance
        cy = labelDistance
      if cy + textHeight + labelDistance > height
        cy = height - labelDistance - textHeight
      ctx.fillText(text, cx, cy)
  ctx.textAlign = "left"
  ctx.textBaseline = "middle"
  for y in ticks(largeSpacing, minY, maxY)
    if y != 0
      text = parseFloat(y.toPrecision(12)).toString()
      [cx, cy] = fromLocal([0, y])
      cx += labelDistance
      if cx < labelDistance
        cx = labelDistance
      if cx + ctx.measureText(text).width + labelDistance > width
        cx = width - labelDistance - ctx.measureText(text).width
      ctx.fillText(text, cx, cy)
  
  ctx.restore()
  
  return {
    
  }