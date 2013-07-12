src = """
precision mediump float;

varying vec2 position;
uniform float time;

const float waves = 11.;

// triangle wave from 0 to 1
float wrap(float n) {
  return abs(mod(n, 2.)-1.)*-1. + 1.;
}

// creates a cosine wave in the plane at a given angle
float wave(float angle, vec2 point) {
  float cth = cos(angle);
  float sth = sin(angle);
  return (cos (cth*point.x + sth*point.y) + 1.) / 2.;
}

// sum cosine waves at various interfering angles
// wrap values when they exceed 1
float quasi(float interferenceAngle, vec2 point) {
  float sum = 0.;
  for (float i = 0.; i < waves; i++) {
    sum += wave(3.1416*i*interferenceAngle, point);
  }
  return wrap(sum);
}

void main() {
  vec2 p = position - 0.5;
  float b = quasi(time*0.016, p*40.);
  
  b *= 1.2;
  b += .1;
  
  vec3 col = vec3(b);
  
  gl_FragColor = vec4(col, 1.0);
  gl_FragColor.a *= 1. - smoothstep(0.44, 0.495, length(p));
}
"""

module.exports = () ->
  editor = require("../editor")({
    src: src
    code: $("#logo-code")
    output: $("#logo")
  })