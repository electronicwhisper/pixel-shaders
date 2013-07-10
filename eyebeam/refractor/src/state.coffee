ReactiveScope = require("ReactiveScope")

distortions = [
  {
    title: "Reflect"
    f:     "p.x = abs(p.x)"
  }
  {
    title: "Repeat"
    f:     "p.x = fract(p.x)"
  }
  {
    title: "Clamp"
    f:     "p.x = min(p.x, 0.)"
  }
  {
    title: "Step"
    f:     "p.x = floor(p.x)"
  }
  {
    title: "Wave"
    f:     "p.x = sin(p.x * 3.14159)"
  }
]


state = new ReactiveScope({
  distortions: distortions
  chain: []
  selected: false
  globalTransform: numeric.identity(3)
  image: 0
  polarMode: false
})

state.watch("selected", "chain", ->
  if state.selected && !_.contains(state.chain, state.selected)
    state.selected = false
)

window.state = state


module.exports = state