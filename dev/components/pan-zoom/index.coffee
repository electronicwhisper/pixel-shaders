###
Options:
  element
  minX
  maxX
  minY
  maxY
  flipY
  flipX
###

$ = require("jquery")
Emitter = require('emitter')




mouseWheelEvent = (orgEvent) ->
  delta = 0
  deltaX = 0
  deltaY = 0
  
  # Old school scrollwheel delta
  delta = orgEvent.wheelDelta/120 if (orgEvent.wheelDelta)
  delta = -orgEvent.detail/3 if (orgEvent.detail)
  
  # New school multidimensional scroll (touchpads) deltas
  deltaY = delta
  
  # Gecko
  if (orgEvent.axis != undefined && orgEvent.axis == orgEvent.HORIZONTAL_AXIS)
    deltaY = 0
    deltaX = -1*delta
  
  # Webkit
  deltaY = orgEvent.wheelDeltaY/120 if (orgEvent.wheelDeltaY != undefined)
  deltaX = -1*orgEvent.wheelDeltaX/120 if (orgEvent.wheelDeltaX != undefined)
  
  return [delta, deltaX, deltaY]



lerp = (x, min, max) ->
  min + x * (max - min)

module.exports = (opts) ->
  $element = $(opts.element)
  
  pz = {}
  
  pz.minX = opts.minX
  pz.maxX = opts.maxX
  pz.minY = opts.minY
  pz.maxY = opts.maxY
  
  Emitter(pz)
  
  toLocal = (pageX, pageY) ->
    width = $element.width()
    height = $element.height()
    offset = $element.offset()
    
    x = (pageX - offset.left) / width
    y = (pageY - offset.top) / height
    
    x = 1 - x if opts.flipX
    y = 1 - y if opts.flipY
    
    [lerp(x, pz.minX, pz.maxX), lerp(y, pz.minY, pz.maxY)]
  
  down = (e) ->
    [downX, downY] = toLocal(e.pageX, e.pageY)
    
    move = (e) ->
      [x, y] = toLocal(e.clientX, e.clientY)
      pz.minX += downX - x
      pz.maxX += downX - x
      pz.minY += downY - y
      pz.maxY += downY - y
      pz.emit("update")
    
    up = (e) ->
      $(document).off("mousemove", move)
      $(document).off("mouseup", up)
    
    $(document).on("mousemove", move)
    $(document).on("mouseup", up)
    
    e.preventDefault() # stop text selection
  
  $element.on("mousedown", down)
  
  
  wheel = (e) ->
    [delta, deltaX, deltaY] = mouseWheelEvent(e.originalEvent)
    [x, y] = toLocal(e.originalEvent.pageX, e.originalEvent.pageY)
    
    deltaLimit = 2.8
    delta = Math.min(Math.max(delta, -deltaLimit), deltaLimit)
    scaleFactor = 1.1
    scale = Math.pow(scaleFactor, -delta)
    
    pz.minX = (pz.minX - x) * scale + x
    pz.maxX = (pz.maxX - x) * scale + x
    pz.minY = (pz.minY - y) * scale + y
    pz.maxY = (pz.maxY - y) * scale + y
    
    e.preventDefault() # stop scrolling
    
    pz.emit("update")
    
  $element.on("mousewheel", wheel)
  $element.on("DOMMouseScroll", wheel) # gecko
  
  return pz
