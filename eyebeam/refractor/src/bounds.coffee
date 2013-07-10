module.exports = ->
  $el = $("#c")
  width = $el.width()
  height = $el.height()

  if width < height
    {
      boundsMin: [-1, -1 * height / width]
      boundsMax: [ 1,  1 * height / width]
    }
  else
    {
      boundsMin: [-1 * width / height, -1]
      boundsMax: [ 1 * width / height,  1]
    }