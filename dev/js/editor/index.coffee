$ = require("jquery")
codemirror = require("codemirror")
Emitter = require('emitter')

module.exports = (opts) ->
  
  $div = $(opts.div)
  multiline = opts.multiline || false
  src = opts.src || ""
  errors = opts.errors || {}
  annotations = opts.annotations || {}
  widgets = opts.widgets || {}
  
  cmOpts = {
    mode: "text/x-glsl"
    value: src
    lineNumbers: true
    matchBrackets: true
  }
  if !multiline
    cmOpts.lineNumberFormatter = (n) -> ""
  
  cm = codemirror($div[0], cmOpts)
  
  # set height
  if multiline
    cm.setSize("100%", $div.innerHeight())
  else
    cm.setSize("100%", cm.defaultTextHeight() + 8)
  
  # make $annotations, container for annotations
  $annotations = $("<div class='editor-annotations'></div>")
  $(cm.getScrollerElement()).find(".CodeMirror-lines").append($annotations)
  
  editor = {
    codemirror: cm
    src: () -> src
  }
  
  Emitter(editor)
  
  
  update = () ->
    # =================================== errors
    # first remove all error classes
    for line in [0...cm.lineCount()]
      cm.removeLineClass(line, "wrap", "editor-error")
    for error in errors
      cm.addLineClass(error.line, "wrap", "editor-error")
    
    # =================================== annotations
    $annotations.html("") # remove old annotations
    for annotation in annotations
      if cm.getLine(annotation.line) != undefined
        charPos = {line: annotation.line, ch: cm.getLine(annotation.line).length}
        xyPos = cm.cursorCoords(charPos, "local")
        $annotation = $("<div class='editor-annotation'></div>")
        codemirror.runMode(annotation.message, "text/x-glsl", $annotation[0])
        $annotation.css({left: xyPos.left, top: xyPos.top})
        $annotations.append($annotation)
    
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