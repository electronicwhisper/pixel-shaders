/**
 * Wrapped logging function.
 * @param {string} msg The message to log.
 */
var error = function(msg) {
  if (window.console) {
    if (window.console.error) {
      window.console.error(msg);
    }
    else if (window.console.log) {
      window.console.log(msg);
    }
  }
};


/**
 * Loads a shader.
 * @param {!WebGLContext} gl The WebGLContext to use.
 * @param {string} shaderSource The shader source.
 * @param {number} shaderType The type of shader.
 * @param {function(string): void) opt_errorCallback callback for errors.
 * @return {!WebGLShader} The created shader.
 */
// var loadShader = function(gl, shaderSource, shaderType, opt_errorCallback) {
//   var errFn = opt_errorCallback || error;
//   // Create the shader object
//   var shader = gl.createShader(shaderType);
// 
//   // Load the shader source
//   gl.shaderSource(shader, shaderSource);
// 
//   // Compile the shader
//   gl.compileShader(shader);
// 
//   // Check the compile status
//   var compiled = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
//   if (!compiled) {
//     // Something went wrong during compilation; get the error
//     lastError = gl.getShaderInfoLog(shader);
//     errFn("*** Error compiling shader '" + shader + "':" + lastError);
//     gl.deleteShader(shader);
//     return null;
//   }
// 
//   return shader;
// }

/**
 * Creates a program, attaches shaders, binds attrib locations, links the
 * program and calls useProgram.
 * @param {!Array.<!WebGLShader>} shaders The shaders to attach
 * @param {!Array.<string>} opt_attribs The attribs names.
 * @param {!Array.<number>} opt_locations The locations for the attribs.
 */
var createProgram = function(gl, shaders, opt_attribs, opt_locations) {
  var program = gl.createProgram();
  for (var ii = 0; ii < shaders.length; ++ii) {
    gl.attachShader(program, shaders[ii]);
  }
  if (opt_attribs) {
    for (var ii = 0; ii < opt_attribs.length; ++ii) {
      gl.bindAttribLocation(
          program,
          opt_locations ? opt_locations[ii] : ii,
          opt_attribs[ii]);
    }
  }
  gl.linkProgram(program);

  // Check the link status
  var linked = gl.getProgramParameter(program, gl.LINK_STATUS);
  if (!linked) {
      // something went wrong with the link
      lastError = gl.getProgramInfoLog (program);
      error("Error in program linking:" + lastError);

      gl.deleteProgram(program);
      return null;
  }
  return program;
};
