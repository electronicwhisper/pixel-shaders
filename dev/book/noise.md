<div class="shader-temp">
<div class="shown">

    float random(float p) {
      return fract(sin(p)*10000.);
    }
    float noise(vec2 p) {
      return random(p.x + p.y*10000.);
    }

</div>
<div class="code">

    precision mediump float;

    varying vec2 position;
    uniform float time;
    uniform sampler2D webcam;


    float scale = 6.;
    vec4 camera(vec2 p) {
      return texture2D(webcam, p / scale);
    }
    vec4 display(float color) {return vec4(vec3(color), 1.);}
    vec4 display(vec4  color) {return color;}


    float random(float p) {
      return fract(sin(p)*10000.);
    }
    float noise(vec2 p) {
      return random(p.x + p.y*10000.);
    }


    float stepNoise(vec2 p) {
      return noise(floor(p));
    }


    vec2 sw(vec2 p) {return vec2( floor(p.x) , floor(p.y) );}
    vec2 se(vec2 p) {return vec2( ceil(p.x)  , floor(p.y) );}
    vec2 nw(vec2 p) {return vec2( floor(p.x) , ceil(p.y)  );}
    vec2 ne(vec2 p) {return vec2( ceil(p.x)  , ceil(p.y)  );}

    float smoothNoise(vec2 p) {
      vec2 inter = smoothstep(0., 1., fract(p));
      float s = mix(noise(sw(p)), noise(se(p)), inter.x);
      float n = mix(noise(nw(p)), noise(ne(p)), inter.x);
      return mix(s, n, inter.y);
      return noise(nw(p));
    }


    float fractalNoise(vec2 p) {
      float total = 0.0;
      total += smoothNoise(p);
      total += smoothNoise(p*2.) / 2.;
      total += smoothNoise(p*4.) / 4.;
      total += smoothNoise(p*8.) / 8.;
      total += smoothNoise(p*16.) / 16.;
      total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
      return total;
    }


    float movingNoise(vec2 p) {
      float total = 0.0;
      total += smoothNoise(p     - time);
      total += smoothNoise(p*2.  + time) / 2.;
      total += smoothNoise(p*4.  - time) / 4.;
      total += smoothNoise(p*8.  + time) / 8.;
      total += smoothNoise(p*16. - time) / 16.;
      total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
      return total;
    }


    float nestedNoise(vec2 p) {
      float x = movingNoise(p);
      float y = movingNoise(p + 100.);
      return movingNoise(p + vec2(x, y));
    }


    vec4 distort(vec2 p) {
      return camera(p + movingNoise(p)-.5);
    }


    void main() {
      vec2 p = position * scale;
      gl_FragColor = display(noise(p));
    }

</div>
</div>

<div class="shader-temp">
<div class="shown">

    float stepNoise(vec2 p) {
      return noise(floor(p));
    }

</div>
<div class="code">

    precision mediump float;

    varying vec2 position;
    uniform float time;
    uniform sampler2D webcam;


    float scale = 6.;
    vec4 camera(vec2 p) {
      return texture2D(webcam, p / scale);
    }
    vec4 display(float color) {return vec4(vec3(color), 1.);}
    vec4 display(vec4  color) {return color;}


    float random(float p) {
      return fract(sin(p)*10000.);
    }
    float noise(vec2 p) {
      return random(p.x + p.y*10000.);
    }


    float stepNoise(vec2 p) {
      return noise(floor(p));
    }


    vec2 sw(vec2 p) {return vec2( floor(p.x) , floor(p.y) );}
    vec2 se(vec2 p) {return vec2( ceil(p.x)  , floor(p.y) );}
    vec2 nw(vec2 p) {return vec2( floor(p.x) , ceil(p.y)  );}
    vec2 ne(vec2 p) {return vec2( ceil(p.x)  , ceil(p.y)  );}

    float smoothNoise(vec2 p) {
      vec2 inter = smoothstep(0., 1., fract(p));
      float s = mix(noise(sw(p)), noise(se(p)), inter.x);
      float n = mix(noise(nw(p)), noise(ne(p)), inter.x);
      return mix(s, n, inter.y);
      return noise(nw(p));
    }


    float fractalNoise(vec2 p) {
      float total = 0.0;
      total += smoothNoise(p);
      total += smoothNoise(p*2.) / 2.;
      total += smoothNoise(p*4.) / 4.;
      total += smoothNoise(p*8.) / 8.;
      total += smoothNoise(p*16.) / 16.;
      total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
      return total;
    }


    float movingNoise(vec2 p) {
      float total = 0.0;
      total += smoothNoise(p     - time);
      total += smoothNoise(p*2.  + time) / 2.;
      total += smoothNoise(p*4.  - time) / 4.;
      total += smoothNoise(p*8.  + time) / 8.;
      total += smoothNoise(p*16. - time) / 16.;
      total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
      return total;
    }


    float nestedNoise(vec2 p) {
      float x = movingNoise(p);
      float y = movingNoise(p + 100.);
      return movingNoise(p + vec2(x, y));
    }


    vec4 distort(vec2 p) {
      return camera(p + movingNoise(p)-.5);
    }


    void main() {
      vec2 p = position * scale;
      gl_FragColor = display(stepNoise(p));
    }

</div>
</div>

<div class="shader-temp">
<div class="shown">

    vec2 sw(vec2 p) {return vec2( floor(p.x) , floor(p.y) );}
    vec2 se(vec2 p) {return vec2( ceil(p.x)  , floor(p.y) );}
    vec2 nw(vec2 p) {return vec2( floor(p.x) , ceil(p.y)  );}
    vec2 ne(vec2 p) {return vec2( ceil(p.x)  , ceil(p.y)  );}

    float smoothNoise(vec2 p) {
      vec2 inter = smoothstep(0., 1., fract(p));
      float s = mix(noise(sw(p)), noise(se(p)), inter.x);
      float n = mix(noise(nw(p)), noise(ne(p)), inter.x);
      return mix(s, n, inter.y);
      return noise(nw(p));
    }

</div>
<div class="code">

    precision mediump float;

    varying vec2 position;
    uniform float time;
    uniform sampler2D webcam;


    float scale = 6.;
    vec4 camera(vec2 p) {
      return texture2D(webcam, p / scale);
    }
    vec4 display(float color) {return vec4(vec3(color), 1.);}
    vec4 display(vec4  color) {return color;}


    float random(float p) {
      return fract(sin(p)*10000.);
    }
    float noise(vec2 p) {
      return random(p.x + p.y*10000.);
    }


    float stepNoise(vec2 p) {
      return noise(floor(p));
    }


    vec2 sw(vec2 p) {return vec2( floor(p.x) , floor(p.y) );}
    vec2 se(vec2 p) {return vec2( ceil(p.x)  , floor(p.y) );}
    vec2 nw(vec2 p) {return vec2( floor(p.x) , ceil(p.y)  );}
    vec2 ne(vec2 p) {return vec2( ceil(p.x)  , ceil(p.y)  );}

    float smoothNoise(vec2 p) {
      vec2 inter = smoothstep(0., 1., fract(p));
      float s = mix(noise(sw(p)), noise(se(p)), inter.x);
      float n = mix(noise(nw(p)), noise(ne(p)), inter.x);
      return mix(s, n, inter.y);
      return noise(nw(p));
    }


    float fractalNoise(vec2 p) {
      float total = 0.0;
      total += smoothNoise(p);
      total += smoothNoise(p*2.) / 2.;
      total += smoothNoise(p*4.) / 4.;
      total += smoothNoise(p*8.) / 8.;
      total += smoothNoise(p*16.) / 16.;
      total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
      return total;
    }


    float movingNoise(vec2 p) {
      float total = 0.0;
      total += smoothNoise(p     - time);
      total += smoothNoise(p*2.  + time) / 2.;
      total += smoothNoise(p*4.  - time) / 4.;
      total += smoothNoise(p*8.  + time) / 8.;
      total += smoothNoise(p*16. - time) / 16.;
      total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
      return total;
    }


    float nestedNoise(vec2 p) {
      float x = movingNoise(p);
      float y = movingNoise(p + 100.);
      return movingNoise(p + vec2(x, y));
    }


    vec4 distort(vec2 p) {
      return camera(p + movingNoise(p)-.5);
    }


    void main() {
      vec2 p = position * scale;
      gl_FragColor = display(smoothNoise(p));
    }

</div>
</div>

<div class="shader-temp">
<div class="shown">

    float fractalNoise(vec2 p) {
      float total = 0.0;
      total += smoothNoise(p);
      total += smoothNoise(p*2.) / 2.;
      total += smoothNoise(p*4.) / 4.;
      total += smoothNoise(p*8.) / 8.;
      total += smoothNoise(p*16.) / 16.;
      total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
      return total;
    }

</div>
<div class="code">

    precision mediump float;

    varying vec2 position;
    uniform float time;
    uniform sampler2D webcam;


    float scale = 6.;
    vec4 camera(vec2 p) {
      return texture2D(webcam, p / scale);
    }
    vec4 display(float color) {return vec4(vec3(color), 1.);}
    vec4 display(vec4  color) {return color;}


    float random(float p) {
      return fract(sin(p)*10000.);
    }
    float noise(vec2 p) {
      return random(p.x + p.y*10000.);
    }


    float stepNoise(vec2 p) {
      return noise(floor(p));
    }


    vec2 sw(vec2 p) {return vec2( floor(p.x) , floor(p.y) );}
    vec2 se(vec2 p) {return vec2( ceil(p.x)  , floor(p.y) );}
    vec2 nw(vec2 p) {return vec2( floor(p.x) , ceil(p.y)  );}
    vec2 ne(vec2 p) {return vec2( ceil(p.x)  , ceil(p.y)  );}

    float smoothNoise(vec2 p) {
      vec2 inter = smoothstep(0., 1., fract(p));
      float s = mix(noise(sw(p)), noise(se(p)), inter.x);
      float n = mix(noise(nw(p)), noise(ne(p)), inter.x);
      return mix(s, n, inter.y);
      return noise(nw(p));
    }


    float fractalNoise(vec2 p) {
      float total = 0.0;
      total += smoothNoise(p);
      total += smoothNoise(p*2.) / 2.;
      total += smoothNoise(p*4.) / 4.;
      total += smoothNoise(p*8.) / 8.;
      total += smoothNoise(p*16.) / 16.;
      total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
      return total;
    }


    float movingNoise(vec2 p) {
      float total = 0.0;
      total += smoothNoise(p     - time);
      total += smoothNoise(p*2.  + time) / 2.;
      total += smoothNoise(p*4.  - time) / 4.;
      total += smoothNoise(p*8.  + time) / 8.;
      total += smoothNoise(p*16. - time) / 16.;
      total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
      return total;
    }


    float nestedNoise(vec2 p) {
      float x = movingNoise(p);
      float y = movingNoise(p + 100.);
      return movingNoise(p + vec2(x, y));
    }


    vec4 distort(vec2 p) {
      return camera(p + movingNoise(p)-.5);
    }


    void main() {
      vec2 p = position * scale;
      gl_FragColor = display(fractalNoise(p));
    }

</div>
</div>

<div class="shader-temp">
<div class="shown">

    float movingNoise(vec2 p) {
      float total = 0.0;
      total += smoothNoise(p     - time);
      total += smoothNoise(p*2.  + time) / 2.;
      total += smoothNoise(p*4.  - time) / 4.;
      total += smoothNoise(p*8.  + time) / 8.;
      total += smoothNoise(p*16. - time) / 16.;
      total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
      return total;
    }

</div>
<div class="code">

    precision mediump float;

    varying vec2 position;
    uniform float time;
    uniform sampler2D webcam;


    float scale = 6.;
    vec4 camera(vec2 p) {
      return texture2D(webcam, p / scale);
    }
    vec4 display(float color) {return vec4(vec3(color), 1.);}
    vec4 display(vec4  color) {return color;}


    float random(float p) {
      return fract(sin(p)*10000.);
    }
    float noise(vec2 p) {
      return random(p.x + p.y*10000.);
    }


    float stepNoise(vec2 p) {
      return noise(floor(p));
    }


    vec2 sw(vec2 p) {return vec2( floor(p.x) , floor(p.y) );}
    vec2 se(vec2 p) {return vec2( ceil(p.x)  , floor(p.y) );}
    vec2 nw(vec2 p) {return vec2( floor(p.x) , ceil(p.y)  );}
    vec2 ne(vec2 p) {return vec2( ceil(p.x)  , ceil(p.y)  );}

    float smoothNoise(vec2 p) {
      vec2 inter = smoothstep(0., 1., fract(p));
      float s = mix(noise(sw(p)), noise(se(p)), inter.x);
      float n = mix(noise(nw(p)), noise(ne(p)), inter.x);
      return mix(s, n, inter.y);
      return noise(nw(p));
    }


    float fractalNoise(vec2 p) {
      float total = 0.0;
      total += smoothNoise(p);
      total += smoothNoise(p*2.) / 2.;
      total += smoothNoise(p*4.) / 4.;
      total += smoothNoise(p*8.) / 8.;
      total += smoothNoise(p*16.) / 16.;
      total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
      return total;
    }


    float movingNoise(vec2 p) {
      float total = 0.0;
      total += smoothNoise(p     - time);
      total += smoothNoise(p*2.  + time) / 2.;
      total += smoothNoise(p*4.  - time) / 4.;
      total += smoothNoise(p*8.  + time) / 8.;
      total += smoothNoise(p*16. - time) / 16.;
      total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
      return total;
    }


    float nestedNoise(vec2 p) {
      float x = movingNoise(p);
      float y = movingNoise(p + 100.);
      return movingNoise(p + vec2(x, y));
    }


    vec4 distort(vec2 p) {
      return camera(p + movingNoise(p)-.5);
    }


    void main() {
      vec2 p = position * scale;
      gl_FragColor = display(movingNoise(p));
    }

</div>
</div>

<div class="shader-temp">
<div class="shown">

    float nestedNoise(vec2 p) {
      float x = movingNoise(p);
      float y = movingNoise(p + 100.);
      return movingNoise(p + vec2(x, y));
    }

</div>
<div class="code">

    precision mediump float;

    varying vec2 position;
    uniform float time;
    uniform sampler2D webcam;


    float scale = 6.;
    vec4 camera(vec2 p) {
      return texture2D(webcam, p / scale);
    }
    vec4 display(float color) {return vec4(vec3(color), 1.);}
    vec4 display(vec4  color) {return color;}


    float random(float p) {
      return fract(sin(p)*10000.);
    }
    float noise(vec2 p) {
      return random(p.x + p.y*10000.);
    }


    float stepNoise(vec2 p) {
      return noise(floor(p));
    }


    vec2 sw(vec2 p) {return vec2( floor(p.x) , floor(p.y) );}
    vec2 se(vec2 p) {return vec2( ceil(p.x)  , floor(p.y) );}
    vec2 nw(vec2 p) {return vec2( floor(p.x) , ceil(p.y)  );}
    vec2 ne(vec2 p) {return vec2( ceil(p.x)  , ceil(p.y)  );}

    float smoothNoise(vec2 p) {
      vec2 inter = smoothstep(0., 1., fract(p));
      float s = mix(noise(sw(p)), noise(se(p)), inter.x);
      float n = mix(noise(nw(p)), noise(ne(p)), inter.x);
      return mix(s, n, inter.y);
      return noise(nw(p));
    }


    float fractalNoise(vec2 p) {
      float total = 0.0;
      total += smoothNoise(p);
      total += smoothNoise(p*2.) / 2.;
      total += smoothNoise(p*4.) / 4.;
      total += smoothNoise(p*8.) / 8.;
      total += smoothNoise(p*16.) / 16.;
      total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
      return total;
    }


    float movingNoise(vec2 p) {
      float total = 0.0;
      total += smoothNoise(p     - time);
      total += smoothNoise(p*2.  + time) / 2.;
      total += smoothNoise(p*4.  - time) / 4.;
      total += smoothNoise(p*8.  + time) / 8.;
      total += smoothNoise(p*16. - time) / 16.;
      total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
      return total;
    }


    float nestedNoise(vec2 p) {
      float x = movingNoise(p);
      float y = movingNoise(p + 100.);
      return movingNoise(p + vec2(x, y));
    }


    vec4 distort(vec2 p) {
      return camera(p + movingNoise(p)-.5);
    }


    void main() {
      vec2 p = position * scale;
      gl_FragColor = display(nestedNoise(p));
    }

</div>
</div>

<div class="shader-temp">
<div class="shown">

    vec4 distort(vec2 p) {
      return camera(p + movingNoise(p)-.5);
    }

</div>
<div class="code">

    precision mediump float;

    varying vec2 position;
    uniform float time;
    uniform sampler2D webcam;


    float scale = 6.;
    vec4 camera(vec2 p) {
      return texture2D(webcam, p / scale);
    }
    vec4 display(float color) {return vec4(vec3(color), 1.);}
    vec4 display(vec4  color) {return color;}


    float random(float p) {
      return fract(sin(p)*10000.);
    }
    float noise(vec2 p) {
      return random(p.x + p.y*10000.);
    }


    float stepNoise(vec2 p) {
      return noise(floor(p));
    }


    vec2 sw(vec2 p) {return vec2( floor(p.x) , floor(p.y) );}
    vec2 se(vec2 p) {return vec2( ceil(p.x)  , floor(p.y) );}
    vec2 nw(vec2 p) {return vec2( floor(p.x) , ceil(p.y)  );}
    vec2 ne(vec2 p) {return vec2( ceil(p.x)  , ceil(p.y)  );}

    float smoothNoise(vec2 p) {
      vec2 inter = smoothstep(0., 1., fract(p));
      float s = mix(noise(sw(p)), noise(se(p)), inter.x);
      float n = mix(noise(nw(p)), noise(ne(p)), inter.x);
      return mix(s, n, inter.y);
      return noise(nw(p));
    }


    float fractalNoise(vec2 p) {
      float total = 0.0;
      total += smoothNoise(p);
      total += smoothNoise(p*2.) / 2.;
      total += smoothNoise(p*4.) / 4.;
      total += smoothNoise(p*8.) / 8.;
      total += smoothNoise(p*16.) / 16.;
      total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
      return total;
    }


    float movingNoise(vec2 p) {
      float total = 0.0;
      total += smoothNoise(p     - time);
      total += smoothNoise(p*2.  + time) / 2.;
      total += smoothNoise(p*4.  - time) / 4.;
      total += smoothNoise(p*8.  + time) / 8.;
      total += smoothNoise(p*16. - time) / 16.;
      total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
      return total;
    }


    float nestedNoise(vec2 p) {
      float x = movingNoise(p);
      float y = movingNoise(p + 100.);
      return movingNoise(p + vec2(x, y));
    }


    vec4 distort(vec2 p) {
      return camera(p + movingNoise(p)-.5);
    }


    void main() {
      vec2 p = position * scale;
      gl_FragColor = display(distort(p));
    }

</div>
</div>