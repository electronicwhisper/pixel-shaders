module.exports = {
  expandCanvas: (canvas) ->
    $canvas = $(canvas)
    $canvas.attr({width: $canvas.innerWidth(), height: $canvas.innerHeight()})
}