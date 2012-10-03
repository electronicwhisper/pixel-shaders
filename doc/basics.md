# Basics

## Colors

Let's start by writing some pixel shaders that just output a solid color.

Colors in GLSL are represented as a mixture of their red, green, and blue components, on a scale from `0.0` to `1.0`.

Colors also have an alpha component. Alpha represents how opaque (`1.0`) or transparent (`0.0`) the color is. This can be useful when you're compositing one image on top of another, but for this chapter we'll always be setting the alpha component to `1.0`--fully opaque.

<div id="exercise-colors"></div>

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

A pixel shader works by running your program *for every pixel* in the outputted image. The examples we've been working with have a resolution of 300 by 300, so that means the pixel shader gets run 900 separate times (300 times 300).

But since the same program is run 900 times, every time it runs it outputs the same color. So we just end up with solid color images.

To make the program output different colors for different pixels, we can introduce `position` which will *vary* across the image. That is, it will take on a different value depending on which pixel the shader is computing. We can use `position` to figure out the *coordinates* of our pixel and compute the appropriate color with our program.

`position.x` will range from `0.0` to `1.0` from the left to the right of our image. `position.y` will range from `0.0` to `1.0` from the bottom to the top of our image.

<div id="exercise-gradients"></div>

## Arithmetic

GLSL supports the standard arithmetic operations:

* `+` (plus)
* `-` (minus)
* `*` (times)
* `/` (divided by)

You'll also need to use parentheses to group terms. Contrast these:

* `1.0 + 1.0 * 3.0 = 4.0`
* `(1.0 + 1.0) * 3.0 = 6.0`

<div id="exercise-arithmetic"></div>