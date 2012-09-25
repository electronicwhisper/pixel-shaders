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
start: """
precision mediump float;

varying vec2 position;

void main() {
gl_FragColor.r = 1.0;
gl_FragColor.g = 0.0;
gl_FragColor.b = 0.0;
gl_FragColor.a = 1.0;
}
"""
end: """
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
end: """
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
end: """
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







module.exports = () ->
  
  editor = require("editor")({
    src: exercises[0].start
    code: $("#code")
    output: $("#output")
  })
  
  makeEditor = require("editor")({
    src: exercises[0].end
    code: $("#makeCode")
    output: $("#makeOutput")
  })