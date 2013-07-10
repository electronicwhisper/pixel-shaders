solve = (objective, argsToMatrix, startArgs) ->
  original = argsToMatrix(startArgs)

  obj = (args) ->
    matrix = argsToMatrix(args)
    return objective(matrix)

  uncmin = numeric.uncmin(obj, startArgs)

  if isNaN(uncmin.f)
    console.warn "NaN"
    return original
  else
    error = obj(uncmin.solution)
    if error > .000001
      console.warn "Error too big", error
      return original

    # window.debugSolver = {
    #   uncmin: uncmin
    #   error: obj(uncmin.solution)
    # }

    solution = uncmin.solution
    m = argsToMatrix(solution)
    # if t.area() < .001
    #   console.log "too small", t.a
    #   return c0.transform
    return m


module.exports = solve