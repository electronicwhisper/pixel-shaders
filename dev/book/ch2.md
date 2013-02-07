# Working with Functions

## `abs`

In addition to arithmetic operations, GLSL has several built-in mathematical *functions* that are very useful.

We'll start with `abs` which takes the *absolute value* of a number. It takes negative numbers to the positive version of the number and leaves positive numbers the same. For example:

<div class="evaluator">abs(-2.)</div>

<div class="evaluator">abs(4.)</div>

Here is a graph of `abs`:

<div style="padding-top: 60px">
<div class="graph-example">abs(x)
<div class="explain" select=".book-editor" position="north">
An expression based on `x`, in this case `abs(x)`.

Experiment by changing this!
</div>
<div class="explain" select=".deconstruct li:first" position="north east">A breakdown of the expression into sub-expressions.

Move your mouse over these to see their graphs.</div>
<div class="explain" select=".left canvas" position="south">On this graph, `x` goes across horizontally and the result of the expression `abs(x)` is graphed vertically.

Move your mouse over the graph to see how the evaluation is carried out (TODO).</div>
</div>
</div>

The purpose of a graph is to visualize a mathematical expression. Further, we want to mentally connect the *visual* representation (graph) and the *symbolic* representation (code).

Compare the graphs for `x` and `abs(x)`. Notice how `abs` "flips" negative values to be positive.

Here are a few variations using `abs` and arithmetic. Move your mouse over the sub-expressions to understand how they work or experiment by changing them.

<div class="graph-example">abs(x) + 1.</div>

<div class="graph-example">abs(x + 1.)</div>

<div class="graph-example">abs(x) * 2.</div>

<div class="graph-example">1. - abs(x) * 2.</div>

Notice how we use arithmetic operations to *transform* the basic `abs(x)` graph.

We sometimes do arithmetic *inside* the function, for example `abs(x + 1.)`, and sometimes *outside* the function, for example `abs(x) + 1.`. Doing operations inside the function is called transforming the *domain* and doing operations outside the function is called transforming the *range*.

Transforming the domain and range of a function--or both--is a powerful technique. We'll see it again and again in the following exercises and later chapters. Look out for it!

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

