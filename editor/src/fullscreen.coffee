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

module.exports = () ->
  editor = require("editor")({
    src: simpleSrc
    code: $("#code")
    output: $("#output")
  })