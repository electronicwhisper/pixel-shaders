precision mediump float;

varying vec2 position;

float f(vec2 p) {
  //return length(floor(p) - vec2(1.,1.));
  //return abs(atan(p.y-.5, p.x-.5) + 1.0);
  return abs(length(p - 0.5) - 0.4);
}

vec2 smoothsign(vec2 x) {
  return smoothstep(-.01, .01, x)*2.-1.;
}

vec2 optimize(vec2 p, vec2 stepsize) {
  float left, right, up, down;
  for (float i = 0.; i < 14.; i++) {
    left  = f(p - vec2(stepsize.x, 0.));
    right = f(p + vec2(stepsize.x, 0.));
    up    = f(p - vec2(0., stepsize.y));
    down  = f(p + vec2(0., stepsize.y));
    
    p += sign(vec2(left-right, up-down)) * stepsize;
    
    stepsize /= 2.;
  }
  return p;
}

void main() {
  float res = 1./150.;
  vec2 p = optimize(position, vec2(res));
  
  if (f(p) < .01) {
    float d = distance(position, p) / res / 3.;
    float b = 1.-smoothstep(0., 1., d);
    gl_FragColor = vec4(b,b,b,1.);
  } else {
    gl_FragColor = vec4(0.,0.,0.,1.);
  }
}