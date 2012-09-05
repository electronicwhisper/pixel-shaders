(function() {
  var canvas, cm, errorLines, gl, refresh, renderer;

  canvas = document.getElementById("canvas");

  gl = canvas.getContext("experimental-webgl", {
    premultipliedAlpha: false
  });

  window.renderer = renderer = flatRenderer(gl);

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

  cm = CodeMirror(document.getElementById("rasterCode"), {
    value: "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = position.x;\n  gl_FragColor.g = 0.0;\n  gl_FragColor.b = 0.0;\n  gl_FragColor.a = 1.0;\n}",
    mode: "text/x-glsl",
    lineNumbers: true,
    onChange: refresh
  });

  refresh();

}).call(this);
