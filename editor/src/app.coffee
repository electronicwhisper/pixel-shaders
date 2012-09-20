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

module.exports = () ->
  $canvas = $("<canvas />")
  
  $("#output").append($canvas)
  $canvas.attr({width: $canvas.innerWidth(), height: $canvas.innerHeight()})
  
  
  ctx = $canvas[0].getContext("experimental-webgl", {premultipliedAlpha: false})
  
  renderer = flatRenderer(ctx)
  
  renderer.loadFragmentShader(simpleSrc)
  renderer.link()
  
  
  renderer.draw()