# Basics

## Colors

Let's start by writing some pixel shaders that just output a solid color.

Colors in GLSL are represented as a mixture of their red, green, and blue components, on a scale from `0.0` to `1.0`.

Colors also have an alpha component. Alpha represents how opaque (`1.0`) or transparent (`0.0`) the color is. This can be useful when you're compositing one image on top of another, but for this chapter we'll always be setting the alpha component to `1.0`--fully opaque.

<div class="shader-exercise">
<div class="start">

    precision mediump float;

    varying vec2 position;

    void main() {
      gl_FragColor.r = 1.0;
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
      gl_FragColor.b = 1.0;
      gl_FragColor.a = 1.0;
    }

</div>
<div class="solution">

    precision mediump float;

    varying vec2 position;

    void main() {
      gl_FragColor.r = 1.0;
      gl_FragColor.g = 1.0;
      gl_FragColor.b = 0.0;
      gl_FragColor.a = 1.0;
    }

</div>
<div class="solution">

    precision mediump float;
  
    varying vec2 position;
  
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
* `-` (minus)
* `*` (times)
* `/` (divided by)

You'll also need to use parentheses to group terms. Contrast these:

* <div class="evaluator">1.0 + 1.0 * 3.0</div>
* <div class="evaluator">(1.0 + 1.0) * 3.0</div>

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


## Feedback

<em>
This chapter is about halfway done. If you've gotten this far, I'd love to hear your thoughts. Did it make sense? Did the exercises feel in flow with the content? How is the pacing? [Send me an email](mailto:tqs@alum.mit.edu). Thanks!

Toby
</em>