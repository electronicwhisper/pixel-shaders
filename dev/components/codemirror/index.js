var codemirror = require("./codemirror");

require("./glsl")(codemirror);
require("./runmode")(codemirror);

module.exports = codemirror;