# Basics

## Colors

Let's start by writing some pixel shaders that just output a solid color.

Colors in GLSL are represented as a mixture of their red, green, and blue components, on a scale from `0.0` to `1.0`.

Colors also have an alpha component. Alpha represents how opaque (`1.0`) or transparent (`0.0`) the color is. This can be useful when you're compositing one image on top of another, but for this chapter we'll always be setting the alpha component to `1.0`--fully opaque.

<div class="shader-exercise">
<div class="start">

    precision mediump float;

    void main() {
      gl_FragColor.r = 1.0;
      gl_FragColor.g = 0.0;
      gl_FragColor.b = 0.0;
      gl_FragColor.a = 1.0;
    }

</div>
<div class="solution">

    precision mediump float;

    void main() {
      gl_FragColor.r = 0.0;
      gl_FragColor.g = 0.0;
      gl_FragColor.b = 1.0;
      gl_FragColor.a = 1.0;
    }

</div>
<div class="solution">

    precision mediump float;

    void main() {
      gl_FragColor.r = 1.0;
      gl_FragColor.g = 1.0;
      gl_FragColor.b = 0.0;
      gl_FragColor.a = 1.0;
    }

</div>
<div class="solution">

    precision mediump float;

    void main() {
      gl_FragColor.r = 1.0;
      gl_FragColor.g = 0.5;
      gl_FragColor.b = 0.0;
      gl_FragColor.a = 1.0;
    }

</div>
</div>

## Numbers

You'll notice that I always write my numbers with a decimal point. That is, instead of just writing `0` and `1`, I write `0.0` and `1.0`.

GLSL treats numbers that are written with a decimal point differently than numbers written without one. Numbers with a decimal point are called `float`s and numbers without a decimal point are called `int`s.

Here are a few examples of `float`s:

* `3.14`
* `0.5` (same as `.5`)
* `1.` (same as `1.0`)
* `0.` (same as `.0` or `0.0`)

Here are a few examples of `int`s:

* `33`
* `1`
* `0`

If you type in a `float` where GLSL is expecting an `int`, or vice versa, it will give an error.

As we saw with the colors, GLSL tends to represent values in fractional amounts, usually on a scale of `0.0` to `1.0`. So we'll mostly be seeing `float`s in this book.

## Gradients

We've seen how to make solid colors, but how do we make more interesting images--images with variation?

A pixel shader works by running your program *for every pixel* in the outputted image. The examples we've been working with have a resolution of 300 by 300, so that means the pixel shader gets run 90,000 separate times (300 times 300).

But since the same program is run 90,000 times, every time it runs it outputs the same color. So we just end up with solid color images.

To make the program output different colors for different pixels, we can introduce `position` which will *vary* across the image. That is, it will take on a different value depending on which pixel the shader is computing. We can use `position` to figure out the *coordinates* of our pixel and compute the appropriate color with our program.

`position.x` will range from `0.0` to `1.0` from the left to the right of our image. `position.y` will range from `0.0` to `1.0` from the bottom to the top of our image.

<div class="shader-exercise">
<div class="start">

    precision mediump float;

    varying vec2 position;

    void main() {
      gl_FragColor.r = position.x;
      gl_FragColor.g = 0.0;
      gl_FragColor.b = 0.0;
      gl_FragColor.a = 1.0;
    }

</div>
<div class="solution">

    precision mediump float;

    varying vec2 position;

    void main() {
      gl_FragColor.r = 0.0;
      gl_FragColor.g = 0.0;
      gl_FragColor.b = position.y;
      gl_FragColor.a = 1.0;
    }

</div>
<div class="solution">

    precision mediump float;

    varying vec2 position;

    void main() {
      gl_FragColor.r = position.x;
      gl_FragColor.g = position.x;
      gl_FragColor.b = 0.0;
      gl_FragColor.a = 1.0;
    }

</div>
<div class="solution">

    precision mediump float;

    varying vec2 position;

    void main() {
      gl_FragColor.r = position.x;
      gl_FragColor.g = 0.0;
      gl_FragColor.b = position.y;
      gl_FragColor.a = 1.0;
    }

</div>
</div>


## Arithmetic

GLSL supports the standard arithmetic operations:

* `+` (plus)

    <div class="evaluator">2.0 + 3.5</div>

* `-` (minus)

    <div class="evaluator">4.5 - 0.5</div>

* `*` (times)

    <div class="evaluator">2.0 * 4.0</div>

* `/` (divided by)

    <div class="evaluator">3.0 / 2.0</div>

You'll also need to use parentheses to group terms. Contrast these:

<div class="book-text"><div class="evaluator">3.0 * 1.0 + 1.0</div></div>

<div class="book-text"><div class="evaluator">3.0 * (1.0 + 1.0)</div></div>

<div class="shader-exercise">
<div class="start">

    precision mediump float;

    varying vec2 position;

    void main() {
      gl_FragColor.r = 1.0 - position.x;
      gl_FragColor.g = 0.0;
      gl_FragColor.b = 0.0;
      gl_FragColor.a = 1.0;
    }

</div>
<div class="solution">

    precision mediump float;

    varying vec2 position;

    void main() {
      gl_FragColor.r = 0.0;
      gl_FragColor.g = 0.0;
      gl_FragColor.b = 1.0 - position.y;
      gl_FragColor.a = 1.0;
    }

</div>
<div class="solution">

    precision mediump float;

    varying vec2 position;

    void main() {
      gl_FragColor.r = 1.0 - position.x;
      gl_FragColor.g = 0.0;
      gl_FragColor.b = position.x;
      gl_FragColor.a = 1.0;
    }

</div>
<div class="solution">

    precision mediump float;

    varying vec2 position;

    void main() {
      gl_FragColor.r = (position.x + position.y) / 2.0;
      gl_FragColor.g = 0.0;
      gl_FragColor.b = 0.0;
      gl_FragColor.a = 1.0;
    }

</div>
<div class="solution">

    precision mediump float;

    varying vec2 position;

    void main() {
      gl_FragColor.r = (position.x + 1.0 - position.y) / 2.0;
      gl_FragColor.g = 0.0;
      gl_FragColor.b = 0.0;
      gl_FragColor.a = 1.0;
    }

</div>
</div>


## Time

We've seen how to make static images with our shaders, but how do we make animated images--images that change over time?

We can introduce `time` which will be a number representing the amount of time, in seconds, that our shader has been running.

For example:

<div class="shader-example">

    precision mediump float;

    uniform float time;

    void main() {
      gl_FragColor.r = time;
      gl_FragColor.g = 0.0;
      gl_FragColor.b = 0.0;
      gl_FragColor.a = 1.0;
    }

</div>

You'll need to hit the ** button on the above to reset `time` to `0.0`. Once `time` goes above `1.0`--which only takes a second--the shader is fully red. Remember, if we set any color to a value above `1.0`, the color maxes out. The shader just treats it as `1.0`--it can't get redder than fully red.

Say we wanted to make the shader take 15 seconds to become fully red instead of 1 second. Can we do that with some arithmetic?

<div class="shader-exercise">
<div class="start">

    precision mediump float;

    uniform float time;

    void main() {
      gl_FragColor.r = time;
      gl_FragColor.g = 0.;
      gl_FragColor.b = 0.;
      gl_FragColor.a = 1.;
    }

</div>
<div class="solution">

    precision mediump float;

    uniform float time;

    void main() {
      gl_FragColor.r = time / 15.;
      gl_FragColor.g = 0.;
      gl_FragColor.b = 0.;
      gl_FragColor.a = 1.;
    }

</div>
</div>

Here's how I think about the above problem. I know the red value can only range between `0.` and `1.`. But I want the time range from `0.` to `15.` to *map* to this `0.` to `1.` range. So, I want:

<table>
  <tr><th>Time</th><th>Redness</th></tr>
  <tr><td>at `0.` seconds</td><td>`0.`</td></tr>
  <tr><td>at `15.` seconds</td><td>`1.`</td></tr>
</table>

So to do this, I'm going to take `time` and divide it by `15.`.

<div class="shader-example">

    precision mediump float;

    uniform float time;

    void main() {
      gl_FragColor.r = time / 15.;
      gl_FragColor.g = 0.;
      gl_FragColor.b = 0.;
      gl_FragColor.a = 1.;
    }

</div>

<div class="shader-exercise">
<div class="start">

    precision mediump float;

    uniform float time;

    void main() {
      gl_FragColor.r = time;
      gl_FragColor.g = 0.;
      gl_FragColor.b = 0.;
      gl_FragColor.a = 1.;
    }

</div>
<div class="solution">

    precision mediump float;

    uniform float time;

    void main() {
      gl_FragColor.r = 1. - time;
      gl_FragColor.g = 0.;
      gl_FragColor.b = 0.;
      gl_FragColor.a = 1.;
    }

</div>
</div>


## Repeating

Now say we want our animation to repeat over and over again. For example we want it to go from black to red and then black to red, over and over again.

We can't do this with our basic arithmetic operations.
