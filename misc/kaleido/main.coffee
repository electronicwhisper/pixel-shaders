n = numeric


unitVector = (angle) ->
  [Math.cos(angle), Math.sin(angle)]

normalize = (v) ->
  n.div(v, n.norm2(v))

facingIntoNormal = (incident, normal) ->
  n.dot(incident, normal) < 0

reflect = (incident, normal) ->
  # via http://www.khronos.org/opengles/sdk/docs/manglsl/xhtml/reflect.xml
  # I - 2.0 * dot(N, I) * N
  n.sub(incident, n.mul(2, n.mul(n.dot(normal, incident), normal)))











makeKaleido = (div, mirrors, renderedImg) ->
  # returns a new [source, incident] after reflecting off the first mirror that the ray hits
  intersectMirrors = (source, incident) ->
    newSource = false
    newIncident = false
    minRatio = Infinity
    
    for mirror in mirrors
      # is the ray facing the normal?
      if facingIntoNormal(incident, mirror.normal)
        # find how far along source->target it intersects
        ratio = n.dot(n.sub(mirror.position, source), mirror.normal) / n.dot(incident, mirror.normal)
        if ratio >= 0 && ratio < 1 # it intersects
          if ratio < minRatio # it's the closest intersection
            minRatio = ratio
          
            newSource = n.add(source, n.mul(incident, ratio))
          
            reflectedRay = reflect(incident, mirror.normal)
            newIncident = n.mul(reflectedRay, 1 - ratio)
    
    if newSource == false
      target = n.add(source, incident)
      return [target, [0,0]]
    else
      return [newSource, newIncident]
  
  
  reflectImage = (ctx) ->
    ctx.drawImage(img, 0, 0)
    
    imageData = ctx.getImageData(0, 0, 600, 600)
    pixels = imageData.data
    
    for x in [0...600]
      for y in [0...600]
        source = [300, 300]
        incident = n.sub([x, y], source)
        # # raytrace
        until incident[0] == 0 && incident[1] == 0
          [source, incident] = intersectMirrors(source, incident)
        
        newX = Math.round(source[0])
        newY = Math.round(source[1])
        
        unless x == newX && y == newY
          for i in [0...3]
            pixels[(y*600 + x)*4 + i] = pixels[(newY*600 + newX)*4 + i]
          pixels[(y*600 + x)*4 + 3] = 180
    
    ctx.putImageData(imageData, 0, 0)
  
  
  drawLines = (ctx, e) ->
    offset = $(e.target).offset()
    p = n.sub([e.pageX, e.pageY], [offset.left, offset.top])
    center = [300, 300]
    
    ctx.clearRect(0, 0, 600, 600)
    
    source = center
    incident = n.sub(p, center)
    
    ctx.strokeStyle = "#0f0"
    ctx.lineWidth = 2
    
    ctx.beginPath()
    ctx.moveTo(source...)
    
    until incident[0] == 0 && incident[1] == 0
      [source, incident] = intersectMirrors(source, incident)
      ctx.lineTo(source...)
    
    ctx.stroke()
    
    ctx.strokeStyle = "#f00"
    ctx.lineWidth = 2
    
    ctx.beginPath()
    ctx.moveTo(center...)
    ctx.lineTo(p...)
    ctx.stroke()
  
  
  
  $div = $(div)
  
  
  if renderedImg
    $div.append("<img src='#{renderedImg}' width='600' height='600' />")
  else
    picCanvas = $("<canvas width='600' height='600'></canvas>")
    $div.append(picCanvas)
    
    picCtx = picCanvas[0].getContext("2d")
    reflectImage(picCtx)
  
  lineCanvas = $("<canvas width='600' height='600'></canvas>")
  $div.append(lineCanvas)
  
  lineCtx = lineCanvas[0].getContext("2d")
  
  lineCanvas.mousemove (e) ->
    drawLines(lineCtx, e)
  
  lineCanvas.mouseout (e) ->
    lineCtx.clearRect(0, 0, 600, 600)








# a mirror is defined by a position and a normal vector
mirror1 = {position: [250, 250], normal: [1, 0]}
mirror2 = {position: [250, 250], normal: [0, 1]}
mirror3 = {position: [350, 350], normal: normalize([-1, -1.5])}
mirror4 = {position: [350, 300], normal: normalize([-1, 0.2])}

makeKaleidos = () ->
  makeKaleido("#k1", [mirror1], "k1.jpg")
  makeKaleido("#k2", [mirror1, mirror2], "k2.jpg")
  makeKaleido("#k3", [mirror1, mirror2, mirror3], "k3.jpg")
  makeKaleido("#k4", [mirror1, mirror2, mirror3, mirror4], "k4.jpg")


# img = new Image()
# img.onload = () ->
#   makeKaleidos()
# img.src = 'pic.jpg';

makeKaleidos()

