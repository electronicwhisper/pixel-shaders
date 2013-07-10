
solve = require("solve")
state = require("state")
bounds = require("bounds")


dist = (p1, p2) ->
  d = numeric['-'](p1, p2)
  numeric.dot(d, d)

lerp = (x, min, max) ->
  min + x * (max - min)





solveTouch = (touches) ->
  # touches is an array of {original: [x, y, 1], current: [x, y, 1]}
  # original should be in _local_ coordinates (i.e. original matrix already applied)
  # current should be in _event_ coordinates
  objective = (m) ->
    error = 0
    for touch in touches[0...3]
      currentLocal = toLocal(touch.current)
      currentLocal = numeric.dot(m, currentLocal)
      error += dist(touch.original, currentLocal)
    return error

  if touches.length == 1
    transform = solve(objective,
      ([x, y]) ->
        [[1, 0, x],
         [0, 1, y],
         [0, 0, 1]]
      , [0, 0]
    )
  else if touches.length == 2
    transform = solve(objective,
      ([s, r, x, y]) ->
        [[s,  r, x],
         [-r, s, y],
         [0,  0, 1]]
      , [1, 0, 0, 0]
    )
  else if touches.length >= 3
    transform = solve(objective,
      ([a, b, c, d, x, y]) ->
        [[a, b, x],
         [c, d, y],
         [0,  0, 1]]
      , [1, 0, 0, 1, 0, 0]
    )

  return transform



getMatrix = ->
  if state.selected
    # state.selected.transform
    numeric.dot(state.selected.transform, state.globalTransform)
  else
    state.globalTransform
  # _.last(state.chain).transform

setMatrix = (m) ->
  if state.selected
    # state.selected.transform = m
    state.selected.transform = numeric.dot(m, numeric.inv(state.globalTransform))
  else
    state.globalTransform = m
  # _.last(state.chain).transform = m


convertToPolar = (v) ->
  r = Math.sqrt(v[0] * v[0] + v[1] * v[1])
  a = Math.atan2(v[1], v[0])
  return [r, a, 1]



toLocal = (v) ->
  v = numeric.dot(state.globalTransform, v)
  if state.selected
    if state.polarMode
      v = convertToPolar(v)
    v = numeric.dot(state.selected.transform, v)
  return v

applyMatrix = (m) ->
  if state.selected
    state.selected.transform = numeric.dot(m, state.selected.transform)
  else
    state.globalTransform = numeric.dot(m, state.globalTransform)








pointers = {}

$("#c").on("pointerdown", (e) ->
  e = e.originalEvent
  pointers[e.pointerId] = {x: e.clientX, y: e.clientY}
)
$("#c").on("pointermove", (e) ->
  e = e.originalEvent
  pointer = pointers[e.pointerId]
  if pointer
    pointer.x = event.clientX
    pointer.y = event.clientY
)
$("#c").on("pointerup", (e) ->
  e = e.originalEvent
  delete pointers[e.pointerId]
)






pointerPosition = (pointer) ->
  $el = $("#c")
  offset = $el.offset()
  width = $el.width()
  height = $el.height()

  # Scaled from 0 to 1
  x =     (pointer.x - offset.left) / width
  y = 1 - (pointer.y - offset.top ) / height

  b = bounds()
  x = lerp(x, b.boundsMin[0], b.boundsMax[0])
  y = lerp(y, b.boundsMin[1], b.boundsMax[1])

  return [x, y, 1]




tracking = {}

trackingLoop = ->

  ids = []
  for own id, pointer of pointers
    ids.push(id)
    if t = tracking[id]
      t.current = pointerPosition(pointer)
    else
      t = tracking[id] = {}
      t.current = pointerPosition(pointer)
      t.original = toLocal(t.current)

  # Remove touches that have ended
  tracking = _.pick(tracking, ids)

  # Solve.
  touches = _.values(tracking)
  if touches.length > 0
    transform = solveTouch(touches)
    state.apply ->
      applyMatrix(transform)


  requestAnimationFrame(trackingLoop)

trackingLoop()







angleIncrement = 0.02
scaleIncrement = 1.02
key(",", (e) ->
  s = Math.cos(angleIncrement)
  r = Math.sin(angleIncrement)
  m = [[s,  r, 0],
       [-r, s, 0],
       [0,  0, 1]]
  state.apply ->
    applyMatrix(m)
)
key(".", (e) ->
  s = Math.cos(-angleIncrement)
  r = Math.sin(-angleIncrement)
  m = [[s,  r, 0],
       [-r, s, 0],
       [0,  0, 1]]
  state.apply ->
    applyMatrix(m)
)
key("z", (e) ->
  s = scaleIncrement
  m = [[s, 0, 0],
       [0, s, 0],
       [0, 0, 1]]
  state.apply ->
    applyMatrix(m)
)
key("x", (e) ->
  s = 1/scaleIncrement
  m = [[s, 0, 0],
       [0, s, 0],
       [0, 0, 1]]
  state.apply ->
    applyMatrix(m)
)
