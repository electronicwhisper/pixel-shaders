# Working with Functions

## `abs`

In addition to arithmetic operations, GLSL has several built-in mathematical *functions* that are very useful.

We'll start with `abs` which takes the *absolute value* of a number. It takes negative numbers to the positive version of the number and leaves positive numbers the same.

<div class="evaluator">abs(-1.5)</div>

<div class="evaluator">abs(4.2)</div>

<div class="evaluator">abs(0.0)</div>

Notice how we write `abs` followed by parentheses with the *parameter* (the number we want to take the absolute value of) inside. This is how we apply functions in GLSL.

Here is a line graph of `abs`:

<div class="graph-example">abs(x)</div>

In the above graph, `x` ranges horizontally and the value of the *expression*, in this case `abs(x)`, ranges vertically.

Graphs are helpful for visualizing functions so we'll be using them a lot. Here are a few other examples of graphs:

<div class="graph-example">x</div>

<div class="graph-example">2. * x - 1.</div>

<!-- <div class="graph-example">-abs(x)</div> -->

The following exercises all use `abs` to create different graphs.

<div class="graph-exercise">
  <div class="start">abs(x)</div>
  <div class="solution">abs(x) - 1.0</div>
  <div class="solution">abs(x - 0.5)</div>
  <div class="solution">abs(x - 0.5) * 2.0</div>
  <div class="solution">1.0 - abs(x - 0.5) * 2.0</div>
</div>

Now let's try using `abs` in shaders.

<div class="shader-exercise">
<div class="start">

    precision mediump float;

    varying vec2 position;

    void main() {
      gl_FragColor.r = abs(position.x);
      gl_FragColor.g = 0.0;
      gl_FragColor.b = 0.0;
      gl_FragColor.a = 1.0;
    }

</div>
<div class="solution">

    precision mediump float;

    varying vec2 position;

    void main() {
      gl_FragColor.r = abs(position.x - 0.5);
      gl_FragColor.g = 0.0;
      gl_FragColor.b = 0.0;
      gl_FragColor.a = 1.0;
    }

</div>
<div class="solution">

    precision mediump float;

    varying vec2 position;

    void main() {
      gl_FragColor.r = abs(position.x - 0.5) * 2.0;
      gl_FragColor.g = 0.0;
      gl_FragColor.b = 0.0;
      gl_FragColor.a = 1.0;
    }

</div>
<div class="solution">

    precision mediump float;

    varying vec2 position;

    void main() {
      gl_FragColor.r = 1.0 - abs(position.x - 0.5) * 2.0;
      gl_FragColor.g = 0.0;
      gl_FragColor.b = 0.0;
      gl_FragColor.a = 1.0;
    }

</div>
<div class="solution">

    precision mediump float;

    varying vec2 position;

    void main() {
      gl_FragColor.r = abs(position.x - 0.5) * 2.0;
      gl_FragColor.g = 0.0;
      gl_FragColor.b = abs(position.y - 0.5) * 2.0;
      gl_FragColor.a = 1.0;
    }

</div>
</div>

In the above exercises, you sometimes needed to modify the expression *inside* the `abs` function, for example changing `abs(x)` to `abs(x - 0.5)`. This is called distorting the *domain* of the function.

You also sometimes needed to modify the expression *outside* of the function, for example changing `abs(x)` to `abs(x) - 0.5`. This is called distorting the *range* of the function.

We'll see this idea--distorting the domain and range of a function--again and again in later chapters. Look out for it!