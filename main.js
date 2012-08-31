(function() {
  var canvas, cm, compileShader, draw, fragmentShaderSource, getShaderError, gl, makePixelShader, ps, vertexShaderSource;

  vertexShaderSource = "precision mediump float;\n\nattribute vec2 a_position;\nattribute vec2 a_texCoord;\nvarying vec2 v_texCoord;\n\nvoid main() {\n  gl_Position = vec4(a_position, 0, 1);\n  v_texCoord = a_texCoord;\n}";

  fragmentShaderSource = "precision mediump float;\n\nvarying vec2 v_texCoord;\nvoid main() {\n  gl_FragColor = vec4(v_texCoord,0,1);\n}";

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

  makePixelShader = function(gl) {
    var buffer, fragmentShader, positionLocation, program, texCoordBuffer, texCoordLocation, vertexShader;
    vertexShader = compileShader(gl, vertexShaderSource, gl.VERTEX_SHADER);
    fragmentShader = compileShader(gl, fragmentShaderSource, gl.FRAGMENT_SHADER);
    program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    gl.useProgram(program);
    texCoordLocation = gl.getAttribLocation(program, "a_texCoord");
    texCoordBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, texCoordBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0]), gl.STATIC_DRAW);
    gl.enableVertexAttribArray(texCoordLocation);
    gl.vertexAttribPointer(texCoordLocation, 2, gl.FLOAT, false, 0, 0);
    positionLocation = gl.getAttribLocation(program, "a_position");
    buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1.0, -1.0, 1.0, -1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0, 1.0, 1.0]), gl.STATIC_DRAW);
    gl.enableVertexAttribArray(positionLocation);
    gl.vertexAttribPointer(positionLocation, 2, gl.FLOAT, false, 0, 0);
    return {
      loadFragmentShader: function(source) {
        var err, shader;
        shader = compileShader(gl, source, gl.FRAGMENT_SHADER);
        err = getShaderError(gl, shader);
        if (err) {
          return err;
        } else {
          gl.detachShader(program, fragmentShader);
          gl.deleteShader(fragmentShader);
          fragmentShader = shader;
          gl.attachShader(program, fragmentShader);
          return null;
        }
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

  gl = canvas.getContext("experimental-webgl");

  ps = makePixelShader(gl);

  draw = function() {
    var err;
    err = ps.loadFragmentShader(cm.getValue());
    if (err) {
      return document.getElementById("status").innerHTML = err;
    } else {
      document.getElementById("status").innerHTML = "";
      ps.link();
      return ps.draw();
    }
  };

  cm = CodeMirror(document.getElementById("rasterCode"), {
    value: fragmentShaderSource,
    mode: "text/x-glsl",
    onChange: draw
  });

  draw();

}).call(this);
