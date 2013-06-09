shaderTemplate = """
<div style="overflow: hidden" class="workspace env">
  <div class="output canvas" style="width: 300px; height: 300px; float: left;"></div>
  <div class="code" style="margin-left: 324px; border: 1px solid #ccc"></div>
</div>
"""

getText = ($el) ->
  text = $el.text()
  text = text.trim() # remove extra whitespace


module.exports = () ->
  $("code").each () ->
    CodeMirror.runMode($(this).text(), "text/x-glsl", this)
    $(this).addClass("cm-s-default")

  $(".book-shader").each () ->
    $div = $(this)
    src = getText($div)

    $shaderDiv = $(shaderTemplate)
    $div.replaceWith($shaderDiv)

    require("../editor")({
      src: src
      output: $shaderDiv.find(".output")
      code: $shaderDiv.find(".code")
    })

  $(".book-exercise").each () ->
    $div = $(this)

    exercises = []
    $div.find(".book-solution").each (i) ->
      exercise = {}
      if i == 0
        exercise.workspace = getText($div.find(".book-workspace"))
      exercise.solution = getText($(this))
      exercises.push(exercise)

    require("../exercise")({
      div: $div
      exercises: exercises
    })