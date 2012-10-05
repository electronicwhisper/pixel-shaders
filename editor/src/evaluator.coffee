evaluate = require("evaluate")

module.exports = (opts) ->
  src = opts.src
  $output = $(opts.output)
  $code = $(opts.code)
  
  refreshCode = () ->
    src = cm.getValue()
    worked = true
    try
      outputValue = evaluate.direct(src)
      outputValue = parseFloat(outputValue).toFixed(4)
      if !isFinite(outputValue)
        worked = false
    catch e
      worked = false
    if worked
      outcm.setValue(" = #{outputValue}")
    else
      outcm.setValue("")
  
  
  cm = CodeMirror($code[0], {
    value: src
    mode: "text/x-glsl"
    onChange: refreshCode
  })
  cm.setSize("100%", $code.innerHeight())
  
  outcm = CodeMirror($output[0], {
    mode: "text/x-glsl"
    readOnly: true
  })
  outcm.setSize(null, $output.innerHeight())
  
  refreshCode()