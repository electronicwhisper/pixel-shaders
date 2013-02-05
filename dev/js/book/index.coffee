ko = require("knockout")
$ = require("jquery")
_ = require("underscore")
CodeMirror = require("codemirror")

# ======================================================= Register Knockout bindings

require("bindings")


# ======================================================= String Util

srcTrim = (s) ->
  lines = s.split("\n")
  indent = Infinity
  for line in lines
    lineIndent = line.search(/[^ ]/)
    indent = Math.min(indent, lineIndent) if lineIndent != -1
  if indent != Infinity
    lines = for line in lines
      line.substr(indent)
  return lines.join("\n").trim()

XRegExp = require('xregexp').XRegExp
parseUniforms = (src) ->
  regex = XRegExp('uniform +(?<type>[^ ]+) +(?<name>[^ ;]+) *;', 'g')
  
  uniforms = {}
  XRegExp.forEach(src, regex, (match) ->
    uniforms[match.name] = {
      type: match.type
    }
  )
  return uniforms


# ======================================================= Animation Util

rafAnimate = (callback) ->
  animate = () ->
    require("raf")(animate)
    callback()
  animate()


# ======================================================= For Shaders

# TODO: this will be part of the uniform itself, so we can have separate, controllable timelines
startTime = Date.now()
updateUniforms = (uniformsObservable) ->
  uniforms = uniformsObservable()
  changed = false
  
  for own name, uniform of uniforms
    if name == "time" && uniform.type == "float"
      uniform.value = (Date.now() - startTime) / 1000
      changed = true
    else if name == "webcam" && uniform.type == "sampler2D"
      uniform.value = require("webcam")()
      changed = true
  
  if changed
    uniformsObservable(uniforms)


shaderModel = (src) ->
  model = {
    bounds: ko.observable({
      minX: 0
      minY: 0
      maxX: 1
      maxY: 1
    })
    src: ko.observable(src)
    compiledSrc: ko.observable(src)
    errors: ko.observable([])
    annotations: ko.observable([])
    uniforms: ko.observable({})
    position: ko.observable([0.3, 0.4])
  }
  
  rafAnimate () ->
    updateUniforms(model.uniforms)
  
  # compile and mark errors
  ko.computed () ->
    src = model.src()
    errors = require("glsl-error")(src)
    model.errors(errors)
    
    if !_.some(errors)
      model.compiledSrc(src)
  
  # update uniforms
  ko.computed () ->
    src = model.compiledSrc()
    # TODO: make it not clear set values, we'll need to .peek() at uniforms
    model.uniforms(parseUniforms(src))
  
  # parse the src
  parsedSrc = ko.computed () ->
    src = model.compiledSrc()
    try
      require("parse-glsl").parse(src, "fragment_start")
  
  # interpret based on position and annotate the line-by-line evaluation
  (ko.computed () ->
    position = model.position()
    if position
      # round it
      round = (x) ->
        mult = Math.pow(10, 3)
        Math.round(x*mult) / mult
      position = (round(x) for x in position)
      
      ast = parsedSrc()
      uniforms = model.uniforms()
      env = {
        gl_FragColor: [0, 0, 0, 0]
        position: position
      }
      for own name, uniform of uniforms
        env[name] = if _.isNumber(uniform.value) then [uniform.value] else uniform.value
      try
        require("interpret")(env, ast)
        annotations = require("interpret").extractStatements(ast)
        model.annotations(annotations)
      catch e
        model.annotations([])
        console.log ast
        # throw e
  ).extend({ throttle: 1 })
  
  return model


# ======================================================= Shader Example

buildShaderExample = ($replace) ->
  src = srcTrim($replace.text())
  model = shaderModel(src)
  
  $div = $("""
  <div class="book-view-edit">
    <div class="book-view" data-bind="panAndZoom: {bounds: bounds, position: position}">
      <canvas data-bind="drawShader: {bounds: bounds, src: compiledSrc, uniforms: uniforms}"></canvas>
      <canvas class="book-grid" data-bind="drawGrid: {bounds: bounds, color: 'white'}"></canvas>
      <!--<div class="book-crosshair" data-bind="relPosition: {bounds: bounds, position: position}"></div>-->
    </div>
    <div class="book-edit book-editor" data-bind="editorShader: {src: src, multiline: true, errors: errors, annotations: annotations}"></div>
  </div>
  """)
  
  $replace.replaceWith($div)
  ko.applyBindings(model, $div[0]) # for sizing, this has to be after the div has been added to the body


# ======================================================= Shader Exercise

testEqualPixelArrays = (p1, p2) ->
  len = p1.length
  
  # sample 1000 random locations to test equivalence
  equivalent = true
  for i in [0...1000]
    location = Math.floor(Math.random()*len)
    diff = Math.abs(p1[location] - p2[location])
    if diff > 2
      equivalent = false
  
  return equivalent


buildShaderExercise = ($replace) ->
  $div = $("""
  <div>
    <div class="book-view-edit">
      <div class="book-view" data-bind="panAndZoom: {bounds: work.bounds, position: work.position}">
        <canvas class="shader-work" data-bind="drawShader: {bounds: work.bounds, src: work.compiledSrc, uniforms: work.uniforms}"></canvas>
        <canvas class="book-grid" data-bind="drawGrid: {bounds: work.bounds, color: 'white'}"></canvas>
      </div>
      <div class="book-edit book-editor" data-bind="editorShader: {src: work.src, multiline: true, errors: work.errors, annotations: work.annotations}">
      </div>
    </div>
    <div class="book-view-edit">
      <div class="book-view" data-bind="panAndZoom: {bounds: work.bounds, position: work.position}">
        <canvas class="shader-solution" data-bind="drawShader: {bounds: work.bounds, src: solution.compiledSrc, uniforms: solution.uniforms}"></canvas>
        <canvas class="book-grid" data-bind="drawGrid: {bounds: work.bounds, color: 'white'}"></canvas>
      </div>
      <div class="book-edit" style="font-family: helvetica; font-size: 30px;">
        <div style="float: left">
          <i class="icon-arrow-left" style="font-size: 26px"></i>
        </div>
        <div style="margin-left: 30px;">
          <div>
            Make this
          </div>
          <div data-bind="style: {visibility: solved() ? 'visible' : 'hidden'}">
            <span style="color: #090; font-size: 42px"><i class="icon-ok"></i> <span style="font-size: 42px; font-weight: bold">Solved</span></span>
          </div>
          <div>
            <button style="vertical-align: middle" data-bind="disable: onFirst, event: {click: previous}">&#x2190;</button>
            <span data-bind="text: currentExercise()+1"></span> of <span data-bind="text: numExercises"></span>
            <button style="vertical-align: middle" data-bind="disable: onLast, event: {click: next}">&#x2192;</button>
          </div>
        </div>
      </div>
    </div>
  </div>
  """)
  
  
  workSrcs = [srcTrim($replace.find(".start").text())]
  workModel = shaderModel(workSrcs[0])
  
  solutionSrcs = $replace.find(".solution").map () ->
    srcTrim($(this).text())
  solutionModel = shaderModel(solutionSrcs[0])
  
  model = {
    work: workModel
    solution: solutionModel
    solved: ko.observable(false)
    currentExercise: ko.observable(0)
    numExercises: solutionSrcs.length
  }
  
  model.onFirst = ko.computed () -> model.currentExercise() == 0
  model.onLast = ko.computed () -> model.currentExercise() == model.numExercises - 1
  model.previous = () ->
    if !model.onFirst()
      model.currentExercise(model.currentExercise() - 1)
  model.next = () ->
    if !model.onLast()
      model.currentExercise(model.currentExercise() + 1)
  
  ko.computed () ->
    currentExercise = model.currentExercise()
    model.solution.src(solutionSrcs[currentExercise])
    if workSrcs[currentExercise]
      model.work.src(workSrcs[currentExercise])
  
  ko.computed () ->
    workSrc = model.work.src()
    workSrcs[model.currentExercise.peek()] = workSrc
  
  ko.computed () ->
    model.work.compiledSrc()
    model.solution.compiledSrc()
    setTimeout(checkSolved, 0)
  
  checkSolved = () ->
    workPixels = $div.find(".shader-work")[0].shader?.readPixels()
    solutionPixels = $div.find(".shader-solution")[0].shader?.readPixels()
    
    if workPixels && solutionPixels
      solved = testEqualPixelArrays(workPixels, solutionPixels)
      model.solved(solved)
  
  
  $replace.replaceWith($div)
  ko.applyBindings(model, $div[0])


# ======================================================= Evaluator

buildEvaluator = ($replace) ->
  src = srcTrim($replace.text())
  $div = $("""
  <div class="book-editor" data-bind="editorShader: {src: src, multiline: false, annotations: annotations, errors: errors}"></div>
  """)
  
  model = {
    src: ko.observable(src)
    annotations: ko.observable([])
    errors: ko.observable([])
  }
  
  ko.computed () ->
    src = model.src()
    try
      ast = require("parse-glsl").parse(src, "assignment_expression")
      # console.log ast
      require("interpret")({}, ast)
      
      result = require("interpret").vecToString(ast.evaluated, 3)
      # console.log result
      model.annotations([{line: 0, message: result}])
      model.errors([])
    catch e
      model.annotations([])
      model.errors([{line: 0, message: ""}])
  
  $replace.replaceWith($div)
  ko.applyBindings(model, $div[0])


# ======================================================= Graph Example

buildGraphExample = ($replace) ->
  src = srcTrim($replace.text())
  $div = $("""
  <div class="split">
    <div class="left" data-bind="panAndZoom: {bounds: bounds}">
      <canvas class="book-grid" data-bind="drawGrid: {bounds: bounds, color: 'black'}"></canvas>
      <canvas data-bind="drawGraph: {bounds: bounds, f: f}"></canvas>
    </div>
    <div class="right">
      <div class="book-editor" data-bind="editorShader: {src: src, multiline: false, errors: errors, annotations: annotations}"></div>
    </div>
  </div>
  """)
  
  model = {
    src: ko.observable(src)
    annotations: ko.observable([])
    errors: ko.observable([])
    bounds: ko.observable({
      minX: -2
      minY: -2
      maxX: 2
      maxY: 2
    })
    f: ko.observable(false)
  }
  
  parsedSrc = ko.observable()
  
  ko.computed () ->
    src = model.src()
    try
      ast = require("parse-glsl").parse(src, "assignment_expression")
      require("interpret")({x: [0]}, ast)
      parsedSrc(ast)
      model.errors([])
    catch e
      model.errors([{line: 0, message: ""}])
  
  ko.computed () ->
    ast = parsedSrc()
    model.f((x) ->
      require("interpret")({x: [x]}, ast)
      return ast.evaluated
    )
  
  $replace.replaceWith($div)
  ko.applyBindings(model, $div[0])











# ======================================================= Build Util

build = ($selection, buildFunction) ->
  $selection.each () ->
    buildFunction($(this))


# ======================================================= Build

do ->
  build($(".shader-example"), buildShaderExample)
  build($(".shader-exercise"), buildShaderExercise)
  build($(".evaluator"), buildEvaluator)
  build($(".graph-example"), buildGraphExample)
  
  $("code").each () ->
    CodeMirror.runMode($(this).text(), "text/x-glsl", this)
    $(this).addClass("cm-s-default")
