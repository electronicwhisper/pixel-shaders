<div class="prompt-webcam capture-webcam">
  <div style="position: absolute; left: 372px; font-size: 42px; margin-top: -63px; top: 50vh;">
  Examples in this chapter use the webcam.<br>
  Please allow access above. Thanks!
  </div>
</div>

<div class="book-shader-manual" style="width: 100vw; height: 100vh; position: relative; top: -96px; left: -372px;">
<div class="output" style="position: absolute; top: 0px; left: 0px; right: 0px; bottom: 0px;"></div>
<div class="code" style="display: none">
precision mediump float;

varying vec2 position;
uniform sampler2D webcam;

void main() {
  vec4 color = texture2D(webcam, position);
  gl_FragColor = color;
}
</div>
<h1 style="position: absolute; left: 372px; top: 50vh; color: #fff; font-size: 96px; line-height: 200px; margin-top: -100px; text-shadow: 0px 0px 8px rgba(0,0,0,0.9), 0px 4px 2px rgba(0, 0, 0, 0.8);">
Sampling
</h1>
</div>

In this chapter we'll learn how to *sample* colors from input images. We'll be sampling from the live webcam video.

For historical reasons, input images are called *textures*, because in 3D applications they're usually used as textures for 3D objects.

Here's a shader which simply draws the current webcam image to the screen.

<div class="book-shader">
precision mediump float;

varying vec2 position;
uniform sampler2D webcam;

void main() {
  vec4 color = texture2D(webcam, position);
  gl_FragColor.r = color.r;
  gl_FragColor.g = color.g;
  gl_FragColor.b = color.b;
  gl_FragColor.a = 1.;
}
</div>

Here's what's new:

    uniform sampler2D webcam;

This declares that we'll be grabbing from the webcam.

    vec4 color = texture2D(webcam, position)

This samples from the webcam at the current position and puts the result into `color`.

    gl_FragColor.r = color.r;
    gl_FragColor.g = color.g;
    gl_FragColor.b = color.b;

We then set `gl_FragColor` (our output color) based on `color` (our webcam color).

(We'll learn more details about `uniform sampler2D` and `texture2D` in later chapters.)

In the next example, we're only setting the output's red color to the webcam's red color, and we're setting the output's green and blue to `0.`.

<div class="book-exercise">
<div class="book-workspace">
precision mediump float;

varying vec2 position;
uniform sampler2D webcam;

void main() {
  vec4 color = texture2D(webcam, position);
  gl_FragColor.r = color.r;
  gl_FragColor.g = 0.;
  gl_FragColor.b = 0.;
  gl_FragColor.a = 1.;
}
</div>
<div class="book-solution">
precision mediump float;

varying vec2 position;
uniform sampler2D webcam;

void main() {
  vec4 color = texture2D(webcam, position);
  gl_FragColor.r = 0.;
  gl_FragColor.g = color.g;
  gl_FragColor.b = 0.;
  gl_FragColor.a = 1.;
}
</div>
<div class="book-solution">
precision mediump float;

varying vec2 position;
uniform sampler2D webcam;

void main() {
  vec4 color = texture2D(webcam, position);
  gl_FragColor.r = 0.;
  gl_FragColor.g = 0.;
  gl_FragColor.b = color.b;
  gl_FragColor.a = 1.;
}
</div>
<div class="book-solution">
precision mediump float;

varying vec2 position;
uniform sampler2D webcam;

void main() {
  vec4 color = texture2D(webcam, position);
  gl_FragColor.r = color.r;
  gl_FragColor.g = 0.;
  gl_FragColor.b = color.b;
  gl_FragColor.a = 1.;
}
</div>
</div>


## Inverting Colors

Remember that a color value ranges between `0.` and `1.`. So we can *invert* or flip a color value by subtracing it from `1.`.

<div class="book-exercise">
<div class="book-workspace">
precision mediump float;

varying vec2 position;
uniform sampler2D webcam;

void main() {
  vec4 color = texture2D(webcam, position);
  gl_FragColor.r = 1. - color.r;
  gl_FragColor.g = 0.;
  gl_FragColor.b = 0.;
  gl_FragColor.a = 1.;
}
</div>
<div class="book-solution">
precision mediump float;

varying vec2 position;
uniform sampler2D webcam;

void main() {
  vec4 color = texture2D(webcam, position);
  gl_FragColor.r = 0.;
  gl_FragColor.g = 0.;
  gl_FragColor.b = 1. - color.b;
  gl_FragColor.a = 1.;
}
</div>
<div class="book-solution">
precision mediump float;

varying vec2 position;
uniform sampler2D webcam;

void main() {
  vec4 color = texture2D(webcam, position);
  gl_FragColor.r = 1. - color.r;
  gl_FragColor.g = 1. - color.g;
  gl_FragColor.b = 1. - color.b;
  gl_FragColor.a = 1.;
}
</div>
<div class="book-solution">
precision mediump float;

varying vec2 position;
uniform sampler2D webcam;

void main() {
  vec4 color = texture2D(webcam, position);
  gl_FragColor.r = color.r;
  gl_FragColor.g = 1. - color.g;
  gl_FragColor.b = 1. - color.b;
  gl_FragColor.a = 1.;
}
</div>
</div>

## Swizzling Colors

We don't always need to have the output colors correspond to the webcam colors. We can mix things up. We can rearrange how the colors match up between input and output, or we can reuse the same input color for multiple output colors.

The graphics slang for this technique is *swizzling*.

For example in the following, the red and blue color channels are switched.

<div class="book-exercise">
<div class="book-workspace">
precision mediump float;

varying vec2 position;
uniform sampler2D webcam;

void main() {
  vec4 color = texture2D(webcam, position);
  gl_FragColor.r = color.b;
  gl_FragColor.g = color.g;
  gl_FragColor.b = color.r;
  gl_FragColor.a = 1.;
}
</div>
<div class="book-solution">
precision mediump float;

varying vec2 position;
uniform sampler2D webcam;

void main() {
  vec4 color = texture2D(webcam, position);
  gl_FragColor.r = color.g;
  gl_FragColor.g = color.r;
  gl_FragColor.b = color.b;
  gl_FragColor.a = 1.;
}
</div>
<div class="book-solution">
precision mediump float;

varying vec2 position;
uniform sampler2D webcam;

void main() {
  vec4 color = texture2D(webcam, position);
  gl_FragColor.r = color.r;
  gl_FragColor.g = color.r;
  gl_FragColor.b = color.r;
  gl_FragColor.a = 1.;
}
</div>
</div>

## Challenge

In the last chapter we learned how to make gradients by setting the color components of `gl_FragColor` based on `position`. In this chapter we learned how to set colors based on the webcam, along with inverting colors and mixing up the components.

What kind of effects can you make by combining these two ideas?

<div class="book-shader-manual capture-idle" style="width: 100vw; height: 100vh; position: relative; overflow: hidden; top: 96px; left: -372px;">
<div class="output" style="position: absolute; top: 0px; left: 0px; right: 0px; bottom: 0px;"></div>
<div class="code fade-out" style="position: absolute; width: 50vw; height: 260px; right: 24px; bottom: 24px; background-color: #fff; box-shadow: 0px 3px 3px rgba(0,0,0,0.4)">
precision mediump float;

varying vec2 position;
uniform sampler2D webcam;

void main() {
  vec4 color = texture2D(webcam, position);
  gl_FragColor.r = color.r;
  gl_FragColor.g = color.g;
  gl_FragColor.b = color.b;
  gl_FragColor.a = 1.;
}
</div>
</div>