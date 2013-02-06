# Working with Functions

## `abs`

In addition to arithmetic operations, GLSL has several built-in mathematical *functions* that are very useful.

We'll start with `abs` which takes the *absolute value* of a number. It takes negative numbers to the positive version of the number and leaves positive numbers the same.

<div class="evaluator">abs(-2.)</div>

<div class="evaluator">abs(4.)</div>

Here is a graph of `abs`:

<div class="graph-example">abs(x)</div>

Graphs are helpful for visualizing mathematical expressions so we'll be using them a lot.

Within the text box on top is an expression based on `x`. In this case it's `abs(x)`. You can experiment by changing the expression in the text box.

On the graph to the left, `x` goes across horizontally and the result of the expression is graphed vertically. You can move your mouse over the graph to see how the evaluation is carried out (TODO).

Underneath the text box is a breakdown of the expression into sub-expressions. You can move your mouse over these sub-expressions to see their graphs.

Here are a few variations using `abs`. Explore them by changing them and moving your mouse over them to understand how they work.

<div class="graph-example">abs(x) + 1.</div>

<div class="graph-example">abs(x + 1.)</div>

<div class="graph-example">abs(x) * 2.</div>

<div class="graph-example">1. - abs(x) * 2.</div>

Notice how we use arithmetic operations to *transform* the basic `abs(x)` graph.

We sometimes do arithmetic *inside* the function, for example `abs(x + 1.)`, and sometimes *outside* the function, for example `abs(x) + 1.`. Doing operations inside the function is called distorting the *domain* and doing operations outside the function is called distorting the *range*.

We'll see this idea--distorting the domain and range of a function--again and again in the following exercises and later chapters. Look out for it!

Transform `abs(x)` to construct the red graphs:

<div class="graph-exercise">
  <div class="start">abs(x)</div>
  <div class="solution">abs(x) - 1.0</div>
  <div class="solution">abs(x - 0.5)</div>
  <div class="solution">abs(x - 0.5) * 2.0</div>
  <div class="solution">1.0 - abs(x - 0.5) * 2.0</div>
</div>

Now let's try using `abs` in shaders:

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