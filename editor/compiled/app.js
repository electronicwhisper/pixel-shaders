
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
    var $canvas, $code, $output, canvas, changeCallback, cm, ctx, draw, drawEveryFrame, editor, errorLines, findUniforms, gl, markErrors, refreshCode, renderer, src, texture, uniforms, update, updateWebcam;
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
    uniforms = {};
    gl = ctx;
    texture = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    updateWebcam = function() {
      var webcamVideo;
      webcamVideo = require("webcam")();
      if (webcamVideo) {
        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, texture);
        return gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, webcamVideo);
      }
    };
    draw = function() {
      if (uniforms.webcam) {
        updateWebcam();
        renderer.hackSetUniformInt("webcam", 0);
      }
      return renderer.draw({
        time: (Date.now() - startTime) / 1000,
        resolution: [canvas.width, canvas.height]
      });
    };
    findUniforms = function() {
      var newUniforms, u, _i, _len, _results;
      uniforms = {};
      newUniforms = require("parse").uniforms(src);
      drawEveryFrame = false;
      _results = [];
      for (_i = 0, _len = newUniforms.length; _i < _len; _i++) {
        u = newUniforms[_i];
        uniforms[u.name] = u.type;
        if (u.name === "time" || u.name === "webcam") {
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
      matchBrackets: true,
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
  var errorValue, evalInContext, evaluate, hasIntegers, hasX;

  evalInContext = (function() {
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
    return function(s) {
      return eval(s);
    };
  })();

  hasIntegers = function(s) {
    var ret;
    ret = false;
    XRegExp.forEach(s, /([0-9]*\.[0-9]*)|[0-9]+/, function(match) {
      var number;
      number = match[0];
      if (number.indexOf(".") === -1) return ret = true;
    });
    return ret;
  };

  errorValue = {
    err: true
  };

  hasX = function(tree) {
    if (_.isArray(tree)) {
      return _.any(tree, hasX);
    } else {
      return tree === "x";
    }
  };

  evaluate = {
    direct: function(s) {
      var outputValue;
      outputValue = errorValue;
      if (!hasIntegers(s)) {
        try {
          outputValue = evalInContext(s);
        } catch (e) {

        }
      }
      return outputValue;
    },
    functionOfX: function(s) {
      if (hasIntegers(s)) return errorValue;
      return evalInContext("(function (x) {return " + s + ";})");
    },
    hasIntegers: hasIntegers,
    stepped: function(s, precision) {
      var ast, pad, ret, step;
      if (precision == null) precision = 4;
      ast = require("parsing/expression").parse(s);
      pad = function(s, length) {
        var n, spaces;
        spaces = function(n) {
          var _i, _results;
          return (function() {
            _results = [];
            for (var _i = 0; 0 <= n ? _i < n : _i > n; 0 <= n ? _i++ : _i--){ _results.push(_i); }
            return _results;
          }).apply(this).map(function() {
            return " ";
          }).join("");
        };
        n = length - s.length;
        return s + spaces(n);
      };
      step = function(tree) {
        var didReduction, evaled, joined, node, ret, _i, _len;
        ret = [];
        didReduction = false;
        for (_i = 0, _len = tree.length; _i < _len; _i++) {
          node = tree[_i];
          if (!didReduction && _.isArray(node)) {
            ret.push(step(node));
            didReduction = true;
          } else {
            ret.push(node);
          }
        }
        if (!didReduction) {
          joined = tree.join("");
          evaled = evalInContext(joined).toFixed(precision);
          return evaled;
        } else {
          return ret;
        }
      };
      ret = [];
      while (_.isArray(ast)) {
        ret.push(_.flatten(ast).join(""));
        ast = step(ast);
      }
      ret.push(ast.toString());
      return ret;
    },
    findSubExpression: function(s, cStart, cEnd) {
      var find, length, sum, tree;
      tree = require("parsing/expression").parse(s);
      sum = function(a) {
        return _.reduce(a, (function(memo, num) {
          return memo + num;
        }), 0);
      };
      length = function(tree) {
        if (_.isArray(tree)) {
          return sum(_.map(tree, length));
        } else {
          return tree.length;
        }
      };
      find = function(tree, start) {
        var found, node, _i, _len;
        if (start == null) start = 0;
        s = start;
        found = [s, length(tree)];
        for (_i = 0, _len = tree.length; _i < _len; _i++) {
          node = tree[_i];
          if (s > cStart) break;
          if (s + length(node) < cEnd) {
            s += length(node);
          } else {
            if (_.isArray(node) && hasX(node)) {
              found = find(node, s);
            } else {
              break;
            }
          }
        }
        return found;
      };
      return find(tree);
    },
    findAllSubExpressions: function(s) {
      var spider, subExprs, tree;
      tree = require("parsing/expression").parse(s);
      subExprs = [];
      spider = function(tree) {
        var node, _i, _len, _results;
        if (_.isArray(tree)) {
          if (hasX(tree)) subExprs.push(tree);
          _results = [];
          for (_i = 0, _len = tree.length; _i < _len; _i++) {
            node = tree[_i];
            _results.push(spider(node));
          }
          return _results;
        }
      };
      spider(tree);
      return subExprs;
    }
  };

  module.exports = evaluate;

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
      var outputValue;
      src = cm.getValue();
      outputValue = evaluate.direct(src);
      if (!outputValue.err && isFinite(outputValue)) {
        outputValue = parseFloat(outputValue).toFixed(4);
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
      },
      hackSetUniformInt: function(name, value) {
        var location;
        location = gl.getUniformLocation(program, name);
        return gl.uniform1i(location, value);
      }
    };
    return flatRenderer;
  };

  module.exports = makeFlatRenderer;

}).call(this);
}, "graph": function(exports, require, module) {(function() {

  module.exports = function(ctx, opts) {
    var canvas, draw, fromCanvasCoords, height, o, toCanvasCoords, width;
    o = _.extend({
      equations: [],
      domain: [-2.6, 2.6],
      range: [-2.6, 2.6],
      label: 1,
      labelSize: 5
    }, opts);
    canvas = ctx.canvas;
    width = canvas.width;
    height = canvas.height;
    toCanvasCoords = function(_arg) {
      var cx, cy, x, y;
      x = _arg[0], y = _arg[1];
      cx = (x - o.domain[0]) / (o.domain[1] - o.domain[0]) * width;
      cy = (y - o.range[0]) / (o.range[1] - o.range[0]) * height;
      return [cx, height - cy];
    };
    fromCanvasCoords = function(_arg) {
      var cx, cy, x, y;
      cx = _arg[0], cy = _arg[1];
      x = (cx / width) * (o.domain[1] - o.domain[0]) + o.domain[0];
      y = ((height - cy) / height) * (o.range[1] - o.range[0]) + o.range[0];
      return [x, y];
    };
    draw = function() {
      var cx, cy, equation, f, i, origin, resolution, x, xi, xmax, xmin, y, yi, ymax, ymin, _i, _j, _len, _len2, _ref, _ref10, _ref11, _ref12, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9, _results;
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
      for (xi = _ref3 = Math.ceil(xmin / o.label), _ref4 = Math.floor(xmax / o.label); _ref3 <= _ref4 ? xi <= _ref4 : xi >= _ref4; _ref3 <= _ref4 ? xi++ : xi--) {
        if (xi !== 0) {
          x = xi * o.label;
          _ref5 = toCanvasCoords([x, 0]), cx = _ref5[0], cy = _ref5[1];
          ctx.beginPath();
          ctx.moveTo(cx, cy - o.labelSize);
          ctx.lineTo(cx, cy + o.labelSize);
          ctx.stroke();
          ctx.fillText("" + x, cx, cy + o.labelSize * 1.5);
        }
      }
      ctx.textAlign = "left";
      ctx.textBaseline = "middle";
      for (yi = _ref6 = Math.ceil(ymin / o.label), _ref7 = Math.floor(ymax / o.label); _ref6 <= _ref7 ? yi <= _ref7 : yi >= _ref7; _ref6 <= _ref7 ? yi++ : yi--) {
        if (yi !== 0) {
          y = yi * o.label;
          _ref8 = toCanvasCoords([0, y]), cx = _ref8[0], cy = _ref8[1];
          ctx.beginPath();
          ctx.moveTo(cx - o.labelSize, cy);
          ctx.lineTo(cx + o.labelSize, cy);
          ctx.stroke();
          ctx.fillText("" + y, cx + o.labelSize * 1.5, cy);
        }
      }
      ctx.lineWidth = 2;
      _ref9 = o.equations;
      for (_i = 0, _len = _ref9.length; _i < _len; _i++) {
        equation = _ref9[_i];
        ctx.strokeStyle = equation.color;
        f = equation.f;
        ctx.beginPath();
        resolution = 0.25;
        for (i = 0, _ref10 = width / resolution; 0 <= _ref10 ? i <= _ref10 : i >= _ref10; 0 <= _ref10 ? i++ : i--) {
          cx = i * resolution;
          x = fromCanvasCoords([cx, 0])[0];
          y = f(x);
          cy = toCanvasCoords([x, y])[1];
          ctx.lineTo(cx, cy);
        }
        ctx.stroke();
      }
      if (o.hint || o.hint === 0) {
        ctx.lineWidth = 0.25;
        _ref11 = o.equations;
        _results = [];
        for (_j = 0, _len2 = _ref11.length; _j < _len2; _j++) {
          equation = _ref11[_j];
          x = o.hint;
          y = equation.f(o.hint);
          _ref12 = toCanvasCoords([x, y]), cx = _ref12[0], cy = _ref12[1];
          ctx.strokeStyle = "#000";
          ctx.beginPath();
          ctx.moveTo.apply(ctx, toCanvasCoords([x, 0]));
          ctx.lineTo(cx, cy);
          ctx.stroke();
          ctx.strokeStyle = equation.color;
          ctx.beginPath();
          ctx.moveTo(cx, cy);
          ctx.lineTo.apply(ctx, toCanvasCoords([0, y]));
          ctx.stroke();
          ctx.fillStyle = equation.color;
          ctx.beginPath();
          ctx.arc(cx, cy, 3, 0, Math.PI * 2, false);
          _results.push(ctx.fill());
        }
        return _results;
      }
    };
    return {
      toCanvasCoords: toCanvasCoords,
      fromCanvasCoords: fromCanvasCoords,
      draw: function(opts) {
        o = _.extend(o, opts);
        return draw();
      }
    };
  };

}).call(this);
}, "graphEditor": function(exports, require, module) {(function() {
  var evaluate, util,
    __slice = Array.prototype.slice;

  util = require("util");

  evaluate = require("evaluate");

  module.exports = function(opts) {
    var $canvas, $code, $output, changeCallbacks, cm, compiled, ctx, fireChangeCallbacks, graph, o, refreshCode, src, srcFun;
    o = opts;
    $output = $(o.output);
    $canvas = $("<canvas />");
    $output.append($canvas);
    util.expandCanvas($canvas);
    ctx = $canvas[0].getContext("2d");
    graph = require("graph")(ctx, opts);
    src = o.src;
    $code = $(o.code);
    srcFun = evaluate.functionOfX(src);
    compiled = true;
    refreshCode = function() {
      src = cm.getValue();
      compiled = true;
      try {
        srcFun = evaluate.functionOfX(src);
        srcFun(0);
      } catch (e) {
        compiled = false;
      }
      if (compiled) {
        return $code.removeClass("error");
      } else {
        return $code.addClass("error");
      }
    };
    changeCallbacks = [refreshCode];
    fireChangeCallbacks = function() {
      var args, c, _i, _len, _results;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _results = [];
      for (_i = 0, _len = changeCallbacks.length; _i < _len; _i++) {
        c = changeCallbacks[_i];
        _results.push(c.apply(null, args));
      }
      return _results;
    };
    cm = CodeMirror($code[0], {
      value: src,
      mode: "text/x-glsl",
      onChange: fireChangeCallbacks
    });
    cm.setSize("100%", $code.innerHeight());
    refreshCode();
    return {
      graph: graph,
      cm: cm,
      change: function(c) {
        return changeCallbacks.push(c);
      },
      get: function() {
        return src;
      },
      compiled: function() {
        return compiled;
      },
      substitute: function(x) {
        return src.replace(/\bx\b/g, x);
      },
      valueAt: function(x) {
        return srcFun(x);
      }
    };
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
}, "pages/book": function(exports, require, module) {(function() {
  var shaderTemplate;

  shaderTemplate = "<div style=\"overflow: hidden\" class=\"workspace env\">\n  <div class=\"output canvas\" style=\"width: 300px; height: 300px; float: left;\"></div>\n  <div class=\"code\" style=\"margin-left: 324px; border: 1px solid #ccc\"></div>\n</div>";

  module.exports = function() {
    $("code").each(function() {
      CodeMirror.runMode($(this).text(), "text/x-glsl", this);
      return $(this).addClass("cm-s-default");
    });
    return $(".book-shader").each(function() {
      var $div, $shaderDiv, src;
      $div = $(this);
      src = $div.text();
      src = src.trim();
      $shaderDiv = $(shaderTemplate);
      $div.replaceWith($shaderDiv);
      return require("../editor")({
        src: src,
        output: $shaderDiv.find(".output"),
        code: $shaderDiv.find(".code")
      });
    });
  };

}).call(this);
}, "pages/fullscreen": function(exports, require, module) {(function() {
  var clickTab, editor, load, selectTab, sources, storage;

  sources = {
    blank: "precision mediump float;\n\nvarying vec2 position;\nuniform float time;\nuniform vec2 resolution;\n\nvoid main() {\n  gl_FragColor.r = position.x;\n  gl_FragColor.g = position.y;\n  gl_FragColor.b = 1.0;\n  gl_FragColor.a = 1.0;\n}",
    quasi: "precision mediump float;\n\nvarying vec2 position;\nuniform float time;\n\nconst float waves = 19.;\n\n// triangle wave from 0 to 1\nfloat wrap(float n) {\n  return abs(mod(n, 2.)-1.)*-1. + 1.;\n}\n\n// creates a cosine wave in the plane at a given angle\nfloat wave(float angle, vec2 point) {\n  float cth = cos(angle);\n  float sth = sin(angle);\n  return (cos (cth*point.x + sth*point.y) + 1.) / 2.;\n}\n\n// sum cosine waves at various interfering angles\n// wrap values when they exceed 1\nfloat quasi(float interferenceAngle, vec2 point) {\n  float sum = 0.;\n  for (float i = 0.; i < waves; i++) {\n    sum += wave(3.1416*i*interferenceAngle, point);\n  }\n  return wrap(sum);\n}\n\nvoid main() {\n  float b = quasi(time*0.002, (position-0.5)*200.);\n  vec4 c1 = vec4(0.0,0.,0.2,1.);\n  vec4 c2 = vec4(1.5,0.7,0.,1.);\n  gl_FragColor = mix(c1,c2,b);\n}",
    warp: "/*\nIterated Fractional Brownian Motion\nBased on:\n  http://www.iquilezles.org/www/articles/warp/warp.htm\n*/\n\nprecision mediump float;\n\nvarying vec2 position;\nuniform float time;\nuniform vec2 resolution;\n\n// makes a pseudorandom number between 0 and 1\nfloat hash(float n) {\n  return fract(sin(n)*93942.234);\n}\n\n// smoothsteps a grid of random numbers at the integers\nfloat noise(vec2 p) {\n  vec2 w = floor(p);\n  vec2 k = fract(p);\n  k = k*k*(3.-2.*k); // smooth it\n  \n  float n = w.x + w.y*57.;\n  \n  float a = hash(n);\n  float b = hash(n+1.);\n  float c = hash(n+57.);\n  float d = hash(n+58.);\n  \n  return mix(\n    mix(a, b, k.x),\n    mix(c, d, k.x),\n    k.y);\n}\n\n// rotation matrix\nmat2 m = mat2(0.6,0.8,-0.8,0.6);\n\n// fractional brownian motion (i.e. photoshop clouds)\nfloat fbm(vec2 p) {\n  float f = 0.;\n  f += 0.5000*noise(p); p *= 2.02*m;\n  f += 0.2500*noise(p); p *= 2.01*m;\n  f += 0.1250*noise(p); p *= 2.03*m;\n  f += 0.0625*noise(p);\n  f /= 0.9375;\n  return f;\n}\n\nvoid main() {\n  // relative coordinates\n  vec2 p = vec2(position*6.)*vec2(resolution.x/resolution.y, 1.);\n  float t = time * .009;\n  \n  // calling fbm on itself\n  vec2 a = vec2(fbm(p+t*3.), fbm(p-t*3.+8.1));\n  vec2 b = vec2(fbm(p+t*4. + a*7. + 3.1), fbm(p-t*4. + a*7. + 91.1));\n  float c = fbm(b*9. + t*20.);\n  \n  // increase contrast\n  c = smoothstep(0.15,0.98,c);\n  \n  // mix in some color\n  vec3 col = vec3(c);\n  col.rb += b*0.17;\n  \n  gl_FragColor = vec4(col, 1.);\n}",
    webcamIdentity: "precision mediump float;\n\nvarying vec2 position;\nuniform sampler2D webcam;\n\nvoid main() {\n  gl_FragColor = texture2D(webcam, position);\n}",
    webcamInvert: "precision mediump float;\n\nvarying vec2 position;\nuniform sampler2D webcam;\n\nvoid main() {\n  vec2 p = position;\n  vec4 color = texture2D(webcam, p);\n  color.rgb = 1.0 - color.rgb;\n  gl_FragColor = color;\n}",
    webcamStreak: "precision mediump float;\n\nvarying vec2 position;\nuniform sampler2D webcam;\n\nvoid main() {\n  vec2 p = position;\n  p.y = 0.5; // only sample from a horizontal strip through the center\n  vec4 color = texture2D(webcam, p);\n  gl_FragColor = color;\n}",
    webcamPinch: "precision mediump float;\n\nvarying vec2 position;\nuniform sampler2D webcam;\n\nvoid main() {\n  // normalize to the center\n  vec2 p = position - 0.5;\n  \n  // cartesian to polar coordinates\n  float r = length(p);\n  float a = atan(p.y, p.x);\n  \n  // distort\n  r = sqrt(r); // pinch\n  //r = r*r; // bulge\n  \n  // polar to cartesian coordinates\n  p = r * vec2(cos(a), sin(a));\n  \n  // sample the webcam\n  vec4 color = texture2D(webcam, p + 0.5);\n  gl_FragColor = color;\n}",
    webcamKaleidoscope: "precision mediump float;\n\nvarying vec2 position;\nuniform sampler2D webcam;\n\nvoid main() {\n  // normalize to the center\n  vec2 p = position - 0.5;\n  \n  // cartesian to polar coordinates\n  float r = length(p);\n  float a = atan(p.y, p.x);\n  \n  // kaleidoscope\n  float sides = 6.;\n  float tau = 2. * 3.1416;\n  a = mod(a, tau/sides);\n  a = abs(a - tau/sides/2.);\n  \n  // polar to cartesian coordinates\n  p = r * vec2(cos(a), sin(a));\n  \n  // sample the webcam\n  vec4 color = texture2D(webcam, p + 0.5);\n  gl_FragColor = color;\n}"
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
    var graphEditor, precision;
    graphEditor = require("../graphEditor")({
      output: $("#output"),
      code: $("#code"),
      src: "abs(x)"
    });
    graphEditor.change(function() {
      var equations, f, html, htmlify, src, stringify, tree;
      if (graphEditor.compiled()) {
        src = graphEditor.get();
        tree = require("parsing/expression").parse(src);
        stringify = function(node) {
          if (_.isArray(node)) {
            return _.flatten(node).join("");
          } else {
            return node;
          }
        };
        htmlify = function(node) {
          var s;
          s = "<li><span class='node'>" + (stringify(node)) + "</span>";
          if (_.isArray(node)) {
            s += "<ul>" + (node.filter(_.isArray).map(htmlify).join("")) + "</ul>";
          }
          s += "</li>";
          return s;
        };
        html = "<ul class='tree'>" + (htmlify(tree)) + "</ul>";
        $("#substitution").html(html);
        require("util").syntaxHighlight($("#substitution").find(".node"));
        $("#substitution").find(".node").each(function() {
          var $this, s;
          $this = $(this);
          s = $this.text();
          $this.data("s", s);
          return $this.data("f", require("evaluate").functionOfX(s));
        });
        f = require("evaluate").functionOfX(src);
        equations = [
          {
            f: f,
            color: "#006"
          }
        ];
        return graphEditor.graph.draw({
          equations: equations
        });
      }
    });
    $("#substitution").on("mouseover", ".node", function() {
      var equations, f, s;
      s = $(this).text();
      f = require("evaluate").functionOfX(s);
      equations = [
        {
          f: f,
          color: "#006"
        }
      ];
      return graphEditor.graph.draw({
        equations: equations
      });
    });
    precision = 2;
    require("../util").relativeMouseMove($("#output"), function(position, size) {
      var p, x;
      if (graphEditor.compiled()) {
        p = graphEditor.graph.fromCanvasCoords(position);
        x = p[0];
        return graphEditor.graph.draw({
          hint: +x
        });
      }
    });
    return $("#output").mouseout(function() {
      $("#substitution").find(".node").each(function() {
        var $this;
        $this = $(this);
        $this.html($this.data('s'));
        return require("util").syntaxHighlight($this);
      });
      return graphEditor.graph.draw({
        hint: null
      });
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
}, "parsing/expression": function(exports, require, module) {module.exports = (function(){
  /*
   * Generated by PEG.js 0.7.0.
   *
   * http://pegjs.majda.cz/
   */
  
  function quote(s) {
    /*
     * ECMA-262, 5th ed., 7.8.4: All characters may appear literally in a
     * string literal except for the closing quote character, backslash,
     * carriage return, line separator, paragraph separator, and line feed.
     * Any character may appear in the form of an escape sequence.
     *
     * For portability, we also escape escape all control and non-ASCII
     * characters. Note that "\0" and "\v" escape sequences are not used
     * because JSHint does not like the first and IE the second.
     */
     return '"' + s
      .replace(/\\/g, '\\\\')  // backslash
      .replace(/"/g, '\\"')    // closing quote character
      .replace(/\x08/g, '\\b') // backspace
      .replace(/\t/g, '\\t')   // horizontal tab
      .replace(/\n/g, '\\n')   // line feed
      .replace(/\f/g, '\\f')   // form feed
      .replace(/\r/g, '\\r')   // carriage return
      .replace(/[\x00-\x07\x0B\x0E-\x1F\x80-\uFFFF]/g, escape)
      + '"';
  }
  
  var result = {
    /*
     * Parses the input with a generated parser. If the parsing is successfull,
     * returns a value explicitly or implicitly specified by the grammar from
     * which the parser was generated (see |PEG.buildParser|). If the parsing is
     * unsuccessful, throws |PEG.parser.SyntaxError| describing the error.
     */
    parse: function(input, startRule) {
      var parseFunctions = {
        "start": parse_start,
        "_": parse__,
        "add_op": parse_add_op,
        "mul_op": parse_mul_op,
        "unary_op": parse_unary_op,
        "func_name": parse_func_name,
        "variable": parse_variable,
        "additive": parse_additive,
        "multiplicative": parse_multiplicative,
        "func_call": parse_func_call,
        "param_list": parse_param_list,
        "primary": parse_primary,
        "number": parse_number
      };
      
      if (startRule !== undefined) {
        if (parseFunctions[startRule] === undefined) {
          throw new Error("Invalid rule name: " + quote(startRule) + ".");
        }
      } else {
        startRule = "start";
      }
      
      var pos = 0;
      var reportFailures = 0;
      var rightmostFailuresPos = 0;
      var rightmostFailuresExpected = [];
      
      function padLeft(input, padding, length) {
        var result = input;
        
        var padLength = length - input.length;
        for (var i = 0; i < padLength; i++) {
          result = padding + result;
        }
        
        return result;
      }
      
      function escape(ch) {
        var charCode = ch.charCodeAt(0);
        var escapeChar;
        var length;
        
        if (charCode <= 0xFF) {
          escapeChar = 'x';
          length = 2;
        } else {
          escapeChar = 'u';
          length = 4;
        }
        
        return '\\' + escapeChar + padLeft(charCode.toString(16).toUpperCase(), '0', length);
      }
      
      function matchFailed(failure) {
        if (pos < rightmostFailuresPos) {
          return;
        }
        
        if (pos > rightmostFailuresPos) {
          rightmostFailuresPos = pos;
          rightmostFailuresExpected = [];
        }
        
        rightmostFailuresExpected.push(failure);
      }
      
      function parse_start() {
        var result0, result1, result2;
        var pos0, pos1;
        
        pos0 = pos;
        pos1 = pos;
        result0 = parse__();
        result0 = result0 !== null ? result0 : "";
        if (result0 !== null) {
          result1 = parse_additive();
          if (result1 !== null) {
            result2 = parse__();
            result2 = result2 !== null ? result2 : "";
            if (result2 !== null) {
              result0 = [result0, result1, result2];
            } else {
              result0 = null;
              pos = pos1;
            }
          } else {
            result0 = null;
            pos = pos1;
          }
        } else {
          result0 = null;
          pos = pos1;
        }
        if (result0 !== null) {
          result0 = (function(offset, exp) { return exp; })(pos0, result0[1]);
        }
        if (result0 === null) {
          pos = pos0;
        }
        return result0;
      }
      
      function parse__() {
        var result0, result1;
        var pos0;
        
        pos0 = pos;
        result0 = [];
        if (input.charCodeAt(pos) === 32) {
          result1 = " ";
          pos++;
        } else {
          result1 = null;
          if (reportFailures === 0) {
            matchFailed("\" \"");
          }
        }
        while (result1 !== null) {
          result0.push(result1);
          if (input.charCodeAt(pos) === 32) {
            result1 = " ";
            pos++;
          } else {
            result1 = null;
            if (reportFailures === 0) {
              matchFailed("\" \"");
            }
          }
        }
        if (result0 !== null) {
          result0 = (function(offset, ws) { return ws.join(""); })(pos0, result0);
        }
        if (result0 === null) {
          pos = pos0;
        }
        return result0;
      }
      
      function parse_add_op() {
        var result0;
        
        if (input.charCodeAt(pos) === 43) {
          result0 = "+";
          pos++;
        } else {
          result0 = null;
          if (reportFailures === 0) {
            matchFailed("\"+\"");
          }
        }
        if (result0 === null) {
          if (input.charCodeAt(pos) === 45) {
            result0 = "-";
            pos++;
          } else {
            result0 = null;
            if (reportFailures === 0) {
              matchFailed("\"-\"");
            }
          }
        }
        return result0;
      }
      
      function parse_mul_op() {
        var result0;
        
        if (input.charCodeAt(pos) === 42) {
          result0 = "*";
          pos++;
        } else {
          result0 = null;
          if (reportFailures === 0) {
            matchFailed("\"*\"");
          }
        }
        if (result0 === null) {
          if (input.charCodeAt(pos) === 47) {
            result0 = "/";
            pos++;
          } else {
            result0 = null;
            if (reportFailures === 0) {
              matchFailed("\"/\"");
            }
          }
        }
        return result0;
      }
      
      function parse_unary_op() {
        var result0;
        
        if (input.charCodeAt(pos) === 43) {
          result0 = "+";
          pos++;
        } else {
          result0 = null;
          if (reportFailures === 0) {
            matchFailed("\"+\"");
          }
        }
        if (result0 === null) {
          if (input.charCodeAt(pos) === 45) {
            result0 = "-";
            pos++;
          } else {
            result0 = null;
            if (reportFailures === 0) {
              matchFailed("\"-\"");
            }
          }
        }
        return result0;
      }
      
      function parse_func_name() {
        var result0, result1;
        var pos0;
        
        pos0 = pos;
        if (/^[a-zA-Z]/.test(input.charAt(pos))) {
          result1 = input.charAt(pos);
          pos++;
        } else {
          result1 = null;
          if (reportFailures === 0) {
            matchFailed("[a-zA-Z]");
          }
        }
        if (result1 !== null) {
          result0 = [];
          while (result1 !== null) {
            result0.push(result1);
            if (/^[a-zA-Z]/.test(input.charAt(pos))) {
              result1 = input.charAt(pos);
              pos++;
            } else {
              result1 = null;
              if (reportFailures === 0) {
                matchFailed("[a-zA-Z]");
              }
            }
          }
        } else {
          result0 = null;
        }
        if (result0 !== null) {
          result0 = (function(offset, name) { return name.join(""); })(pos0, result0);
        }
        if (result0 === null) {
          pos = pos0;
        }
        return result0;
      }
      
      function parse_variable() {
        var result0;
        var pos0;
        
        pos0 = pos;
        if (input.charCodeAt(pos) === 120) {
          result0 = "x";
          pos++;
        } else {
          result0 = null;
          if (reportFailures === 0) {
            matchFailed("\"x\"");
          }
        }
        if (result0 !== null) {
          result0 = (function(offset, v) { return [v]; })(pos0, result0);
        }
        if (result0 === null) {
          pos = pos0;
        }
        return result0;
      }
      
      function parse_additive() {
        var result0, result1, result2, result3, result4;
        var pos0;
        
        pos0 = pos;
        result0 = parse_multiplicative();
        if (result0 !== null) {
          result1 = parse__();
          result1 = result1 !== null ? result1 : "";
          if (result1 !== null) {
            result2 = parse_add_op();
            if (result2 !== null) {
              result3 = parse__();
              result3 = result3 !== null ? result3 : "";
              if (result3 !== null) {
                result4 = parse_additive();
                if (result4 !== null) {
                  result0 = [result0, result1, result2, result3, result4];
                } else {
                  result0 = null;
                  pos = pos0;
                }
              } else {
                result0 = null;
                pos = pos0;
              }
            } else {
              result0 = null;
              pos = pos0;
            }
          } else {
            result0 = null;
            pos = pos0;
          }
        } else {
          result0 = null;
          pos = pos0;
        }
        if (result0 === null) {
          result0 = parse_multiplicative();
        }
        return result0;
      }
      
      function parse_multiplicative() {
        var result0, result1, result2, result3, result4;
        var pos0;
        
        pos0 = pos;
        result0 = parse_func_call();
        if (result0 !== null) {
          result1 = parse__();
          result1 = result1 !== null ? result1 : "";
          if (result1 !== null) {
            result2 = parse_mul_op();
            if (result2 !== null) {
              result3 = parse__();
              result3 = result3 !== null ? result3 : "";
              if (result3 !== null) {
                result4 = parse_multiplicative();
                if (result4 !== null) {
                  result0 = [result0, result1, result2, result3, result4];
                } else {
                  result0 = null;
                  pos = pos0;
                }
              } else {
                result0 = null;
                pos = pos0;
              }
            } else {
              result0 = null;
              pos = pos0;
            }
          } else {
            result0 = null;
            pos = pos0;
          }
        } else {
          result0 = null;
          pos = pos0;
        }
        if (result0 === null) {
          result0 = parse_func_call();
        }
        return result0;
      }
      
      function parse_func_call() {
        var result0, result1, result2, result3;
        var pos0, pos1;
        
        pos0 = pos;
        pos1 = pos;
        result0 = parse_func_name();
        if (result0 !== null) {
          if (input.charCodeAt(pos) === 40) {
            result1 = "(";
            pos++;
          } else {
            result1 = null;
            if (reportFailures === 0) {
              matchFailed("\"(\"");
            }
          }
          if (result1 !== null) {
            result2 = parse_param_list();
            if (result2 !== null) {
              if (input.charCodeAt(pos) === 41) {
                result3 = ")";
                pos++;
              } else {
                result3 = null;
                if (reportFailures === 0) {
                  matchFailed("\")\"");
                }
              }
              if (result3 !== null) {
                result0 = [result0, result1, result2, result3];
              } else {
                result0 = null;
                pos = pos1;
              }
            } else {
              result0 = null;
              pos = pos1;
            }
          } else {
            result0 = null;
            pos = pos1;
          }
        } else {
          result0 = null;
          pos = pos1;
        }
        if (result0 !== null) {
          result0 = (function(offset, result) { return flatten(result); })(pos0, result0);
        }
        if (result0 === null) {
          pos = pos0;
        }
        if (result0 === null) {
          result0 = parse_primary();
        }
        return result0;
      }
      
      function parse_param_list() {
        var result0, result1, result2, result3, result4, result5;
        var pos0, pos1, pos2;
        
        pos0 = pos;
        pos1 = pos;
        pos2 = pos;
        result0 = parse__();
        result0 = result0 !== null ? result0 : "";
        if (result0 !== null) {
          result1 = parse_additive();
          if (result1 !== null) {
            result2 = parse__();
            result2 = result2 !== null ? result2 : "";
            if (result2 !== null) {
              result0 = [result0, result1, result2];
            } else {
              result0 = null;
              pos = pos2;
            }
          } else {
            result0 = null;
            pos = pos2;
          }
        } else {
          result0 = null;
          pos = pos2;
        }
        if (result0 !== null) {
          result1 = [];
          pos2 = pos;
          if (input.charCodeAt(pos) === 44) {
            result2 = ",";
            pos++;
          } else {
            result2 = null;
            if (reportFailures === 0) {
              matchFailed("\",\"");
            }
          }
          if (result2 !== null) {
            result3 = parse__();
            result3 = result3 !== null ? result3 : "";
            if (result3 !== null) {
              result4 = parse_additive();
              if (result4 !== null) {
                result5 = parse__();
                result5 = result5 !== null ? result5 : "";
                if (result5 !== null) {
                  result2 = [result2, result3, result4, result5];
                } else {
                  result2 = null;
                  pos = pos2;
                }
              } else {
                result2 = null;
                pos = pos2;
              }
            } else {
              result2 = null;
              pos = pos2;
            }
          } else {
            result2 = null;
            pos = pos2;
          }
          while (result2 !== null) {
            result1.push(result2);
            pos2 = pos;
            if (input.charCodeAt(pos) === 44) {
              result2 = ",";
              pos++;
            } else {
              result2 = null;
              if (reportFailures === 0) {
                matchFailed("\",\"");
              }
            }
            if (result2 !== null) {
              result3 = parse__();
              result3 = result3 !== null ? result3 : "";
              if (result3 !== null) {
                result4 = parse_additive();
                if (result4 !== null) {
                  result5 = parse__();
                  result5 = result5 !== null ? result5 : "";
                  if (result5 !== null) {
                    result2 = [result2, result3, result4, result5];
                  } else {
                    result2 = null;
                    pos = pos2;
                  }
                } else {
                  result2 = null;
                  pos = pos2;
                }
              } else {
                result2 = null;
                pos = pos2;
              }
            } else {
              result2 = null;
              pos = pos2;
            }
          }
          if (result1 !== null) {
            result0 = [result0, result1];
          } else {
            result0 = null;
            pos = pos1;
          }
        } else {
          result0 = null;
          pos = pos1;
        }
        if (result0 !== null) {
          result0 = (function(offset, head, tail) { return flatten([head].concat(tail)); })(pos0, result0[0], result0[1]);
        }
        if (result0 === null) {
          pos = pos0;
        }
        return result0;
      }
      
      function parse_primary() {
        var result0, result1, result2, result3, result4;
        var pos0;
        
        result0 = parse_number();
        if (result0 === null) {
          result0 = parse_variable();
          if (result0 === null) {
            pos0 = pos;
            if (input.charCodeAt(pos) === 40) {
              result0 = "(";
              pos++;
            } else {
              result0 = null;
              if (reportFailures === 0) {
                matchFailed("\"(\"");
              }
            }
            if (result0 !== null) {
              result1 = parse__();
              result1 = result1 !== null ? result1 : "";
              if (result1 !== null) {
                result2 = parse_additive();
                if (result2 !== null) {
                  result3 = parse__();
                  result3 = result3 !== null ? result3 : "";
                  if (result3 !== null) {
                    if (input.charCodeAt(pos) === 41) {
                      result4 = ")";
                      pos++;
                    } else {
                      result4 = null;
                      if (reportFailures === 0) {
                        matchFailed("\")\"");
                      }
                    }
                    if (result4 !== null) {
                      result0 = [result0, result1, result2, result3, result4];
                    } else {
                      result0 = null;
                      pos = pos0;
                    }
                  } else {
                    result0 = null;
                    pos = pos0;
                  }
                } else {
                  result0 = null;
                  pos = pos0;
                }
              } else {
                result0 = null;
                pos = pos0;
              }
            } else {
              result0 = null;
              pos = pos0;
            }
          }
        }
        return result0;
      }
      
      function parse_number() {
        var result0, result1, result2, result3, result4;
        var pos0, pos1;
        
        pos0 = pos;
        pos1 = pos;
        result0 = parse_unary_op();
        result0 = result0 !== null ? result0 : "";
        if (result0 !== null) {
          result1 = [];
          if (/^[0-9]/.test(input.charAt(pos))) {
            result2 = input.charAt(pos);
            pos++;
          } else {
            result2 = null;
            if (reportFailures === 0) {
              matchFailed("[0-9]");
            }
          }
          while (result2 !== null) {
            result1.push(result2);
            if (/^[0-9]/.test(input.charAt(pos))) {
              result2 = input.charAt(pos);
              pos++;
            } else {
              result2 = null;
              if (reportFailures === 0) {
                matchFailed("[0-9]");
              }
            }
          }
          if (result1 !== null) {
            if (input.charCodeAt(pos) === 46) {
              result2 = ".";
              pos++;
            } else {
              result2 = null;
              if (reportFailures === 0) {
                matchFailed("\".\"");
              }
            }
            if (result2 !== null) {
              result3 = [];
              if (/^[0-9]/.test(input.charAt(pos))) {
                result4 = input.charAt(pos);
                pos++;
              } else {
                result4 = null;
                if (reportFailures === 0) {
                  matchFailed("[0-9]");
                }
              }
              while (result4 !== null) {
                result3.push(result4);
                if (/^[0-9]/.test(input.charAt(pos))) {
                  result4 = input.charAt(pos);
                  pos++;
                } else {
                  result4 = null;
                  if (reportFailures === 0) {
                    matchFailed("[0-9]");
                  }
                }
              }
              if (result3 !== null) {
                result0 = [result0, result1, result2, result3];
              } else {
                result0 = null;
                pos = pos1;
              }
            } else {
              result0 = null;
              pos = pos1;
            }
          } else {
            result0 = null;
            pos = pos1;
          }
        } else {
          result0 = null;
          pos = pos1;
        }
        if (result0 !== null) {
          result0 = (function(offset, u, d1, d2) { return u + d1.join("") + "." + d2.join("")})(pos0, result0[0], result0[1], result0[3]);
        }
        if (result0 === null) {
          pos = pos0;
        }
        return result0;
      }
      
      
      function cleanupExpected(expected) {
        expected.sort();
        
        var lastExpected = null;
        var cleanExpected = [];
        for (var i = 0; i < expected.length; i++) {
          if (expected[i] !== lastExpected) {
            cleanExpected.push(expected[i]);
            lastExpected = expected[i];
          }
        }
        return cleanExpected;
      }
      
      function computeErrorPosition() {
        /*
         * The first idea was to use |String.split| to break the input up to the
         * error position along newlines and derive the line and column from
         * there. However IE's |split| implementation is so broken that it was
         * enough to prevent it.
         */
        
        var line = 1;
        var column = 1;
        var seenCR = false;
        
        for (var i = 0; i < Math.max(pos, rightmostFailuresPos); i++) {
          var ch = input.charAt(i);
          if (ch === "\n") {
            if (!seenCR) { line++; }
            column = 1;
            seenCR = false;
          } else if (ch === "\r" || ch === "\u2028" || ch === "\u2029") {
            line++;
            column = 1;
            seenCR = true;
          } else {
            column++;
            seenCR = false;
          }
        }
        
        return { line: line, column: column };
      }
      
      
      function flatten(x) {
        return x.reduce(function(a, b) {
          if (!Array.isArray(a)) a = [a];
          return a.concat(b);
        })
      }
      
      
      var result = parseFunctions[startRule]();
      
      /*
       * The parser is now in one of the following three states:
       *
       * 1. The parser successfully parsed the whole input.
       *
       *    - |result !== null|
       *    - |pos === input.length|
       *    - |rightmostFailuresExpected| may or may not contain something
       *
       * 2. The parser successfully parsed only a part of the input.
       *
       *    - |result !== null|
       *    - |pos < input.length|
       *    - |rightmostFailuresExpected| may or may not contain something
       *
       * 3. The parser did not successfully parse any part of the input.
       *
       *   - |result === null|
       *   - |pos === 0|
       *   - |rightmostFailuresExpected| contains at least one failure
       *
       * All code following this comment (including called functions) must
       * handle these states.
       */
      if (result === null || pos !== input.length) {
        var offset = Math.max(pos, rightmostFailuresPos);
        var found = offset < input.length ? input.charAt(offset) : null;
        var errorPosition = computeErrorPosition();
        
        throw new this.SyntaxError(
          cleanupExpected(rightmostFailuresExpected),
          found,
          offset,
          errorPosition.line,
          errorPosition.column
        );
      }
      
      return result;
    },
    
    /* Returns the parser source code. */
    toSource: function() { return this._source; }
  };
  
  /* Thrown when a parser encounters a syntax error. */
  
  result.SyntaxError = function(expected, found, offset, line, column) {
    function buildMessage(expected, found) {
      var expectedHumanized, foundHumanized;
      
      switch (expected.length) {
        case 0:
          expectedHumanized = "end of input";
          break;
        case 1:
          expectedHumanized = expected[0];
          break;
        default:
          expectedHumanized = expected.slice(0, expected.length - 1).join(", ")
            + " or "
            + expected[expected.length - 1];
      }
      
      foundHumanized = found ? quote(found) : "end of input";
      
      return "Expected " + expectedHumanized + " but " + foundHumanized + " found.";
    }
    
    this.name = "SyntaxError";
    this.expected = expected;
    this.found = found;
    this.message = buildMessage(expected, found);
    this.offset = offset;
    this.line = line;
    this.column = column;
  };
  
  result.SyntaxError.prototype = Error.prototype;
  
  return result;
})();}, "storage": function(exports, require, module) {(function() {
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
    },
    relativeMouseMove: function(div, callback) {
      var $div;
      $div = $(div);
      return $div.mousemove(function(e) {
        var offset, position, size;
        offset = $div.offset();
        position = [e.clientX - offset.left, e.clientY - offset.top];
        size = [$div.width(), $div.height()];
        return callback(position, size);
      });
    },
    syntaxHighlight: function(div) {
      var $div;
      $div = $(div);
      return $div.each(function() {
        CodeMirror.runMode($(this).text(), "text/x-glsl", this);
        return $(this).addClass("cm-s-default");
      });
    }
  };

}).call(this);
}, "webcam": function(exports, require, module) {(function() {
  var askForCam, streaming, video;

  video = null;

  streaming = false;

  askForCam = function() {
    var error, success;
    success = function(stream) {
      console.log("received stream");
      if (navigator.mozGetUserMedia !== void 0) {
        video.src = stream;
      } else {
        video.src = window.URL.createObjectURL(stream);
      }
      video.play();
      return streaming = true;
    };
    error = function(err) {
      alert('Webcam required');
      return console.log(err);
    };
    return navigator.getUserMedia({
      video: true
    }, success, error);
  };

  module.exports = function() {
    window.URL = window.URL || window.webkitURL || window.mozURL || window.msURL;
    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia;
    if (!video) {
      video = document.createElement('video');
      video.width = 640;
      video.height = 480;
      setTimeout(askForCam, 200);
    }
    if (streaming && video.readyState === 4) {
      return video;
    } else {
      return false;
    }
  };

}).call(this);
}});
