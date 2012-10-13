
(function(/*! Stitch !*/) {
  if (!this.require) {
    var modules = {}, cache = {}, require = function(name, root) {
      var path = expand(root, name), module = cache[path], fn;
      if (module) {
        return module.exports;
      } else if (fn = modules[path] || modules[path = expand(path, './index')]) {
        module = {id: path, exports: {}};
        try {
          cache[path] = module;
          fn(module.exports, function(name) {
            return require(name, dirname(path));
          }, module);
          return module.exports;
        } catch (err) {
          delete cache[path];
          throw err;
        }
      } else {
        throw 'module \'' + name + '\' not found';
      }
    }, expand = function(root, name) {
      var results = [], parts, part;
      if (/^\.\.?(\/|$)/.test(name)) {
        parts = [root, name].join('/').split('/');
      } else {
        parts = name.split('/');
      }
      for (var i = 0, length = parts.length; i < length; i++) {
        part = parts[i];
        if (part == '..') {
          results.pop();
        } else if (part != '.' && part != '') {
          results.push(part);
        }
      }
      return results.join('/');
    }, dirname = function(path) {
      return path.split('/').slice(0, -1).join('/');
    };
    this.require = function(name) {
      return require(name, '');
    }
    this.require.define = function(bundle) {
      for (var key in bundle)
        modules[key] = bundle[key];
    };
  }
  return this.require.define;
}).call(this)({"app": function(exports, require, module) {(function() {
  var exercises, flatRenderer, simpleSrc;

  flatRenderer = require("flatRenderer");

  simpleSrc = "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = position.x;\n  gl_FragColor.g = position.y;\n  gl_FragColor.b = 1.0;\n  gl_FragColor.a = 1.0;\n}";

  exercises = [
    {
      start: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = 1.0;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = 0.0;\n  gl_FragColor.a = 1.0;\n}",
      solution: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = 0.0;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = 1.0;\n  gl_FragColor.a = 1.0;\n}"
    }, {
      solution: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = 1.0;\n  gl_FragColor.g = 1.0;\n  gl_FragColor.b = 0.0;\n  gl_FragColor.a = 1.0;\n}"
    }, {
      solution: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = 1.0;\n  gl_FragColor.g = 0.5;\n  gl_FragColor.b = 0.0;\n  gl_FragColor.a = 1.0;\n}"
    }
  ];

  module.exports = function() {
    var editor, loadExercise, makeEditor;
    editor = require("editor")({
      src: exercises[0].start,
      code: $("#code"),
      output: $("#output")
    });
    window.e = editor;
    makeEditor = require("editor")({
      src: exercises[0].solution,
      code: $("#makeCode"),
      output: $("#makeOutput")
    });
    return window.loadExercise = loadExercise = function(i) {
      var exercise;
      exercise = exercises[i];
      console.log(exercise);
      if (exercise.start) editor.set(exercise.start);
      return makeEditor.set(exercise.solution);
    };
  };

}).call(this);
}, "editor": function(exports, require, module) {(function() {
  var flatRenderer, makeEditor, startTime, util;

  flatRenderer = require("flatRenderer");

  util = require("util");

  startTime = Date.now();

  makeEditor = function(opts) {
    var $canvas, $code, $output, canvas, changeCallback, cm, ctx, draw, drawEveryFrame, editor, errorLines, findUniforms, markErrors, refreshCode, renderer, src, update;
    src = opts.src;
    $output = $(opts.output);
    $code = $(opts.code);
    $canvas = $("<canvas />");
    canvas = $canvas[0];
    $output.append($canvas);
    util.expandCanvas($canvas);
    ctx = $canvas[0].getContext("experimental-webgl", {
      premultipliedAlpha: false
    });
    renderer = flatRenderer(ctx);
    drawEveryFrame = false;
    changeCallback = null;
    draw = function() {
      return renderer.draw({
        time: (Date.now() - startTime) / 1000,
        resolution: [canvas.width, canvas.height]
      });
    };
    findUniforms = function() {
      var newUniforms, u, _i, _len, _results;
      newUniforms = require("parse").uniforms(src);
      drawEveryFrame = false;
      _results = [];
      for (_i = 0, _len = newUniforms.length; _i < _len; _i++) {
        u = newUniforms[_i];
        if (u.name === "time") {
          _results.push(drawEveryFrame = true);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
    errorLines = [];
    markErrors = function(errors) {
      var error, line, _i, _j, _len, _len2, _results;
      for (_i = 0, _len = errorLines.length; _i < _len; _i++) {
        line = errorLines[_i];
        cm.setLineClass(line, null, null);
        cm.clearMarker(line);
      }
      errorLines = [];
      $.fn.tipsy.revalidate();
      _results = [];
      for (_j = 0, _len2 = errors.length; _j < _len2; _j++) {
        error = errors[_j];
        line = cm.getLineHandle(error.lineNum - 1);
        errorLines.push(line);
        cm.setLineClass(line, null, "errorLine");
        _results.push(cm.setMarker(line, "<div class='errorMessage'>" + error.error + "</div>%N%", "errorMarker"));
      }
      return _results;
    };
    refreshCode = function() {
      var err, errors;
      src = cm.getValue();
      err = renderer.loadFragmentShader(src);
      if (err) {
        errors = require("parse").shaderError(err);
        markErrors(errors);
      } else {
        markErrors([]);
        findUniforms();
        renderer.link();
        if (!drawEveryFrame) draw();
      }
      if (changeCallback) return changeCallback(src);
    };
    cm = CodeMirror($code[0], {
      value: src,
      mode: "text/x-glsl",
      lineNumbers: true,
      onChange: refreshCode
    });
    cm.setSize("100%", $code.innerHeight());
    refreshCode();
    update = function() {
      if (drawEveryFrame) draw();
      return requestAnimationFrame(update);
    };
    update();
    $(window).focus(draw);
    editor = {
      get: function() {
        return src;
      },
      set: function(newSrc) {
        return cm.setValue(newSrc);
      },
      snapshot: function(width, height) {
        var data, oldHeight, oldWidth;
        canvas = $canvas[0];
        if (width) {
          oldWidth = canvas.width;
          oldHeight = canvas.height;
          canvas.width = width;
          canvas.height = height;
          ctx.viewport(0, 0, width, height);
        }
        draw();
        data = canvas.toDataURL('image/png');
        if (width) {
          canvas.width = oldWidth;
          canvas.height = oldHeight;
          ctx.viewport(0, 0, oldWidth, oldHeight);
          draw();
        }
        return data;
      },
      readPixels: renderer.readPixels,
      onchange: function(callback) {
        return changeCallback = callback;
      }
    };
    $canvas.data("editor", editor);
    return editor;
  };

  $(".errorMarker").tipsy({
    live: true,
    gravity: "e",
    opacity: 1.0,
    title: function() {
      return $(this).find(".errorMessage").text();
    }
  });

  module.exports = makeEditor;

}).call(this);
}, "evaluate": function(exports, require, module) {(function() {
  var abs, ceil, clamp, cos, exp, floor, fract, max, min, mod, pow, sin, sqrt, tan;

  abs = Math.abs;

  mod = function(x, y) {
    return x - y * Math.floor(x / y);
  };

  floor = Math.floor;

  ceil = Math.ceil;

  sin = Math.sin;

  cos = Math.cos;

  tan = Math.tan;

  min = Math.min;

  max = Math.max;

  clamp = function(x, minVal, maxVal) {
    return min(max(x, minVal), maxVal);
  };

  exp = Math.exp;

  pow = Math.pow;

  sqrt = Math.sqrt;

  fract = function(x) {
    return x - floor(x);
  };

  module.exports = {
    direct: function(s) {
      return eval(s);
    },
    functionOfX: function(s) {
      return eval("(function (x) {return " + s + ";})");
    },
    hasIntegers: function(s) {
      var ret;
      ret = false;
      XRegExp.forEach(s, /([0-9]*\.[0-9]*)|[0-9]+/, function(match) {
        var number;
        number = match[0];
        if (number.indexOf(".") === -1) return ret = true;
      });
      return ret;
    }
  };

}).call(this);
}, "evaluator": function(exports, require, module) {(function() {
  var evaluate;

  evaluate = require("evaluate");

  module.exports = function(opts) {
    var $code, $output, cm, outcm, refreshCode, src;
    src = opts.src;
    $output = $(opts.output);
    $code = $(opts.code);
    refreshCode = function() {
      var outputValue, worked;
      src = cm.getValue();
      worked = true;
      if (evaluate.hasIntegers(src)) {
        worked = false;
      } else {
        try {
          outputValue = evaluate.direct(src);
          outputValue = parseFloat(outputValue).toFixed(4);
          if (!isFinite(outputValue)) worked = false;
        } catch (e) {
          worked = false;
        }
      }
      if (worked) {
        return outcm.setValue(" = " + outputValue);
      } else {
        return outcm.setValue("");
      }
    };
    cm = CodeMirror($code[0], {
      value: src,
      mode: "text/x-glsl",
      onChange: refreshCode
    });
    cm.setSize("100%", $code.innerHeight());
    outcm = CodeMirror($output[0], {
      mode: "text/x-glsl",
      readOnly: true
    });
    outcm.setSize(null, $output.innerHeight());
    return refreshCode();
  };

}).call(this);
}, "exercise": function(exports, require, module) {(function() {
  var editor, template, testEqualEditors;

  editor = require("editor");

  template = "<div style=\"overflow: hidden\" class=\"workspace env\">\n  <div class=\"output canvas\" style=\"width: 300px; height: 300px; float: left;\"></div>\n  <div class=\"code\" style=\"margin-left: 324px; border: 1px solid #ccc\"></div>\n</div>\n\n<div style=\"overflow: hidden; margin-top: 24px\" class=\"solution env\">\n  <div class=\"output canvas\" style=\"width: 300px; height: 300px; float: left;\"></div>\n  <div class=\"code\" style=\"display: none\"></div>\n  <div style=\"margin-left: 324px; font-size: 30px; font-family: helvetica; height: 300px\">\n    <div style=\"float: left\">\n      <i class=\"icon-arrow-left\" style=\"font-size: 26px\"></i>\n    </div>\n    <div style=\"margin-left: 30px\">\n      <div>\n        Make this\n      </div>\n      <div style=\"font-size: 48px\">\n        <span style=\"color: #090\" data-bind=\"visible: solved\"><i class=\"icon-ok\"></i> <span style=\"font-size: 42px; font-weight: bold\">Solved</span></span>&nbsp;\n      </div>\n      <div>\n        <button style=\"vertical-align: middle\" data-bind=\"disable: onFirst, event: {click: previous}\">&#x2190;</button>\n        <span data-bind=\"text: currentExercise()+1\"></span> of <span data-bind=\"text: exercises.length\"></span>\n        <button style=\"vertical-align: middle\" data-bind=\"disable: onLast, event: {click: next}\">&#x2192;</button>\n      </div>\n    </div>\n    \n  </div>\n</div>";

  testEqualEditors = function(e1, e2) {
    var diff, equivalent, i, len, location, p1, p2;
    p1 = e1.readPixels();
    p2 = e2.readPixels();
    len = p1.length;
    equivalent = true;
    for (i = 0; i < 1000; i++) {
      location = Math.floor(Math.random() * len);
      diff = Math.abs(p1[location] - p2[location]);
      if (diff > 2) equivalent = false;
    }
    return equivalent;
  };

  module.exports = function(opts) {
    var $div, editorSolution, editorWorkspace, exercise, exercises;
    exercises = opts.exercises;
    $div = $(opts.div);
    $div.html(template);
    editorWorkspace = editor({
      src: exercises[0].workspace,
      code: $div.find(".workspace .code"),
      output: $div.find(".workspace .output")
    });
    editorSolution = editor({
      src: exercises[0].solution,
      code: $div.find(".solution .code"),
      output: $div.find(".solution .output")
    });
    exercise = {
      workspace: ko.observable(""),
      solution: ko.observable(""),
      currentExercise: ko.observable(0),
      exercises: exercises,
      solved: ko.observable(false),
      previous: function() {
        if (!exercise.onFirst()) {
          return exercise.currentExercise(exercise.currentExercise() - 1);
        }
      },
      next: function() {
        if (!exercise.onLast()) {
          return exercise.currentExercise(exercise.currentExercise() + 1);
        }
      }
    };
    exercise.onFirst = ko.computed(function() {
      return exercise.currentExercise() === 0;
    });
    exercise.onLast = ko.computed(function() {
      return exercise.currentExercise() === exercise.exercises.length - 1;
    });
    editorWorkspace.onchange(function(src) {
      return exercise.workspace(src);
    });
    editorSolution.onchange(function(src) {
      return exercise.solution(src);
    });
    ko.computed(function() {
      var e;
      e = exercises[exercise.currentExercise()];
      if (e.workspace) editorWorkspace.set(e.workspace);
      return editorSolution.set(e.solution);
    });
    ko.computed(function() {
      exercise.workspace();
      exercise.solution();
      return exercise.solved(testEqualEditors(editorWorkspace, editorSolution));
    });
    ko.computed(function() {
      return exercises[exercise.currentExercise()].workspace = exercise.workspace();
    });
    return ko.applyBindings(exercise, $div[0]);
  };

}).call(this);
}, "flatRenderer": function(exports, require, module) {(function() {
  var bufferAttribute, compileShader, fragmentShaderSource, getShaderError, makeFlatRenderer, vertexShaderSource,
    __hasProp = Object.prototype.hasOwnProperty;

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
    var flatRenderer, program, replaceShader, shaders;
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
    flatRenderer = {
      loadFragmentShader: function(shaderSource) {
        return replaceShader(shaderSource, gl.FRAGMENT_SHADER);
      },
      link: function() {
        gl.linkProgram(program);
        return null;
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
      readPixels: function() {
        var arr, h, w;
        flatRenderer.draw();
        w = gl.drawingBufferWidth;
        h = gl.drawingBufferHeight;
        arr = new Uint8Array(w * h * 4);
        gl.readPixels(0, 0, w, h, gl.RGBA, gl.UNSIGNED_BYTE, arr);
        return arr;
      },
      draw: function(uniforms) {
        var location, name, value;
        if (uniforms == null) uniforms = {};
        for (name in uniforms) {
          if (!__hasProp.call(uniforms, name)) continue;
          value = uniforms[name];
          location = gl.getUniformLocation(program, name);
          if (typeof value === "number") value = [value];
          switch (value.length) {
            case 1:
              gl.uniform1fv(location, value);
              break;
            case 2:
              gl.uniform2fv(location, value);
              break;
            case 3:
              gl.uniform3fv(location, value);
              break;
            case 4:
              gl.uniform4fv(location, value);
          }
        }
        return gl.drawArrays(gl.TRIANGLES, 0, 6);
      }
    };
    return flatRenderer;
  };

  module.exports = makeFlatRenderer;

}).call(this);
}, "graph": function(exports, require, module) {(function() {
  var evaluate, util;

  util = require("util");

  evaluate = require("evaluate");

  module.exports = function(opts) {
    var $canvas, $code, $output, cm, ctx, domain, draw, fromCanvasCoords, height, label, labelSize, range, refreshCode, src, srcFun, toCanvasCoords, width;
    src = opts.src;
    $output = $(opts.output);
    $code = $(opts.code);
    domain = opts.domain || [-1.6, 1.6];
    range = opts.range || [-1.6, 1.6];
    label = opts.label || 0.5;
    labelSize = 5;
    $canvas = $("<canvas />");
    $output.append($canvas);
    util.expandCanvas($canvas);
    ctx = $canvas[0].getContext("2d");
    width = $canvas[0].width;
    height = $canvas[0].height;
    toCanvasCoords = function(_arg) {
      var cx, cy, x, y;
      x = _arg[0], y = _arg[1];
      cx = (x - domain[0]) / (domain[1] - domain[0]) * width;
      cy = (y - range[0]) / (range[1] - range[0]) * height;
      return [cx, height - cy];
    };
    fromCanvasCoords = function(_arg) {
      var cx, cy, x, y;
      cx = _arg[0], cy = _arg[1];
      x = (cx / width) * (domain[1] - domain[0]) + domain[0];
      y = ((height - cy) / height) * (range[1] - range[0]) + range[0];
      return [x, y];
    };
    srcFun = evaluate.functionOfX(src);
    draw = function() {
      var cx, cy, i, origin, resolution, x, xi, xmax, xmin, y, yi, ymax, ymin, _ref, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
      ctx.setTransform(1, 0, 0, 1, 0, 0);
      ctx.clearRect(0, 0, width, height);
      origin = toCanvasCoords([0, 0]);
      ctx.strokeStyle = "#999";
      ctx.lineWidth = 0.5;
      ctx.beginPath();
      ctx.moveTo(origin[0], 0);
      ctx.lineTo(origin[0], height);
      ctx.stroke();
      ctx.beginPath();
      ctx.moveTo(0, origin[1]);
      ctx.lineTo(height, origin[1]);
      ctx.stroke();
      ctx.font = "12px verdana";
      ctx.fillStyle = "#666";
      _ref = fromCanvasCoords([0, height]), xmin = _ref[0], ymin = _ref[1];
      _ref2 = fromCanvasCoords([width, 0]), xmax = _ref2[0], ymax = _ref2[1];
      ctx.textAlign = "center";
      ctx.textBaseline = "top";
      for (xi = _ref3 = Math.ceil(xmin / label), _ref4 = Math.floor(xmax / label); _ref3 <= _ref4 ? xi <= _ref4 : xi >= _ref4; _ref3 <= _ref4 ? xi++ : xi--) {
        if (xi !== 0) {
          x = xi * label;
          _ref5 = toCanvasCoords([x, 0]), cx = _ref5[0], cy = _ref5[1];
          ctx.beginPath();
          ctx.moveTo(cx, cy - labelSize);
          ctx.lineTo(cx, cy + labelSize);
          ctx.stroke();
          ctx.fillText("" + x, cx, cy + labelSize * 1.5);
        }
      }
      ctx.textAlign = "left";
      ctx.textBaseline = "middle";
      for (yi = _ref6 = Math.ceil(ymin / label), _ref7 = Math.floor(ymax / label); _ref6 <= _ref7 ? yi <= _ref7 : yi >= _ref7; _ref6 <= _ref7 ? yi++ : yi--) {
        if (yi !== 0) {
          y = yi * label;
          _ref8 = toCanvasCoords([0, y]), cx = _ref8[0], cy = _ref8[1];
          ctx.beginPath();
          ctx.moveTo(cx - labelSize, cy);
          ctx.lineTo(cx + labelSize, cy);
          ctx.stroke();
          ctx.fillText("" + y, cx + labelSize * 1.5, cy);
        }
      }
      ctx.strokeStyle = "#006";
      ctx.lineWidth = 2;
      ctx.beginPath();
      resolution = 0.25;
      for (i = 0, _ref9 = width / resolution; 0 <= _ref9 ? i <= _ref9 : i >= _ref9; 0 <= _ref9 ? i++ : i--) {
        cx = i * resolution;
        x = fromCanvasCoords([cx, 0])[0];
        y = srcFun(x);
        cy = toCanvasCoords([x, y])[1];
        ctx.lineTo(cx, cy);
      }
      return ctx.stroke();
    };
    refreshCode = function() {
      var worked;
      src = cm.getValue();
      worked = true;
      try {
        srcFun = evaluate.functionOfX(src);
      } catch (e) {
        worked = false;
      }
      if (worked) return draw();
    };
    cm = CodeMirror($code[0], {
      value: src,
      mode: "text/x-glsl",
      onChange: refreshCode
    });
    cm.setSize("100%", $code.innerHeight());
    return refreshCode();
  };

}).call(this);
}, "pages/basics": function(exports, require, module) {(function() {
  var arithmetic, colors, gradients;

  colors = [
    {
      workspace: "precision mediump float;\n\nvoid main() {\n  gl_FragColor.r = 1.0;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = 0.0;\n  gl_FragColor.a = 1.0;\n}",
      solution: "precision mediump float;\n\nvoid main() {\n  gl_FragColor.r = 0.0;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = 1.0;\n  gl_FragColor.a = 1.0;\n}"
    }, {
      solution: "precision mediump float;\n\nvoid main() {\n  gl_FragColor.r = 1.0;\n  gl_FragColor.g = 1.0;\n  gl_FragColor.b = 0.0;\n  gl_FragColor.a = 1.0;\n}"
    }, {
      solution: "precision mediump float;\n\nvoid main() {\n  gl_FragColor.r = 1.0;\n  gl_FragColor.g = 0.5;\n  gl_FragColor.b = 0.0;\n  gl_FragColor.a = 1.0;\n}"
    }, {
      solution: "precision mediump float;\n\nvoid main() {\n  gl_FragColor.r = 0.5;\n  gl_FragColor.g = 0.5;\n  gl_FragColor.b = 0.5;\n  gl_FragColor.a = 1.0;\n}"
    }
  ];

  gradients = [
    {
      workspace: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = position.x;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = 0.0;\n  gl_FragColor.a = 1.0;\n}",
      solution: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = 0.0;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = position.y;\n  gl_FragColor.a = 1.0;\n}"
    }, {
      solution: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = position.x;\n  gl_FragColor.g = position.x;\n  gl_FragColor.b = 0.0;\n  gl_FragColor.a = 1.0;\n}"
    }, {
      solution: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = position.x;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = position.y;\n  gl_FragColor.a = 1.0;\n}"
    }
  ];

  arithmetic = [
    {
      workspace: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = 1.0 - position.x;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = 0.0;\n  gl_FragColor.a = 1.0;\n}",
      solution: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = 0.0;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = 1.0 - position.y;\n  gl_FragColor.a = 1.0;\n}"
    }, {
      solution: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = 1.0 - position.x;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = position.x;\n  gl_FragColor.a = 1.0;\n}"
    }, {
      solution: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = (position.x + position.y) / 2.0;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = 0.0;\n  gl_FragColor.a = 1.0;\n}"
    }, {
      solution: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = (position.x + 1.0 - position.y) / 2.0;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = 0.0;\n  gl_FragColor.a = 1.0;\n}"
    }
  ];

  module.exports = function() {
    $("code").each(function() {
      CodeMirror.runMode($(this).text(), "text/x-glsl", this);
      return $(this).addClass("cm-s-default");
    });
    require("../exercise")({
      div: $("#exercise-colors"),
      exercises: colors
    });
    require("../exercise")({
      div: $("#exercise-gradients"),
      exercises: gradients
    });
    return require("../exercise")({
      div: $("#exercise-arithmetic"),
      exercises: arithmetic
    });
  };

}).call(this);
}, "pages/fullscreen": function(exports, require, module) {(function() {
  var clickTab, editor, load, selectTab, sources, storage;

  sources = {
    blank: "precision mediump float;\n\nvarying vec2 position;\nuniform float time;\nuniform vec2 resolution;\n\nvoid main() {\n  gl_FragColor.r = position.x;\n  gl_FragColor.g = position.y;\n  gl_FragColor.b = 1.0;\n  gl_FragColor.a = 1.0;\n}",
    quasi: "precision mediump float;\n\nvarying vec2 position;\nuniform float time;\n\nconst float waves = 19.;\n\n// triangle wave from 0 to 1\nfloat wrap(float n) {\n  return abs(mod(n, 2.)-1.)*-1. + 1.;\n}\n\n// creates a cosine wave in the plane at a given angle\nfloat wave(float angle, vec2 point) {\n  float cth = cos(angle);\n  float sth = sin(angle);\n  return (cos (cth*point.x + sth*point.y) + 1.) / 2.;\n}\n\n// sum cosine waves at various interfering angles\n// wrap values when they exceed 1\nfloat quasi(float interferenceAngle, vec2 point) {\n  float sum = 0.;\n  for (float i = 0.; i < waves; i++) {\n    sum += wave(3.1416*i*interferenceAngle, point);\n  }\n  return wrap(sum);\n}\n\nvoid main() {\n  float b = quasi(time*0.002, (position-0.5)*200.);\n  vec4 c1 = vec4(0.0,0.,0.2,1.);\n  vec4 c2 = vec4(1.5,0.7,0.,1.);\n  gl_FragColor = mix(c1,c2,b);\n}",
    warp: "/*\nIterated Fractional Brownian Motion\nBased on:\n  http://www.iquilezles.org/www/articles/warp/warp.htm\n*/\n\nprecision mediump float;\n\nvarying vec2 position;\nuniform float time;\nuniform vec2 resolution;\n\n// makes a pseudorandom number between 0 and 1\nfloat hash(float n) {\n  return fract(sin(n)*93942.234);\n}\n\n// smoothsteps a grid of random numbers at the integers\nfloat noise(vec2 p) {\n  vec2 w = floor(p);\n  vec2 k = fract(p);\n  k = k*k*(3.-2.*k); // smooth it\n  \n  float n = w.x + w.y*57.;\n  \n  float a = hash(n);\n  float b = hash(n+1.);\n  float c = hash(n+57.);\n  float d = hash(n+58.);\n  \n  return mix(\n    mix(a, b, k.x),\n    mix(c, d, k.x),\n    k.y);\n}\n\n// rotation matrix\nmat2 m = mat2(0.6,0.8,-0.8,0.6);\n\n// fractional brownian motion (i.e. photoshop clouds)\nfloat fbm(vec2 p) {\n  float f = 0.;\n  f += 0.5000*noise(p); p *= 2.02*m;\n  f += 0.2500*noise(p); p *= 2.01*m;\n  f += 0.1250*noise(p); p *= 2.03*m;\n  f += 0.0625*noise(p);\n  f /= 0.9375;\n  return f;\n}\n\nvoid main() {\n  // relative coordinates\n  vec2 p = vec2(position*6.)*vec2(resolution.x/resolution.y, 1.);\n  float t = time * .009;\n  \n  // calling fbm on itself\n  vec2 a = vec2(fbm(p+t*3.), fbm(p-t*3.+8.1));\n  vec2 b = vec2(fbm(p+t*4. + a*7. + 3.1), fbm(p-t*4. + a*7. + 91.1));\n  float c = fbm(b*9. + t*20.);\n  \n  // increase contrast\n  c = smoothstep(0.15,0.98,c);\n  \n  // mix in some color\n  vec3 col = vec3(c);\n  col.rb += b*0.17;\n  \n  gl_FragColor = vec4(col, 1.);\n}"
  };

  storage = require("../storage");

  editor = null;

  load = function(src) {
    $("#share-button").click(function() {
      return storage.serialize(editor.get(), function(hash) {
        var url;
        url = location.href.split("#")[0] + "#" + hash;
        $("#popup").show();
        $("#share-url").val(url);
        return $("#share-url").select();
      });
    });
    selectTab("code");
    $('#drawer .tab').click(clickTab);
    editor = require("../editor")({
      src: src,
      code: $("#code"),
      output: $("#output")
    });
    return editor.onchange(function() {
      return storage.saveLast(editor.get());
    });
  };

  window.selectShader = function(name) {
    selectTab("code");
    return editor.set(sources[name]);
  };

  clickTab = function() {
    var selectedTab, tab;
    tab = $(this).attr("data-tab");
    selectedTab = $("#drawer").attr("data-selected");
    if (tab === selectedTab) {
      $('#fullscreen').toggleClass('show-drawer');
    } else {
      $('#fullscreen').addClass('show-drawer');
    }
    return selectTab(tab);
  };

  selectTab = function(tab) {
    $('#drawer').attr("data-selected", tab);
    $('#drawer .tab').removeClass("selected");
    $("#drawer .tab[data-tab='" + tab + "']").addClass("selected");
    $('#drawer section').removeClass("selected");
    return $("#drawer section[data-tab='" + tab + "']").addClass("selected");
  };

  module.exports = function() {
    var hash, src;
    hash = location.hash.substr(1);
    if (hash) {
      if (sources[hash]) {
        load(sources[hash]);
      } else {
        storage.unserialize(hash, load);
      }
    } else {
      $('#fullscreen').addClass('show-drawer');
      src = storage.loadLast();
      if (src) {
        load(src);
      } else {
        load(sources["blank"]);
      }
    }
    return history.replaceState("", "", location.pathname);
  };

}).call(this);
}, "pages/homepage": function(exports, require, module) {(function() {
  var src;

  src = "precision mediump float;\n\nvarying vec2 position;\nuniform float time;\n\nconst float waves = 11.;\n\n// triangle wave from 0 to 1\nfloat wrap(float n) {\n  return abs(mod(n, 2.)-1.)*-1. + 1.;\n}\n\n// creates a cosine wave in the plane at a given angle\nfloat wave(float angle, vec2 point) {\n  float cth = cos(angle);\n  float sth = sin(angle);\n  return (cos (cth*point.x + sth*point.y) + 1.) / 2.;\n}\n\n// sum cosine waves at various interfering angles\n// wrap values when they exceed 1\nfloat quasi(float interferenceAngle, vec2 point) {\n  float sum = 0.;\n  for (float i = 0.; i < waves; i++) {\n    sum += wave(3.1416*i*interferenceAngle, point);\n  }\n  return wrap(sum);\n}\n\nvoid main() {\n  vec2 p = position - 0.5;\n  float b = quasi(time*0.016, p*40.);\n  \n  b *= 1.2;\n  b += .1;\n  \n  vec3 col = vec3(b);\n  \n  gl_FragColor = vec4(col, 1.0);\n  gl_FragColor.a *= 1. - smoothstep(0.44, 0.495, length(p));\n}";

  module.exports = function() {
    var editor;
    return editor = require("../editor")({
      src: src,
      code: $("#logo-code"),
      output: $("#logo")
    });
  };

}).call(this);
}, "pages/test": function(exports, require, module) {(function() {

  module.exports = function() {
    require("../graph")({
      output: $("#output"),
      code: $("#code"),
      src: "abs(x)"
    });
    return require("../evaluator")({
      output: $("#eoutput"),
      code: $("#ecode"),
      src: "3. + 5."
    });
  };

}).call(this);
}, "parse": function(exports, require, module) {(function() {

  module.exports = {
    shaderError: function(error) {
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
    },
    uniforms: function(src) {
      var regex, uniforms;
      regex = XRegExp('uniform +(?<type>[^ ]+) +(?<name>[^ ;]+) *;', 'g');
      uniforms = [];
      XRegExp.forEach(src, regex, function(match) {
        return uniforms.push({
          type: match.type,
          name: match.name
        });
      });
      return uniforms;
    }
  };

}).call(this);
}, "storage": function(exports, require, module) {(function() {
  function convertHexToBytes( text ) {
  var tmpHex, array = [];
  for ( var i = 0; i < text.length; i += 2 ) {
    tmpHex = text.substring( i, i + 2 );
    array.push( parseInt( tmpHex, 16 ) );
  }
  return array;
}

function convertBytesToHex( byteArray ) {
  var tmpHex, hex = "";
  for ( var i = 0, il = byteArray.length; i < il; i ++ ) {
    if ( byteArray[ i ] < 0 ) {
      byteArray[ i ] = byteArray[ i ] + 256;
    }
    tmpHex = byteArray[ i ].toString( 16 );
    // add leading zero
    if ( tmpHex.length == 1 ) tmpHex = "0" + tmpHex;
    hex += tmpHex;
  }
  return hex;
};
  var lzma;

  lzma = new LZMA("../vendor/lzma/lzma_worker.js");

  module.exports = {
    loadLast: function() {
      return localStorage["last"];
    },
    saveLast: function(src) {
      return localStorage["last"] = src;
    },
    serialize: function(src, callback) {
      return lzma.compress(src, 1, function(bytes) {
        var compressed;
        compressed = convertBytesToHex(bytes);
        return callback(compressed);
      });
    },
    unserialize: function(blob, callback) {
      var bytes;
      bytes = convertHexToBytes(blob);
      return lzma.decompress(bytes, function(src) {
        return callback(src);
      });
    }
  };

}).call(this);
}, "util": function(exports, require, module) {(function() {

  module.exports = {
    expandCanvas: function(canvas) {
      var $canvas;
      $canvas = $(canvas);
      return $canvas.attr({
        width: $canvas.innerWidth(),
        height: $canvas.innerHeight()
      });
    }
  };

}).call(this);
}});
