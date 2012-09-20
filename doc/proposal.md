# An <span class="red">Interactive Introduction</span><br />to Graphics Programming

This is a proposal and proof-of-concept for an interactive book about programming the graphics processor.

Modern computers come with two separate processors, two "brains":

* The traditional CPU, the Central Processing Unit
* The newer GPU, the Graphics Processing Unit

Almost all books and courses about programming only teach you how to program the CPU.

GPU programming is esoteric. Learning resources are targeted at experienced programmers who need to use the GPU for applications like high-performance video games and scientific simulations.

Yet there is a unique joy to programming the graphics processor. It *feels* different than traditional programming. Traditional programs are usually quite long. The challenge is in understanding how the computer steps through the program. GPU programs are often fiendishly short. The challenge is in understanding how a simple program, when performed thousands of time in parallel, can produce a powerful effect.

This book is intended to bring the wonder and joy of graphics processor programming to a wider audience. It is targeted at artists who want to integrate powerful computer graphics into their work, and traditional programmers who want to try thinking about programming in a different way. It has no programming pre-requisites, and indeed encourages a fresh mindset--many traditional programming tactics will be ineffective.

## An Interactive Book

This book will be *interactive*. You can play with it as you read it.

The text will be extensively illustrated with *manipulable diagrams* and *live code examples*. Here's a live code example:

<div id="example-live-code"></div>

On the left you have a graphic output and on the right you have the code that produced it. But you can also change the code and the output will change dynamically, as you type. Try it out!

By experimenting with the code--by *touching* it--you can gain a much deeper understanding of how it works.

The live coding interface will also feature line-by-line evaluation and visual aids to help you understand how a program works. Here's a mockup, illustrating polar coordinates:

<div id="example-line-by-line"></div>

Try moving your mouse over the output.

The *line-by-line evaluation* on the source code shows you exactly how the color of the pixel you're on was computed.

The <span style="color: #f00">red</span> and <span style="color: #0f0">green</span> [*isolines*](http://en.wikipedia.org/wiki/Contour_line) show you where on your image a particular line of code has the same value as the pixel you're on. Just like a topographical map, isolines help you quickly understand how a value varies over the entire image.

I am extremely excited about the possibilities of interactive books in general. I hope that this book, in addition to teaching programming, will point to some future possibilities for this medium.

## Contents

The book in its initial incarnation will cover the topic of *pixel shaders*.

Pixel shaders are programs which compute a color for each pixel in an outputted image or animation. You can imagine thousands of independent computers--one in each pixel of your display--whose sole purpose is to figure out what color to be. Because each pixel needs to determine its color independently, programming pixel shaders is very different than programming graphics traditionally (as a sequence of centrally managed drawing operations).

The book will introduce the concepts of pixel shading from the ground up. Along the way, it will naturally motivate powerful concepts in mathematics and geometry. It will also explore optical phenomena and bring in ideas from contemporary visual art. Finally, it will show how pixel shaders can be integrated with other software frameworks.

Here is an in-progress table of contents for the book:

1. Introduction
    * What are pixel shaders?
    * What can you do with pixel shaders?
2. Colors
    * Gradients
    * Vector Math
    * Color Spaces, Rainbows
3. Working with Textures
    * Image Filters
    * Compositing
4. Transformations
    * Case Study: Gerhardt Richter's [Patterns](http://artnet.tumblr.com/post/29052281623/gerhard-richter-patterns-for-his-latest-project)
    * Coordinate Spaces
    * Polar Coordinates
    * Distortion
    * Displacement Maps
5. Multiple Point Sampling
    * Edge Detection
    * Blur
6. Generative Textures
    * Noise
    * Quasicrystals
    * Fractals
7. Raytracing
    * Case Study: Mirrors and Kaleidoscopes
    * 3D
8. Integrating Shaders With Other Frameworks
    * WebGL
    * Processing, openFrameworks, Jitter, Quartz Composer

## Open Source

I'd like for the entire book and all of the code in it--both example code and the code to play with the examples--to be open source. All the code and contents of the book will be hosted on GitHub. The book itself will be freely available on the web.

In addition to the book being open, I anticipate that the production of the interactive examples in the book will spawn several independent open source projects. These projects might include code to:

* Flexibly embed pixel shaders with WebGL
* Create live coding environments
* Parse and simulate GLSL in Javascript
* Create interactive diagrams
* Integrate interactive examples with lightweight markup languages (e.g. Markdown, Asciidoc)
* Render GPU output, e.g. WebGL to Animated GIF via Javascript

## New programmers.<br />New ways of programming.

Our most profound advances in computing were driven by endeavors to enable new programmers to richly interact with computers in new ways. For example, in the early 1970s, while others designed computers for engineers and businessmen, Alan Kay and his Learning Research Group at Xerox PARC believed computers could be [used and programmed by children for creative purposes](http://www.newmediareader.com/book_samples/nmr-26-kay.pdf). From this starting point, they invented object oriented programming and the modern GUI.

This book aims to challenge the traditional way we teach and learn programming. It is targeted at programmers who want to use technology primarily as a creative tool. It introduces programming with a topic normally considered advanced and esoteric, but whose importance to future computing problems is rapidly being recognized. It eschews the traditional programming challenge of designing sequences of operations and replaces it with the challenge of orchestrating thousands of deceptively simple computations to produce a powerful combined effect.

Finally, it abandons the notion of the book as a static medium. The interactions in this book will be developed in tandem with the text. They will be intimately tied in--part of the flow. Readers will be encouraged to engage with the book *actively*. 

Our learning resources should inspire *thirst*. They should make you think, "I can't get enough this!"

Like a child exploring some new, wondrous pocket of the universe, this is the feeling that I hope to inspire with this book.

**Toby Schachman**<br />[tqs@alum.mit.edu](mailto:tqs@alum.mit.edu)