$ = require('jquery')

tt = $("#tt")

Tip = require('tip')
tip = new Tip(tt)
tip.attach('#mylink')

setInterval(() ->
  tt.text(Math.random())
, 1000)


vertexShaderSource = """
precision mediump float;

attribute vec3 vertexPosition;
varying vec2 position;
uniform vec2 boundsMin;
uniform vec2 boundsMax;

void main() {
  gl_Position = vec4(vertexPosition, 1.0);
  position = mix(boundsMin, boundsMax, (vertexPosition.xy + 1.0) * 0.5);
}
"""


fragmentShaderSource = """
precision mediump float;

varying vec2 position;

void main() {
  gl_FragColor = vec4(position.x, position.y, 0., 1.);
}
"""


fragmentShaderSource2 = """
precision mediump float;

varying vec2 position;
uniform sampler2D img;

void main() {
  gl_FragColor = texture2D(img, position);
}
"""

mandelbrot = """
precision mediump float;

varying vec2 position;

void main() {
  vec2 c = position;
  vec2 z = c;
  
  float escape = 0.;
  const float iter = 50.;
  for(float i = 0.; i<iter; i++) {
    escape = i;
    float x = (z.x * z.x - z.y * z.y) + c.x;
    float y = (z.y * z.x + z.x * z.y) + c.y;
	
    if ((x * x + y * y) > 800.0) break;
    z.x = x;
    z.y = y;
  }
  
  float b = escape/iter;
  
  gl_FragColor = vec4(b,b,b,1.);
}
"""





shader = require("shader")({
  canvas: $("canvas")[0]
  vertex: vertexShaderSource
  # fragment: fragmentShaderSource
  fragment: mandelbrot
  uniforms: {
    boundsMin: [0, 0]
    boundsMax: [1, 1]
  }
})

shader.draw()


pz = require("pan-zoom")({
  element: $("canvas")[0]
  minX: 0
  maxX: 1
  minY: 0
  maxY: 1
  flipY: true
})

pz.on("update", () ->
  shader.draw({
    uniforms: {
      boundsMin: [pz.minX, pz.minY]
      boundsMax: [pz.maxX, pz.maxY]
    }
  })
)





window.next = () ->
  bird = $("img")[0]
  
  shader.draw({
    fragment: fragmentShaderSource2
    uniforms: {
      img: bird
    }
  })

window.next2 = () ->
  # turtle = $("img")[1]
  $("img").attr("src", "turtle.jpg")
  
  shader.draw({
    uniforms: {
      img: $("img")[0]
    }
  })