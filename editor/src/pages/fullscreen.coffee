src = {quasi: """
precision mediump float;

varying vec2 position;
uniform float time;

const float waves = 19.;

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
  float b = quasi(time*0.002, (position-0.5)*200.);
  vec4 c1 = vec4(0.0,0.,0.2,1.);
  vec4 c2 = vec4(1.5,0.7,0.,1.);
  gl_FragColor = mix(c1,c2,b);
}
"""
warp: """
// inspired by http://www.iquilezles.org/www/articles/warp/warp.htm

precision mediump float;

varying vec2 position;
uniform float time;
uniform vec2 resolution;

// makes a pseudorandom number between 0 and 1
float hash(float n) {
  return fract(sin(n)*93942.234);
}

// smoothsteps a grid of random numbers at the integers
float noise(vec2 p) {
  vec2 w = floor(p);
  vec2 k = fract(p);
  k = k*k*(3.-2.*k); // smooth it
  
  float n = w.x + w.y*57.;
  
  float a = hash(n);
  float b = hash(n+1.);
  float c = hash(n+57.);
  float d = hash(n+58.);
  
  return mix(
    mix(a, b, k.x),
    mix(c, d, k.x),
    k.y);
}

// rotation matrix
mat2 m = mat2(0.6,0.8,-0.8,0.6);

// fractal brownian motion (i.e. photoshop clouds)
float fbm(vec2 p) {
  float f = 0.;
  f += 0.5000*noise(p); p *= 2.02*m;
  f += 0.2500*noise(p); p *= 2.01*m;
  f += 0.1250*noise(p); p *= 2.03*m;
  f += 0.0625*noise(p);
  f /= 0.9375;
  return f;
}

void main() {
  // relative coordinates
  vec2 p = vec2(position*6.)*vec2(resolution.x/resolution.y, 1.);
  float t = time * .009;
  
  // calling fbm on itself
  vec2 a = vec2(fbm(p+t*3.), fbm(p-t*3.+8.1));
  vec2 b = vec2(fbm(p+t*4. + a*7. + 3.1), fbm(p-t*4. + a*7. + 91.1));
  float c = fbm(b*9. + t*20.);
  
  // increase contrast
  c = smoothstep(0.15,0.98,c);
  
  // mix in some color
  vec3 col = vec3(c);
  col.rb += b*0.17;
  
  gl_FragColor = vec4(col, 1.);
}
"""}

module.exports = () ->
  hash = location.hash.substr(1)
  hash = "quasi" if hash == ""
  hash = "quasi" if !src[hash]
  
  editor = require("../editor")({
    src: src[hash]
    code: $("#code")
    output: $("#output")
  })