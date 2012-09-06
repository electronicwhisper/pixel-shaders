(function() {
  var buildEnv, parseShaderError;

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

  buildEnv = function(src, inspectorHint) {
    var $canvas, canvas, cm, code, convert, env, errorLines, gl, makeSpaces, originalValue, refresh, renderer, update, updateWithEvent;
    env = $("<div class='env'><canvas></canvas><div class='code'></div></div>");
    $("body").append(env);
    canvas = env.find("canvas")[0];
    code = env.find(".code")[0];
    gl = canvas.getContext("experimental-webgl", {
      premultipliedAlpha: false
    });
    renderer = flatRenderer(gl);
    errorLines = [];
    refresh = function() {
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
        renderer.link();
        return renderer.draw();
      }
    };
    cm = CodeMirror(code, {
      value: src,
      mode: "text/x-glsl",
      lineNumbers: true,
      onChange: refresh
    });
    refresh();
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
      convert = function(n) {
        if (typeof n === "number") {
          return n.toFixed(4);
        } else if (typeof n === "string") {
          return n;
        } else {
          return "vec" + n.length + "(" + (n.map(function(x) {
            return x.toFixed(4);
          }).join(', ')) + ")";
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
          hints = ["This mockup can only show line-by-line", "evaluation on the original code."];
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
      $canvas = $(canvas);
      updateWithEvent = function(e) {
        var offset, x, y;
        offset = $canvas.offset();
        x = (e.pageX - offset.left) / $canvas.width();
        y = 1 - (e.pageY - offset.top) / $canvas.height();
        return update(x, y);
      };
      $canvas.mouseover(function(e) {
        return originalValue = cm.getValue();
      });
      $canvas.mousemove(function(e) {
        return updateWithEvent(e);
      });
      $canvas.mouseout(function(e) {
        return cm.setValue(originalValue);
      });
      return $canvas.click(function(e) {
        cm.setValue(src);
        originalValue = src;
        return updateWithEvent(e);
      });
    }
  };

  buildEnv("precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = position.x;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = 0.0;\n  gl_FragColor.a = 1.0;\n}", function(x, y) {
    return [false, false, [x, y], false, false, x, 0, 0, 1, false];
  });

  buildEnv("precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = position.x;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = position.y;\n  gl_FragColor.a = 1.0;\n}", function(x, y) {
    return [false, false, [x, y], false, false, x, 0, y, 1, false];
  });

}).call(this);
