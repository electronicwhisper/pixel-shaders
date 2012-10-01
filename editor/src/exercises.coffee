flatRenderer = require("flatRenderer")

simpleSrc = """
precision mediump float;

varying vec2 position;

void main() {
  gl_FragColor.r = position.x;
  gl_FragColor.g = position.y;
  gl_FragColor.b = 1.0;
  gl_FragColor.a = 1.0;
}
"""


exercises = [{
workspace: """
precision mediump float;

varying vec2 position;

void main() {
  gl_FragColor.r = 1.0;
  gl_FragColor.g = 0.0;
  gl_FragColor.b = 0.0;
  gl_FragColor.a = 1.0;
}
"""
solution: """
precision mediump float;

varying vec2 position;

void main() {
  gl_FragColor.r = 0.0;
  gl_FragColor.g = 0.0;
  gl_FragColor.b = 1.0;
  gl_FragColor.a = 1.0;
}
"""
},{
solution: """
precision mediump float;

varying vec2 position;

void main() {
  gl_FragColor.r = 1.0;
  gl_FragColor.g = 1.0;
  gl_FragColor.b = 0.0;
  gl_FragColor.a = 1.0;
}
"""
},{
solution: """
precision mediump float;

varying vec2 position;

void main() {
  gl_FragColor.r = 1.0;
  gl_FragColor.g = 0.5;
  gl_FragColor.b = 0.0;
  gl_FragColor.a = 1.0;
}
"""
}]




testEqualEditors = (e1, e2) ->
  e1.snapshot() == e2.snapshot()





module.exports = () ->
  
  editor = require("editor")({
    src: exercises[0].workspace
    code: $("#code")
    output: $("#output")
  })
  window.e = editor
  
  makeEditor = require("editor")({
    src: exercises[0].solution
    code: $("#makeCode")
    output: $("#makeOutput")
  })
  
  # window.loadExercise = loadExercise = (i) ->
  #   exercise = exercises[i]
  #   if exercise.start
  #     editor.set(exercise.start)
  #   makeEditor.set(exercise.solution)
  
  exercise = {
    workspace: ko.observable("")
    solution: ko.observable("")
    currentExercise: ko.observable(0)
    exercises: exercises
    solved: ko.observable(false)
    previous: () ->
      exercise.currentExercise(exercise.currentExercise() - 1)
    next: () ->
      exercise.currentExercise(exercise.currentExercise() + 1)
  }
  
  editor.onchange (src) ->
    exercise.workspace(src)
  makeEditor.onchange (src) ->
    exercise.solution(src)
  
  ko.computed () ->
    e = exercises[exercise.currentExercise()]
    if e.workspace
      editor.set(e.workspace)
    makeEditor.set(e.solution)
  
  ko.computed () ->
    exercise.workspace()
    exercise.solution()
    exercise.solved(testEqualEditors(editor, makeEditor))
  
  ko.computed () ->
    exercises[exercise.currentExercise()].workspace = exercise.workspace()
  
  ko.applyBindings(exercise)
  
  
