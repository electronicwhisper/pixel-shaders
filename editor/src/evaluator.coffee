evaluate = require("evaluate")



module.exports = (opts) ->
  src = opts.src
  $output = $(opts.output)
  $code = $(opts.code)
  
  refreshCode = () ->
    src = cm.getValue()
    
    outputValue = evaluate.direct(src)
    
    if !outputValue.err && isFinite(outputValue)
      outputValue = parseFloat(outputValue).toFixed(4)
      outcm.setValue(" = #{outputValue}")
    else
      outcm.setValue("")
    
    # worked = true
    # if evaluate.hasIntegers(src)
    #   worked = false
    # else
    #   try
    #     outputValue = evaluate.direct(src)
    #     outputValue = parseFloat(outputValue).toFixed(4)
    #     if !isFinite(outputValue)
    #       worked = false
    #   catch e
    #     console.log "caught"
    #     worked = false
    # if worked
    #   outcm.setValue(" = #{outputValue}")
    # else
    #   outcm.setValue("")
  
  
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