(function() {
  var buildEnv, parseShaderError, parseUniforms, start, tex0,
    __hasProp = Object.prototype.hasOwnProperty;

  tex0 = new Image();

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

  parseUniforms = function(src) {
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
  };

  buildEnv = function(opts) {
    var $canvas, $uniforms, appendDiv, canvas, cm, code, codeChange, convert, draw, env, errorLines, gl, inspectorHint, makeSpaces, originalValue, renderer, round, src, supplement, supplementOff, uniformGetters, uniforms, update, updateWithEvent;
    src = opts.src;
    appendDiv = $(opts.append || "body");
    inspectorHint = opts.inspector;
    supplement = opts.supplement;
    supplementOff = opts.supplementOff;
    env = $("<div class='env'>\n  <div class='canvas'>\n    <canvas class='maincanvas' width='300' height='300'></canvas>\n    <canvas class='supplementcanvas' width='300' height='300'></canvas>\n  </div>\n  <div class='uniforms'></div>\n  <div class='code'></div>\n</div>");
    appendDiv.append(env);
    canvas = env.find(".maincanvas")[0];
    code = env.find(".code")[0];
    $uniforms = env.find(".uniforms");
    gl = canvas.getContext("experimental-webgl", {
      premultipliedAlpha: false
    });
    renderer = flatRenderer(gl);
    uniforms = [];
    uniformGetters = {};
    errorLines = [];
    draw = function() {
      var getter, name;
      for (name in uniformGetters) {
        if (!__hasProp.call(uniformGetters, name)) continue;
        getter = uniformGetters[name];
        renderer.setUniform(name, getter());
      }
      return renderer.draw();
    };
    codeChange = function() {
      var err, error, errors, line, newUniforms, _i, _j, _len, _len2, _results;
      newUniforms = parseUniforms(cm.getValue());
      if (!_.isEqual(uniforms, newUniforms)) {
        uniforms = newUniforms;
        uniformGetters = {};
        $uniforms.html("");
        uniforms.forEach(function(u) {
          var $u, getter, input;
          if (u.type === "float") {
            input = $("<input type='range' min='0' max='1' step='.0001'>");
            input.change(draw);
            getter = function() {
              return parseFloat(input.val());
            };
          } else if (u.type === "sampler2D") {
            input = $("<img src='tex0.jpg' width='60' height='60'>");
            getter = false;
          }
          $u = $("<div class=\"uniform\">\n  <div class=\"name\">" + u.name + "</div>\n  <div class=\"input\"></div>\n</div>");
          $u.find(".input").append(input);
          $uniforms.append($u);
          if (getter) return uniformGetters[u.name] = getter;
        });
      }
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
          _results.push(cm.setMarker(line, "<div class='errorMessage'>" + error.error + "</div>%N%", "errorMarker"));
        }
        return _results;
      } else {
        renderer.link();
        return draw();
      }
    };
    cm = CodeMirror(code, {
      value: src,
      mode: "text/x-glsl",
      lineNumbers: true,
      onChange: codeChange
    });
    codeChange();
    if (inspectorHint) {
      makeSpaces = function(num) {
        var i;
        return ((function() {
          var _results;
          _results = [];
          for (i = 0; 0 <= num ? i < num : i > num; 0 <= num ? i++ : i--) {
            _results.push(" ");
          }
          return _results;
        })()).join("");
      };
      round = function(n) {
        return Math.round(n * 10000) / 10000;
      };
      convert = function(n) {
        if (typeof n === "number") {
          return round(n);
        } else if (typeof n === "string") {
          return n;
        } else {
          return "vec" + n.length + "(" + (n.map(round).join(', ')) + ")";
        }
      };
      originalValue = src;
      update = function(x, y) {
        var hints, i, line, lines, maxLength, newLines, _i, _len, _len2;
        lines = originalValue.split("\n");
        maxLength = 0;
        for (_i = 0, _len = lines.length; _i < _len; _i++) {
          line = lines[_i];
          if (line.length > maxLength) maxLength = line.length;
        }
        newLines = [];
        if (originalValue === src) {
          hints = inspectorHint(x, y);
        } else {
          hints = ["(This mockup only shows line-by-line", "evaluation on the original code.)"];
        }
        for (i = 0, _len2 = lines.length; i < _len2; i++) {
          line = lines[i];
          if (hints[i] || hints[i] === 0) {
            newLines.push("" + line + (makeSpaces(maxLength - line.length)) + "  // " + (convert(hints[i])));
          } else {
            newLines.push(line);
          }
        }
        return cm.setValue(newLines.join("\n"));
      };
      $canvas = env.find(".canvas");
      updateWithEvent = function(e) {
        var offset, supplementCtx, x, y;
        offset = $canvas.offset();
        x = (e.pageX - offset.left + 0.5) / $canvas.width();
        y = 1 - (e.pageY - offset.top + 0.5) / $canvas.height();
        update(x, y);
        if (supplement) {
          supplementCtx = env.find(".supplementcanvas")[0].getContext("2d");
          return supplement(cm, supplementCtx, x, y);
        }
      };
      $canvas.mouseover(function(e) {
        return originalValue = cm.getValue();
      });
      $canvas.mousemove(function(e) {
        return updateWithEvent(e);
      });
      $canvas.mouseout(function(e) {
        var supplementCtx;
        cm.setValue(originalValue);
        if (supplementOff) {
          supplementCtx = env.find(".supplementcanvas")[0].getContext("2d");
          return supplementOff(cm, supplementCtx);
        }
      });
      return $canvas.click(function(e) {
        cm.setValue(src);
        originalValue = src;
        return updateWithEvent(e);
      });
    }
  };

  start = function() {
    buildEnv({
      append: "#example-live-code",
      src: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = position.x;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = position.y;\n  gl_FragColor.a = 1.0;\n}"
    });
    return buildEnv({
      append: "#example-line-by-line",
      src: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  vec2 p = position - vec2(0.5, 0.5);\n  \n  float radius = length(p);\n  float angle = atan(p.y, p.x);\n  \n  gl_FragColor.r = radius;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = abs(angle / 3.14159);\n  gl_FragColor.a = 1.0;\n}",
      inspector: function(x, y) {
        var angle, p, radius;
        p = [x - 0.5, y - 0.5];
        radius = Math.sqrt(p[0] * p[0] + p[1] * p[1]);
        angle = Math.atan2(p[1], p[0]);
        return [false, false, [x, y], false, false, p, false, radius, angle, false, radius, 0, Math.abs(angle / 3.14159), 1, false];
      },
      supplement: function(cm, ctx, x, y) {
        var a, r;
        cm.setLineClass(7, null, "iso-1");
        cm.setMarker(7, "%N%", "iso-1");
        cm.setLineClass(8, null, "iso-2");
        cm.setMarker(8, "%N%", "iso-2");
        ctx.clearRect(0, 0, 300, 300);
        x = x - 0.5;
        y = 1 - y - 0.5;
        r = Math.sqrt(x * x + y * y);
        a = Math.atan(y, x);
        ctx.strokeStyle = "#f00";
        ctx.beginPath();
        ctx.arc(150, 150, r * 300, 0, Math.PI * 2, false);
        ctx.stroke();
        ctx.strokeStyle = "#0f0";
        ctx.beginPath();
        ctx.moveTo(150, 150);
        ctx.lineTo(150 + x * 600 / r, 150 + y * 600 / r);
        return ctx.stroke();
      },
      supplementOff: function(cm, ctx) {
        cm.setLineClass(7, null, null);
        cm.clearMarker(7);
        cm.setLineClass(8, null, null);
        cm.clearMarker(8);
        return ctx.clearRect(0, 0, 300, 300);
      }
    });
  };

  tex0.onload = start;

  tex0.src = "tex0.jpg";

}).call(this);
