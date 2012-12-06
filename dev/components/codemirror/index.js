var codemirror = require("./codemirror");

require("./glsl")(codemirror);
require("./runmode")(codemirror);
require("./matchbrackets")(codemirror);

module.exports = codemirror;