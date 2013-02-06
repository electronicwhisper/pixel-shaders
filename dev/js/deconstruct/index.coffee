$ = require("jquery")
_ = require("underscore")

ast = require("ast")

module.exports = (opts) ->
  $div = $(opts.div)
  src = opts.src
  
  node = require("parse-glsl").parse(src, "assignment_expression")
  
  ast.markEnds(node, src.length)
  breakdown = ast.breakdown(node)
  
  htmlify = (children) ->
    s = "<ul class='deconstruct-tree'>"
    for child in children
      s += "<li><span class='deconstruct-node'>#{ast.stringify(child.node, src)}</span>"
      if child.children.length > 0
        s += htmlify(child.children)
      s += "</li>"
    s += "</ul>"
    return s
  
  html = htmlify(breakdown)
  
  $div.html(html)
  
  $div.find(".deconstruct-node").each () ->
    $this = $(this)
    # console.log("highlighting", $this)
    require("codemirror").runMode($this.text(), "text/x-glsl", this)
    
    $this.addClass("cm-s-default")
    $this.css("font-family", "monospace")
    
    # console.log("highlighting", $this.text())