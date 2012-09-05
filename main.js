(function() {
  var bufferAttribute, canvas, cm, compileShader, draw, errorLines, fragmentShaderSource, getShaderError, gl, makeFlatRenderer, parseShaderError, renderer, vertexShaderSource;

  vertexShaderSource = "precision mediump float;\n\nattribute vec3 vertexPosition;\nvarying vec2 position;\n\nvoid main() {\n  gl_Position = vec4(vertexPosition, 1.0);\n  position = (vertexPosition.xy + 1.0) * 0.5;\n}";

  fragmentShaderSource = "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor = vec4(1, 0, 0, 1);\n}";

  compileShader = function(gl, shaderSource, shaderType) {
    var shader;
    shader = gl.createShader(shaderType);
    gl.shaderSource(shader, shaderSource);
    gl.compileShader(shader);
    return shader;
  };

  getShaderError = function(gl, shader) {
    var compiled;
    compiled = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (!compiled) {
      return gl.getShaderInfoLog(shader);
    } else {
      return null;
    }
  };

  bufferAttribute = function(gl, program, attrib, data, size) {
    var buffer, location;
    if (size == null) size = 2;
    location = gl.getAttribLocation(program, attrib);
    buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(data), gl.STATIC_DRAW);
    gl.enableVertexAttribArray(location);
    return gl.vertexAttribPointer(location, size, gl.FLOAT, false, 0, 0);
  };

  parseShaderError = function(error) {
    var index, indexEnd, lineError, lineNum, parsed;
    while ((error.length > 1) && (error.charCodeAt(error.length - 1) < 32)) {
      error = error.substring(0, error.length - 1);
    }
    parsed = [];
    index = 0;
    while (index >= 0) {
      index = error.indexOf("ERROR: 0:", index);
      if (index < 0) break;
      index += 9;
      indexEnd = error.indexOf(':', index);
      if (indexEnd > index) {
        lineNum = parseInt(error.substring(index, indexEnd));
        index = indexEnd + 1;
        indexEnd = error.indexOf("ERROR: 0:", index);
        lineError = indexEnd > index ? error.substring(index, indexEnd) : error.substring(index);
        parsed.push({
          lineNum: lineNum,
          error: lineError
        });
      }
    }
    return parsed;
  };

  makeFlatRenderer = function(gl) {
    var program, replaceShader, shaders;
    program = gl.createProgram();
    shaders = {};
    shaders[gl.VERTEX_SHADER] = compileShader(gl, vertexShaderSource, gl.VERTEX_SHADER);
    shaders[gl.FRAGMENT_SHADER] = compileShader(gl, fragmentShaderSource, gl.FRAGMENT_SHADER);
    gl.attachShader(program, shaders[gl.VERTEX_SHADER]);
    gl.attachShader(program, shaders[gl.FRAGMENT_SHADER]);
    gl.linkProgram(program);
    gl.useProgram(program);
    bufferAttribute(gl, program, "vertexPosition", [-1.0, -1.0, 1.0, -1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0, 1.0, 1.0]);
    replaceShader = function(shaderSource, shaderType) {
      var err, shader;
      shader = compileShader(gl, shaderSource, shaderType);
      err = getShaderError(gl, shader);
      if (err) {
        gl.deleteShader(shader);
        return err;
      } else {
        gl.detachShader(program, shaders[shaderType]);
        gl.deleteShader(shaders[shaderType]);
        gl.attachShader(program, shader);
        shaders[shaderType] = shader;
        return null;
      }
    };
    return {
      loadFragmentShader: function(shaderSource) {
        return replaceShader(shaderSource, gl.FRAGMENT_SHADER);
      },
      link: function() {
        gl.linkProgram(program);
        return null;
      },
      draw: function() {
        return gl.drawArrays(gl.TRIANGLES, 0, 6);
      }
    };
  };

  canvas = document.getElementById("canvas");

  gl = canvas.getContext("experimental-webgl", {
    premultipliedAlpha: false
  });

  renderer = makeFlatRenderer(gl);

  errorLines = [];

  draw = function() {
    var err, error, errors, line, _i, _j, _len, _len2, _results;
    for (_i = 0, _len = errorLines.length; _i < _len; _i++) {
      line = errorLines[_i];
      cm.setLineClass(line, null, null);
      cm.clearMarker(line);
    }
    errorLines = [];
    err = renderer.loadFragmentShader(cm.getValue());
    if (err) {
      errors = parseShaderError(err);
      _results = [];
      for (_j = 0, _len2 = errors.length; _j < _len2; _j++) {
        error = errors[_j];
        line = cm.getLineHandle(error.lineNum - 1);
        errorLines.push(line);
        cm.setLineClass(line, null, "errorLine");
        _results.push(cm.setMarker(line, "%N%", "errorMarker"));
      }
      return _results;
    } else {
      document.getElementById("status").innerHTML = "";
      renderer.link();
      return renderer.draw();
    }
  };

  cm = CodeMirror(document.getElementById("rasterCode"), {
    value: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = position.x;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = 0.0;\n  gl_FragColor.a = 1.0;\n}",
    mode: "text/x-glsl",
    lineNumbers: true,
    onChange: draw
  });

  draw();

}).call(this);
