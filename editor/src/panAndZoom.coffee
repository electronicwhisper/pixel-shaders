###
Takes in:
  div (will register appropriate mousedown, mousemove, mouseup, and mousescroll events)
  xmin, xmax, ymin, ymax - these properties are also exposed
  flipy - makes y go from bottom to top
  listen(callback) - calls callback whenever bounds change due to mouse interaction
###

module.exports = (o) ->
  $div = $(o.div)
  
  o.listen = (callback) ->
    
  
  return o