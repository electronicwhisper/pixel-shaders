# Tranforms,<br />Inverse Transforms,<br />and Glitch

When you do a transform and follow it with its inverse transform, nothing happens. That is, you get the *identity* transform, by definition.

Here's an example. I'm going to transform cartesian coordinates into polar coordinates, and then do the inverse transform:

<div class="book-shader">
precision mediump float;

varying vec2 position;
uniform sampler2D webcam;

void main() {
  // starting with position in cartesian coordinates
  vec2 p = position;
  
  // convert cartesian to polar
  float radius = length(p-0.5);
  float angle = atan(p.y-0.5, p.x-0.5);
  
  // convert polar to cartesian
  float x = cos(angle)*radius+0.5;
  float y = sin(angle)*radius+0.5;
  p = vec2(x, y);
  
  gl_FragColor = texture2D(webcam, p);
}
</div>

However, when you make a change *in between* the transform and its inverse--when you *glitch* that particular identity--you get interesting results which reveal the nature of the transform and its inverse. Here's an example:

<div class="book-shader">
precision mediump float;

varying vec2 position;
uniform sampler2D webcam;

void main() {
  // starting with position in cartesian coordinates
  vec2 p = position;
  
  // convert cartesian to polar
  float radius = length(p-0.5);
  float angle = atan(p.y-0.5, p.x-0.5);
  
  // "glitch" it in between the transform and its inverse
  // try other glitches!
  radius = radius - 0.2;
  
  // convert polar to cartesian
  float x = cos(angle)*radius+0.5;
  float y = sin(angle)*radius+0.5;
  p = vec2(x, y);
  
  gl_FragColor = texture2D(webcam, p);
}
</div>

## Identity Bending

My hypothesis is that glitch art is centered on exploring the nature of identity transformations in our world.

For example, when we take a digital photo, we point a camera at the world, and the camera transforms what it sees into a digital artifact (say, a JPEG file). When we view a digital photo, we do the inverse transform: our computer transforms the digital artifact into lit up pixels which we can look at. In a way, this process aims to be an identity transformation, bringing the space-time captured by the photograph faithfully to the space-time when the photograph is viewed. However, we can glitch this process--say by mangling the bits of the JPEG. In doing so, we reveal something about the nature of this "identity", and the technologies we use to transmit information "faithfully".

Data bending a JPEG:

<a href="http://www.flickr.com/photos/71156563@N00/4464020133/"><img src="http://farm5.staticflickr.com/4012/4464020133_75253b99fc_z.jpg?zz=1" /></a>

Circuit bending a digital camera, by Phil Stearns:

<a href="http://yearoftheglitch.tumblr.com/post/34633766095/302-of-366-dcp-0028-made-using-a-prepared-kodak"><img src="http://24.media.tumblr.com/tumblr_mch1o761jg1r9uwqao1_1280.jpg" /></a>

## Iterated Identity

Another form of glitch art takes what are supposed to be identities, then applies them many times to magnify the subtle distortions of the identity.

Applying JPEG compression 275 times, by Benjamin Baker-Smith:

<a href="https://secure.flickr.com/photos/37634994@N05/3471426989/"><img src="https://farm4.staticflickr.com/3589/3471426989_53e2a70b2e_z.jpg?zz=1" /></a>

Google "Search by Image" applied recursively, by Sebastian Schmieg:

<iframe src="http://player.vimeo.com/video/34949864?title=0&amp;byline=0&amp;portrait=0&amp;badge=0" width="540" height="405" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>

An analog of this in sound is Alvin Lucier's ["I am Sitting in a Room"](http://www.ubu.com/sound/lucier.html) (1969).

Most these examples were pulled from Kyle McDonald's [class notes on Glitch](https://github.com/kylemcdonald/AppropriatingNewTechnologies/wiki/Week-4).