editor = require("editor")

template = """
<div style="overflow: hidden" class="workspace env">
  <div class="output canvas" style="width: 300px; height: 300px; float: left;"></div>
  <div class="code" style="margin-left: 324px; border: 1px solid #ccc"></div>
</div>

<div style="overflow: hidden; margin-top: 24px" class="solution env">
  <div class="output canvas" style="width: 300px; height: 300px; float: left;"></div>
  <div class="code" style="display: none"></div>
  <div style="margin-left: 324px; font-size: 30px; font-family: helvetica; height: 300px">
    <div style="float: left">
      <i class="icon-arrow-left" style="font-size: 26px"></i>
    </div>
    <div style="margin-left: 30px">
      <div>
        Make this
      </div>
      <div style="font-size: 48px">
        <span style="color: #090" data-bind="visible: solved"><i class="icon-ok"></i> <span style="font-size: 42px; font-weight: bold">Solved</span></span>&nbsp;
      </div>
      <div>
        <button style="vertical-align: middle" data-bind="disable: onFirst, event: {click: previous}">&#x2190;</button>
        <span data-bind="text: currentExercise()+1"></span> of <span data-bind="text: exercises.length"></span>
        <button style="vertical-align: middle" data-bind="disable: onLast, event: {click: next}">&#x2192;</button>
      </div>
    </div>
    
  </div>
</div>
"""


testEqualEditors = (e1, e2) ->
  e1.snapshot(300,300) == e2.snapshot(300,300)


module.exports = (opts) ->
  exercises = opts.exercises
  $div = $(opts.div)
  
  $div.html(template)
  
  editorWorkspace = editor({
    src: exercises[0].workspace
    code: $div.find(".workspace .code")
    output: $div.find(".workspace .output")
  })
  
  editorSolution = editor({
    src: exercises[0].solution
    code: $div.find(".solution .code")
    output: $div.find(".solution .output")
  })
  
  
  exercise = {
    workspace: ko.observable("")
    solution: ko.observable("")
    currentExercise: ko.observable(0)
    exercises: exercises
    solved: ko.observable(false)
    previous: () ->
      if !exercise.onFirst()
        exercise.currentExercise(exercise.currentExercise() - 1)
    next: () ->
      if !exercise.onLast()
        exercise.currentExercise(exercise.currentExercise() + 1)
  }
  
  exercise.onFirst = ko.computed () -> exercise.currentExercise() == 0
  exercise.onLast = ko.computed () -> exercise.currentExercise() == exercise.exercises.length - 1
  
  editorWorkspace.onchange (src) -> exercise.workspace(src)
  editorSolution.onchange (src) -> exercise.solution(src)
  
  ko.computed () ->
    e = exercises[exercise.currentExercise()]
    if e.workspace
      editorWorkspace.set(e.workspace)
    editorSolution.set(e.solution)
  
  ko.computed () ->
    exercise.workspace()
    exercise.solution()
    exercise.solved(testEqualEditors(editorWorkspace, editorSolution))
  
  ko.computed () ->
    exercises[exercise.currentExercise()].workspace = exercise.workspace()
  
  ko.applyBindings(exercise, $div[0])