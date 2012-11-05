module.exports = () ->
  graphEditor = require("../graphEditor")({
    output: $("#output")
    code: $("#code")
    src: "abs(x)"
  })
  
  # require("../evaluator")({
  #   output: $("#eoutput")
  #   code: $("#ecode")
  #   src: "3. + 5."
  # })
  
  
  cm = CodeMirror($("#substitution")[0], {
    value: ""
    mode: "text/x-glsl"
    readOnly: true
  })
  cm.setSize(null, $("#substitution").innerHeight())
  
  
  precision = 2
  
  require("../util").relativeMouseMove $("#output"), (position, size) ->
    if graphEditor.compiled()
      p = graphEditor.graph.fromCanvasCoords(position)
      x = p[0]
      x = x.toFixed(precision)
      
      # sub = "#{graphEditor.substitute(x)} = #{graphEditor.valueAt(+x).toFixed(precision)}"
      # 
      # cm.setValue(sub)
      
      sub = graphEditor.substitute(x)
      simplification = require("evaluate").stepped(sub, precision)
      simplification = simplification.join("\n\n")
      cm.setValue(simplification)
      
      graphEditor.graph.draw({hint: +x})
  
  defaultValue = () ->
    # cm.setValue("#{graphEditor.get()} = y")
    cm.setValue("")
    graphEditor.graph.draw({hint: null})
  
  $("#output").mouseout(defaultValue)
  # defaultValue()