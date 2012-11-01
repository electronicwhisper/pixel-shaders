shaderTemplate = """
<div style="overflow: hidden" class="workspace env">
  <div class="output canvas" style="width: 300px; height: 300px; float: left;"></div>
  <div class="code" style="margin-left: 324px; border: 1px solid #ccc"></div>
</div>
"""

module.exports = () ->
  $("code").each () ->
    CodeMirror.runMode($(this).text(), "text/x-glsl", this)
    $(this).addClass("cm-s-default")
  
  $(".book-shader").each () ->
    $div = $(this)
    src = $div.text()
    
    # remove extra whitespace
    src = src.trim()
    
    $shaderDiv = $(shaderTemplate)
    $div.replaceWith($shaderDiv)
    
    require("../editor")({
      src: src
      output: $shaderDiv.find(".output")
      code: $shaderDiv.find(".code")
    })