$ = require("jquery")
codemirror = require("codemirror")
Emitter = require('emitter')

module.exports = (opts) ->
  
  $div = $(opts.div)
  multiline = opts.multiline || false
  src = opts.src || ""
  errorCheck = opts.errorCheck || false
  
  cm = codemirror($div[0], {
    mode: "text/x-glsl"
    value: src
    lineNumbers: multiline
    matchBrackets: true
  })
  
  if multiline
    cm.setSize("100%", $div.innerHeight())
  else
    cm.setSize("100%", cm.defaultTextHeight() + 8)
  
  editor = {
    codemirror: cm
    src: () -> src
  }
  
  Emitter(editor)
  
  cm.on("change", () ->
    src = cm.getValue()
    if errorCheck
      # first remove all error classes
      for line in [0...cm.lineCount()]
        cm.removeLineClass(line, "wrap", "editor-error")
      errors = errorCheck(src)
      if errors
        for error in errors
          cm.addLineClass(error.lineNum, "wrap", "editor-error")
        return
    editor.emit("change", src)
  )
  
  return editor