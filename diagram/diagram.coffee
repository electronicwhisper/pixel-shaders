min = Math.min
max = Math.max

clamp = (x, minVal, maxVal) ->
   min(max(x, minVal), maxVal)


smoothstep = (edge0, edge1, x) ->
  t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
  return t * t * (3.0 - 2.0 * t)






ko.bindingHandlers.canvas = {
  init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
    ctx = element.getContext("2d")
    draw = valueAccessor()
    
    ko.computed () ->
      draw(ctx)
}
ko.bindingHandlers.position = {
  update: (element, valueAccessor, allBindingsAccessor) ->
    position = ko.utils.unwrapObservable(valueAccessor())
    $(element).css({left: position[0], top: position[1], width: position[2], height: position[3]})
}




precision = 3


graphPos = [20, 20]
graphSize = [300, 200]

canvasToModel = (p) ->
  numeric.div(numeric.sub(p, graphPos), graphSize)

modelToCanvas = (p) ->
  numeric.add(numeric.mul(p, graphSize), graphPos)

getOffset = (el) ->
  offset = $(el).parents(".diagram").offset()
  offset = [offset.left, offset.top]


makeAdjustable = (v) ->
  adjustable = {
    value: ko.observable(v.toFixed(precision))
    constrain: () -> [0, 1]
    mousedown: (data, e) ->
      offset = getOffset(e.target)
      
      mousemove = (e) ->
        p = [e.pageX, e.pageY]
        p = canvasToModel(numeric.sub(p, offset))
        
        constrain = adjustable.constrain()
        newVal = clamp(p[0], constrain...)
        
        adjustable.value(newVal.toFixed(precision))
      mouseup = (e) ->
        $(document).off("mousemove", mousemove)
        $(document).off("mouseup", mouseup)
      $(document).on("mousemove", mousemove)
      $(document).on("mouseup", mouseup)
  }



diagram = {
  canvasToModel: canvasToModel
  modelToCanvas: modelToCanvas
  
  domain: [0, 1]
  range: [0, 1]
  edge0: makeAdjustable(0.3000)
  edge1: makeAdjustable(0.8000)
  x: ko.observable(0)
  y: ko.observable(0)
  mousemove: (data, e) ->
    offset = getOffset(e.target)
    p = numeric.sub([e.pageX, e.pageY], offset)
    p = canvasToModel(p)
    x = clamp(p[0], 0, 1).toFixed(precision)
    y = smoothstep(diagram.edge0.value(), diagram.edge1.value(), x).toFixed(precision)
    diagram.x(x)
    diagram.y(y)
  draw: (ctx) ->
    ctx.setTransform(1, 0, 0, 1, 0, 0)
    ctx.clearRect(0, 0, 500, 500)
    
    labelOffset = 0
    
    ctx.translate(graphPos...)
    
    [graphWidth, graphHeight] = graphSize
    
    
    ctx.lineWidth = 0.5
    
    # axes
    ctx.strokeStyle = "#999"
    ctx.beginPath()
    ctx.moveTo(0, 0)
    ctx.lineTo(0, graphHeight)
    ctx.lineTo(graphWidth, graphHeight)
    ctx.stroke()
    
    # labels
    ctx.textBaseline = "middle"
    ctx.textAlign = "right"
    ctx.fillText("0.0 ", -labelOffset, graphHeight)
    ctx.fillText("1.0 ", -labelOffset, 0)
    
    # graph
    ctx.lineWidth = 1.5
    ctx.strokeStyle = "#009"
    ctx.beginPath()
    for xp in [0...graphWidth]
      x = xp / graphWidth
      y = smoothstep(diagram.edge0.value(), diagram.edge1.value(), x)
      yp = (1 - y) * graphHeight
      if xp == 0
        ctx.moveTo(xp, yp)
      else
        ctx.lineTo(xp, yp)
    ctx.stroke()
}

window.diagram = diagram

ko.applyBindings(diagram)