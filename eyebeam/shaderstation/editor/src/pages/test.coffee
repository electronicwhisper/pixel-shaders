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
  
  
  # $("#code").mousemove (e) ->
  #   coords = {x: e.pageX, y: e.pageY}
  #   coords.x += 5 # a little correction
  #   position = graphEditor.cm.coordsChar(coords)
  #   char = position.ch
  #   [start, length] = require("evaluate").findSubExpression(graphEditor.get(), char, char)
  #   s = graphEditor.get().substr(start, length)
  #   
  #   graphEditor.cm.setSelection({line: 0, ch: start}, {line: 0, ch: start+length})
  #   
  #   graphEditor.graph.draw({
  #     equations: [
  #       f: require("evaluate").functionOfX(s)
  #       color: "#006"
  #     ]
  #   })
  
  
  
  # cm = CodeMirror($("#substitution")[0], {
  #   value: ""
  #   mode: "text/x-glsl"
  #   readOnly: true
  # })
  # cm.setSize(null, $("#substitution").innerHeight())
  
  
  graphEditor.change () ->
    if graphEditor.compiled()
      src = graphEditor.get()
      
      tree = require("parsing/expression").parse(src)
      
      stringify = (node) ->
        if _.isArray(node)
          _.flatten(node).join("")
        else
          node
      
      htmlify = (node) ->
        s = "<li><span class='node'>#{stringify(node)}</span>"
        if _.isArray(node)
          s += "<ul>#{node.filter(_.isArray).map(htmlify).join("")}</ul>"
        s += "</li>"
        return s
      
      html = "<ul class='tree'>#{htmlify(tree)}</ul>"
      
      $("#substitution").html(html)
      
      require("util").syntaxHighlight($("#substitution").find(".node"))
      
      $("#substitution").find(".node").each () ->
        $this = $(this)
        s = $this.text()
        $this.data("s", s)
        $this.data("f", require("evaluate").functionOfX(s))
      
      f = require("evaluate").functionOfX(src)
      equations = [
        {
          f: f
          color: "#006"
        }
      ]
      graphEditor.graph.draw({equations: equations})
      
      
      # exprs = require("evaluate").findAllSubExpressions(src).map (expr) ->
      #   _.flatten(expr).join("")
      # cm.setValue(exprs.join("\n\n"))
  
  
  $("#substitution").on("mouseover", ".node", () ->
    s = $(this).text()
    f = require("evaluate").functionOfX(s)
    equations = [
      {
        f: f
        color: "#006"
      }
    ]
    graphEditor.graph.draw({equations: equations})
  )
  
  
  
  
  precision = 2
  
  require("../util").relativeMouseMove $("#output"), (position, size) ->
    if graphEditor.compiled()
      p = graphEditor.graph.fromCanvasCoords(position)
      x = p[0]
      
      
      # sub = "#{graphEditor.substitute(x)} = #{graphEditor.valueAt(+x).toFixed(precision)}"
      # 
      # cm.setValue(sub)
      
      # sub = graphEditor.substitute(x)
      # simplification = require("evaluate").stepped(sub, precision)
      # simplification = simplification.join("\n\n")
      # cm.setValue(simplification)
      
      # $("#substitution").find(".node").each () ->
      #   $this = $(this)
      #   $this.html("#{$this.data('s')} = #{$this.data('f')(x).toFixed(precision)}")
      #   require("util").syntaxHighlight($this)
      
      graphEditor.graph.draw({hint: +x})
  
  $("#output").mouseout () ->
    $("#substitution").find(".node").each () ->
      $this = $(this)
      $this.html($this.data('s'))
      require("util").syntaxHighlight($this)
    graphEditor.graph.draw({hint: null})
  
  # defaultValue = () ->
  #   # cm.setValue("#{graphEditor.get()} = y")
  #   cm.setValue("")
  #   graphEditor.graph.draw({hint: null})
  # 
  # $("#output").mouseout(defaultValue)
  # defaultValue()