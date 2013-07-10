isPlainObject = (o) ->
  o != undefined && o.constructor == Object
  # $.isPlainObject(o)
deepClone = (o) ->
  if _.isArray(o)
    return _.map(o, deepClone)
  else if isPlainObject(o)
    result = {}
    for own k, v of o
      result[k] = deepClone(v)
    return result
  else
    return o


class Watcher
  constructor: (@watchFn, @callback) ->
    @_oldValue = undefined
    @update()

  update: () ->
    newValue = @watchFn()
    updated = !_.isEqual(@_oldValue, newValue)
    @_oldValue = newValue
    return updated


class ReactiveScope

  constructor: (initial) ->
    @_watchers = []
    for own k, v of initial
      this[k] = v

  watch: (args...) ->
    callback = _.last(args)
    watchExprs = _.initial(args)

    watchFn = _.bind(->
      result = for watchExpr in watchExprs
        if _.isString(watchExpr)
          this[watchExpr]
        else if _.isFunction(watchExpr)
          watchExpr()
      deepClone(result)
    , this)

    watcher = new Watcher(watchFn, callback)
    @_watchers.push(watcher)
    remover = _.bind(->
      @_watchers = _.without(@_watchers, watcher)
    , this)
    return remover

  apply: (fn) ->
    result = fn()
    @digest()
    return result

  digest: () ->
    dirty = true
    digestCycles = 0
    while dirty
      digestCycles++
      if digestCycles > 10
        throw "Maximum digest cycles (10) exceeded."

      dirty = false

      callbacks = []
      for watcher in @_watchers
        updated = watcher.update()
        if updated
          callbacks.push(watcher.callback)
          dirty = true

      for callback in callbacks
        callback()


module.exports = ReactiveScope