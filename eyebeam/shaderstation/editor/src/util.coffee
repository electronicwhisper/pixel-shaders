module.exports = {
  expandCanvas: (canvas) ->
    $canvas = $(canvas)
    $canvas.attr({width: $canvas.innerWidth(), height: $canvas.innerHeight()})
  relativeMouseMove: (div, callback) ->
    $div = $(div)
    $div.mousemove (e) ->
      offset = $div.offset()
      position = [e.clientX - offset.left, e.clientY - offset.top]
      size = [$div.width(), $div.height()]
      callback(position, size)
  syntaxHighlight: (div) ->
    $div = $(div)
    $div.each () ->
      CodeMirror.runMode($(this).text(), "text/x-glsl", this)
      $(this).addClass("cm-s-default")
  

}