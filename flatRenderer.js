(function() {
  var bufferAttribute, compileShader, fragmentShaderSource, getShaderError, makeFlatRenderer, vertexShaderSource;

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
      setUniform: function(name, value, size) {
        var location;
        location = gl.getUniformLocation(program, name);
        if (typeof value === "number") value = [value];
        if (!size) size = value.length;
        switch (size) {
          case 1:
            return gl.uniform1fv(location, value);
          case 2:
            return gl.uniform2fv(location, value);
          case 3:
            return gl.uniform3fv(location, value);
          case 4:
            return gl.uniform4fv(location, value);
        }
      },
      createTexture: function(image) {
        var texture;
        texture = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D, texture);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
        return texture;
      },
      draw: function() {
        return gl.drawArrays(gl.TRIANGLES, 0, 6);
      }
    };
  };

  window.flatRenderer = makeFlatRenderer;

}).call(this);
