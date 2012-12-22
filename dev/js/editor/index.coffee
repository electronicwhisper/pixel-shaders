$ = require("jquery")
codemirror = require("codemirror")
Emitter = require('emitter')

module.exports = (opts) ->
  
  $div = $(opts.div)
  multiline = opts.multiline || false
  src = opts.src || ""
  # errorCheck = opts.errorCheck || false
  errors = opts.errors || {}
  annotations = opts.annotations || {}
  widgets = opts.widgets || {}
  
  cm = codemirror($div[0], {
    mode: "text/x-glsl"
    value: src
    lineNumbers: multiline
    matchBrackets: true
  })
  
  # set height
  if multiline
    cm.setSize("100%", $div.innerHeight())
  else
    cm.setSize("100%", cm.defaultTextHeight() + 8)
  
  editor = {
    codemirror: cm
    src: () -> src
  }
  
  Emitter(editor)
  
  oldAnnotations = []
  update = () ->
    # =================================== errors
    # first remove all error classes
    for line in [0...cm.lineCount()]
      cm.removeLineClass(line, "wrap", "editor-error")
    for error in errors
      cm.addLineClass(error.line, "wrap", "editor-error")
    
    # =================================== annotations
    # first remove all old annotations
    for oldAnnotation in oldAnnotations
      oldAnnotation.clear()
    # add annotations
    for annotation in annotations
      pos = {line: annotation.line, ch: cm.getLine(annotation.line).length}
      $element = $("<span class='editor-annotation'></span>").text(annotation.message)
      oldAnnotations.push(cm.setBookmark(pos, $element[0]))
    
    # =================================== widgets
  
  
  editor.set = (o) ->
    errors = o.errors || errors
    annotations = o.annotations || annotations
    widgets = o.widgets || widgets
    update()
  
  cm.on("change", () ->
    src = cm.getValue()
    update()
    editor.emit("change", src)
  )
  
  
  
  return editor