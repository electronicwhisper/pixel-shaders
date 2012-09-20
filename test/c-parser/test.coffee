parser = require("./glsl").parser

# input = """
# float ee = 3.0;
# """

# input = "3 + 6"

input = "void main () {float x = 4;}"

console.log parser.parse(input)