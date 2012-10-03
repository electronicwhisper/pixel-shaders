colors = [{
workspace: """
precision mediump float;

void main() {
  gl_FragColor.r = 1.0;
  gl_FragColor.g = 0.0;
  gl_FragColor.b = 0.0;
  gl_FragColor.a = 1.0;
}
"""
solution: """
precision mediump float;

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

void main() {
  gl_FragColor.r = 1.0;
  gl_FragColor.g = 0.5;
  gl_FragColor.b = 0.0;
  gl_FragColor.a = 1.0;
}
"""
},{
solution: """
precision mediump float;

void main() {
  gl_FragColor.r = 0.5;
  gl_FragColor.g = 0.5;
  gl_FragColor.b = 0.5;
  gl_FragColor.a = 1.0;
}
"""
}]



gradients = [{
workspace: """
precision mediump float;

varying vec2 position;

void main() {
  gl_FragColor.r = position.x;
  gl_FragColor.g = 0.0;
  gl_FragColor.b = 0.0;
  gl_FragColor.a = 1.0;
}
"""
solution:   """
precision mediump float;

varying vec2 position;

void main() {
  gl_FragColor.r = 0.0;
  gl_FragColor.g = 0.0;
  gl_FragColor.b = position.y;
  gl_FragColor.a = 1.0;
}
"""
},{
solution:   """
precision mediump float;

varying vec2 position;

void main() {
  gl_FragColor.r = position.x;
  gl_FragColor.g = position.x;
  gl_FragColor.b = 0.0;
  gl_FragColor.a = 1.0;
}
"""
},{
solution:   """
precision mediump float;

varying vec2 position;

void main() {
  gl_FragColor.r = position.x;
  gl_FragColor.g = 0.0;
  gl_FragColor.b = position.y;
  gl_FragColor.a = 1.0;
}
"""
}
]



arithmetic = [{
workspace: """
precision mediump float;

varying vec2 position;

void main() {
  gl_FragColor.r = 1.0 - position.x;
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
  gl_FragColor.b = 1.0 - position.y;
  gl_FragColor.a = 1.0;
}
"""
},{
solution:   """
precision mediump float;

varying vec2 position;

void main() {
  gl_FragColor.r = 1.0 - position.x;
  gl_FragColor.g = 0.0;
  gl_FragColor.b = position.x;
  gl_FragColor.a = 1.0;
}
"""
},{
solution:   """
precision mediump float;

varying vec2 position;

void main() {
  gl_FragColor.r = (position.x + position.y) / 2.0;
  gl_FragColor.g = 0.0;
  gl_FragColor.b = 0.0;
  gl_FragColor.a = 1.0;
}
"""
},{
solution:   """
precision mediump float;

varying vec2 position;

void main() {
  gl_FragColor.r = (position.x + 1.0 - position.y) / 2.0;
  gl_FragColor.g = 0.0;
  gl_FragColor.b = 0.0;
  gl_FragColor.a = 1.0;
}
"""
}
]


module.exports = () ->
  $("code").each () ->
    CodeMirror.runMode($(this).text(), "text/x-glsl", this)
    $(this).addClass("cm-s-default")
  
  require("../exercise")({
    div: $("#exercise-colors")
    exercises: colors
  })
  require("../exercise")({
    div: $("#exercise-gradients")
    exercises: gradients
  })
  require("../exercise")({
    div: $("#exercise-arithmetic")
    exercises: arithmetic
  })