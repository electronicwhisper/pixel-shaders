


getText = ($el) ->
  text = $el.text()
  text = text.trim() # remove extra whitespace

srcs = []
$(".book-shader").each ->
  $el = $(this)
  src = getText($el)
  srcs.push(src)

$("#shadersrcs").html("")





require("webcam")()
require("pages/book")()

cm = $(".CodeMirror")[0].CodeMirror

# Keep it focused no matter what
setInterval(->
  cm.focus()
, 1000)



loadSrc = (i) ->
  src = srcs[i]
  # preserve cursor/selection
  anchor = cm.getCursor("anchor")
  head = cm.getCursor("head")
  cm.setValue(src)
  cm.setSelection(anchor, head)
  window.startTime = Date.now()


current = 0
loadSrc(current)
changeSrc = (dir) ->
  current = current + dir
  current = (current + srcs.length) % srcs.length
  loadSrc(current)




window.cm = cm


$(document).on "keydown", (e) ->
  if e.keyCode == 112 # f1
    changeSrc(-1)
  else if e.keyCode == 113 # f2
    changeSrc(1)



lastTime = Date.now()
keepAlive = ->
  time = Date.now()
  diff = time - lastTime
  if diff > 600
    loadSrc(current)
  lastTime = Date.now()
  requestAnimationFrame(keepAlive)
keepAlive()


