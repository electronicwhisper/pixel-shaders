$ = require("jquery")
_ = require("underscore")

module.exports = (opts) ->
  $div = $(opts.div)
  src = opts.src
  
  tree = require("parse").parse(src)
  
  stringify = (node) ->
    if _.isArray(node)
      _.flatten(node).join("")
    else
      node
  
  htmlify = (node) ->
    s = "<li><span class='deconstruct-node'>#{stringify(node)}</span>"
    if _.isArray(node)
      s += "<ul>#{node.filter(_.isArray).map(htmlify).join("")}</ul>"
    s += "</li>"
    return s
  
  html = "<ul class='deconstruct-tree'>#{htmlify(tree)}</ul>"
  
  $div.html(html)
  
  $div.find(".deconstruct-node").each () ->
    $this = $(this)
    # console.log("highlighting", $this)
    require("codemirror").runMode($this.text(), "text/x-glsl", this)
    
    $this.addClass("cm-s-default")
    $this.css("font-family", "monospace")
    
    # console.log("highlighting", $this.text())