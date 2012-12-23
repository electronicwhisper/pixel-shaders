glsl.pegjs is taken from http://code.google.com/p/glsl-unit/



All instances of `new node({` were replaced by `new node({line:line,column:column,` to keep track of where we are in the source code.

All instances of `daisy_chain(head, tail)` were replaced by `daisy_chain(head, tail, line, column)`.