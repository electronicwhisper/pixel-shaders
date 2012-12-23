// Generated by CoffeeScript 1.4.0
(function() {
  var $, XRegExp, fragmentShaderSource, parseUniforms, vertexShaderSource, _;

  $ = require('jquery');

  _ = require('underscore');

  XRegExp = require('xregexp').XRegExp;

  vertexShaderSource = "precision mediump float;\n\nattribute vec3 vertexPosition;\nvarying vec2 position;\nuniform vec2 boundsMin;\nuniform vec2 boundsMax;\n\nvoid main() {\n  gl_Position = vec4(vertexPosition, 1.0);\n  position = mix(boundsMin, boundsMax, (vertexPosition.xy + 1.0) * 0.5);\n}";

  fragmentShaderSource = "precision mediump float;\n\nvarying vec2 position;\n\nvoid main() {\n  gl_FragColor.r = position.x;\n  gl_FragColor.g = position.y;\n  gl_FragColor.b = 0.0;\n  gl_FragColor.a = 1.0;\n}";

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

  (function() {
    var animate, animated, ctx, editor, pz, shader, shouldAnimate, startTime, uniforms, update;
    shader = require("shader")({
      canvas: $("#c1")[0],
      vertex: vertexShaderSource,
      fragment: fragmentShaderSource,
      uniforms: {
        boundsMin: [0, 0],
        boundsMax: [1, 1]
      }
    });
    pz = require("pan-zoom")({
      element: $("#main")[0],
      minX: 0,
      maxX: 1,
      minY: 0,
      maxY: 1,
      flipY: true
    });
    ctx = $("#c2")[0].getContext("2d");
    update = function() {
      shader.draw({
        uniforms: {
          boundsMin: [pz.minX, pz.minY],
          boundsMax: [pz.maxX, pz.maxY]
        }
      });
      ctx.clearRect(0, 0, 1000, 1000);
      if ($("#showgrid").attr("checked")) {
        return require("graph-grid")({
          ctx: ctx,
          minX: pz.minX,
          maxX: pz.maxX,
          minY: pz.minY,
          maxY: pz.maxY,
          flipY: true,
          color: "255,255,255",
          shadow: true
        });
      }
    };
    $("#resetbounds").on("click", function() {
      pz.minX = 0;
      pz.minY = 0;
      pz.maxX = 1;
      pz.maxY = 1;
      return pz.emit("update");
    });
    pz.on("update", update);
    $("#showgrid").on("change", update);
    update();
    startTime = Date.now();
    animated = false;
    uniforms = [];
    shouldAnimate = function() {
      var uniform, _i, _len;
      for (_i = 0, _len = uniforms.length; _i < _len; _i++) {
        uniform = uniforms[_i];
        if (uniform.name === "time" || uniform.name === "webcam") {
          return true;
        }
      }
      return false;
    };
    editor = require("editor")({
      div: $("#cm")[0],
      multiline: true,
      src: fragmentShaderSource,
      errorCheck: require("glsl-error")
    });
    editor.on("change", function(src) {
      uniforms = parseUniforms(src);
      animated = shouldAnimate();
      return shader.draw({
        fragment: src
      });
    });
    animate = function() {
      var sendUniforms, uniform, _i, _len;
      require("raf")(animate);
      if (animated) {
        sendUniforms = {};
        for (_i = 0, _len = uniforms.length; _i < _len; _i++) {
          uniform = uniforms[_i];
          if (uniform.name === "time") {
            sendUniforms.time = (Date.now() - startTime) / 1000;
          }
          if (uniform.name === "webcam") {
            sendUniforms.webcam = require("webcam")();
          }
        }
        return shader.draw({
          uniforms: sendUniforms
        });
      }
    };
    return animate();
  })();

  (function() {
    var ctx, draw, f, graphEditor, pz, src;
    src = "x";
    f = require("evaluate").functionOfX(src);
    ctx = $("#c3")[0].getContext("2d");
    pz = require("pan-zoom")({
      element: $("#linegraph")[0],
      minX: -2,
      maxX: 2,
      minY: -2,
      maxY: 2,
      flipY: true
    });
    graphEditor = require("editor")({
      div: $("#graph-cm"),
      multiline: false,
      src: "x",
      errorCheck: function(src) {
        f = require("evaluate").functionOfX(src);
        if (f.err || src === "") {
          return [
            {
              lineNum: 0,
              error: ""
            }
          ];
        } else {
          return false;
        }
      }
    });
    draw = function() {
      ctx.clearRect(0, 0, 1000, 1000);
      require("graph-grid")({
        ctx: ctx,
        minX: pz.minX,
        maxX: pz.maxX,
        minY: pz.minY,
        maxY: pz.maxY,
        flipY: true,
        color: "0,0,0",
        shadow: false
      });
      return require("graph-line")({
        ctx: ctx,
        f: f,
        minX: pz.minX,
        maxX: pz.maxX,
        minY: pz.minY,
        maxY: pz.maxY,
        flipY: true
      });
    };
    pz.on("update", draw);
    graphEditor.on("change", function(src) {
      require("deconstruct")({
        div: $("#substitution"),
        src: src
      });
      f = require("evaluate").functionOfX(src);
      return draw();
    });
    graphEditor.emit("change", graphEditor.src());
    return $("#substitution").on("mouseenter", ".deconstruct-node", function() {
      var s;
      s = $(this).text();
      f = require("evaluate").functionOfX(s);
      return draw();
    });
  })();

}).call(this);