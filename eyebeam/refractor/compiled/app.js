
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
}).call(this)({"ReactiveScope": function(exports, require, module) {(function() {
  var ReactiveScope, Watcher, deepClone, isPlainObject,
    __hasProp = {}.hasOwnProperty,
    __slice = [].slice;

  isPlainObject = function(o) {
    return o !== void 0 && o.constructor === Object;
  };

  deepClone = function(o) {
    var k, result, v;
    if (_.isArray(o)) {
      return _.map(o, deepClone);
    } else if (isPlainObject(o)) {
      result = {};
      for (k in o) {
        if (!__hasProp.call(o, k)) continue;
        v = o[k];
        result[k] = deepClone(v);
      }
      return result;
    } else {
      return o;
    }
  };

  Watcher = (function() {

    function Watcher(watchFn, callback) {
      this.watchFn = watchFn;
      this.callback = callback;
      this._oldValue = void 0;
      this.update();
    }

    Watcher.prototype.update = function() {
      var newValue, updated;
      newValue = this.watchFn();
      updated = !_.isEqual(this._oldValue, newValue);
      this._oldValue = newValue;
      return updated;
    };

    return Watcher;

  })();

  ReactiveScope = (function() {

    function ReactiveScope(initial) {
      var k, v;
      this._watchers = [];
      for (k in initial) {
        if (!__hasProp.call(initial, k)) continue;
        v = initial[k];
        this[k] = v;
      }
    }

    ReactiveScope.prototype.watch = function() {
      var args, callback, remover, watchExprs, watchFn, watcher;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      callback = _.last(args);
      watchExprs = _.initial(args);
      watchFn = _.bind(function() {
        var result, watchExpr;
        result = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = watchExprs.length; _i < _len; _i++) {
            watchExpr = watchExprs[_i];
            if (_.isString(watchExpr)) {
              _results.push(this[watchExpr]);
            } else if (_.isFunction(watchExpr)) {
              _results.push(watchExpr());
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        }).call(this);
        return deepClone(result);
      }, this);
      watcher = new Watcher(watchFn, callback);
      this._watchers.push(watcher);
      remover = _.bind(function() {
        return this._watchers = _.without(this._watchers, watcher);
      }, this);
      return remover;
    };

    ReactiveScope.prototype.apply = function(fn) {
      var result;
      result = fn();
      this.digest();
      return result;
    };

    ReactiveScope.prototype.digest = function() {
      var callback, callbacks, digestCycles, dirty, updated, watcher, _i, _len, _ref, _results;
      dirty = true;
      digestCycles = 0;
      _results = [];
      while (dirty) {
        digestCycles++;
        if (digestCycles > 10) {
          throw "Maximum digest cycles (10) exceeded.";
        }
        dirty = false;
        callbacks = [];
        _ref = this._watchers;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          watcher = _ref[_i];
          updated = watcher.update();
          if (updated) {
            callbacks.push(watcher.callback);
            dirty = true;
          }
        }
        _results.push((function() {
          var _j, _len1, _results1;
          _results1 = [];
          for (_j = 0, _len1 = callbacks.length; _j < _len1; _j++) {
            callback = callbacks[_j];
            _results1.push(callback());
          }
          return _results1;
        })());
      }
      return _results;
    };

    return ReactiveScope;

  })();

  module.exports = ReactiveScope;

}).call(this);
}, "app": function(exports, require, module) {(function() {
  var $c, canvas, changeImage, imageCount, koState, koUpdate, onclick, setCanvasSize, state;

  _.reverse = function(a) {
    return a.slice().reverse();
  };

  $c = $("#c");

  canvas = $c[0];

  setCanvasSize = function() {
    var parentHeight, parentWidth;
    parentWidth = $c.parent().width();
    parentHeight = $c.parent().height();
    $c.css({
      width: parentWidth + "px",
      height: parentHeight + "px"
    });
    canvas.width = parentWidth;
    return canvas.height = parentHeight;
  };

  setCanvasSize();

  require("draw");

  require("touch");

  $(window).on("resize", function() {
    return setCanvasSize();
  });

  imageCount = 4;

  state = require("state");

  onclick = function(selector, fn) {
    return $(document).on("click", selector, fn);
  };

  onclick(".button-add", function(e) {
    var distortion;
    distortion = ko.dataFor(this);
    state.apply(function() {
      var c;
      c = {
        transform: numeric.inv(state.globalTransform),
        distortion: distortion
      };
      state.chain.push(c);
      return state.selected = c;
    });
    return false;
  });

  onclick(".button-remove", function(e) {
    var c;
    c = ko.dataFor(this);
    state.apply(function() {
      return state.chain = _.without(state.chain, c);
    });
    return false;
  });

  onclick(".distortion", function(e) {
    var c;
    c = ko.dataFor(this);
    state.apply(function() {
      return state.selected = c;
    });
    return false;
  });

  onclick("#sidebar", function(e) {
    state.apply(function() {
      return state.selected = false;
    });
    return false;
  });

  changeImage = function(d) {
    return state.apply(function() {
      state.image += d;
      return state.image = (state.image + imageCount) % imageCount;
    });
  };

  onclick(".button-image-prev", function(e) {
    changeImage(-1);
    return false;
  });

  onclick(".button-image-next", function(e) {
    changeImage(1);
    return false;
  });

  onclick(".button-reset", function(e) {
    state.apply(function() {
      state.chain = [];
      return state.globalTransform = numeric.identity(3);
    });
    return false;
  });

  $(document).on("change", "input[type='checkbox']", function(e) {
    return setTimeout(function() {
      return state.apply(function() {
        return true;
      });
    }, 100);
  });

  $(document).on("contextmenu", function(e) {
    return e.preventDefault();
  });

  koState = ko.observable();

  koUpdate = function() {
    return koState(state);
  };

  koUpdate();

  state.watch((function() {
    var _ref;
    return (_ref = state.selected) != null ? _ref.distortion : void 0;
  }), "image", (function() {
    return _.pluck(state.chain, "distortion");
  }), function() {
    return koUpdate();
  });

  ko.applyBindings({
    koState: koState
  });

}).call(this);
}, "bounds": function(exports, require, module) {(function() {

  module.exports = function() {
    var $el, height, width;
    $el = $("#c");
    width = $el.width();
    height = $el.height();
    if (width < height) {
      return {
        boundsMin: [-1, -1 * height / width],
        boundsMax: [1, 1 * height / width]
      };
    } else {
      return {
        boundsMin: [-1 * width / height, -1],
        boundsMax: [1 * width / height, 1]
      };
    }
  };

}).call(this);
}, "draw": function(exports, require, module) {(function() {
  var bounds, canvas, fragmentSrc, generate, image, s, setImage, shader, state, updateImage, updateWebcamImage, vertexSrc, webcam;

  shader = require("shader");

  state = require("state");

  generate = require("generate");

  bounds = require("bounds");

  vertexSrc = "precision highp float;\n\nattribute vec3 vertexPosition;\nvarying vec2 position;\nuniform vec2 boundsMin;\nuniform vec2 boundsMax;\n\nvoid main() {\n  gl_Position = vec4(vertexPosition, 1.0);\n  position = mix(boundsMin, boundsMax, (vertexPosition.xy + 1.0) * 0.5);\n}";

  fragmentSrc = generate.code();

  canvas = $("#c")[0];

  s = shader({
    canvas: canvas,
    vertex: vertexSrc,
    fragment: generate.code(),
    uniforms: generate.uniforms()
  });

  s.set({
    uniforms: require("bounds")()
  });

  webcam = require("webcam");

  webcam();

  updateWebcamImage = function() {
    var webcamImage;
    if (state.image === 0) {
      if (webcamImage = webcam()) {
        s.draw({
          uniforms: {
            image: webcamImage,
            resolution: [canvas.width, canvas.height],
            imageResolution: [webcamImage.width, webcamImage.height]
          }
        });
      }
    } else {
      s.draw({
        uniforms: {
          image: image,
          resolution: [canvas.width, canvas.height],
          imageResolution: [image.width, image.height]
        }
      });
    }
    return requestAnimationFrame(updateWebcamImage);
  };

  updateWebcamImage();

  image = new Image();

  setImage = function(src) {
    return image.src = src;
  };

  updateImage = function() {
    if (state.image !== 0) {
      return setImage("images/" + state.image + ".jpg");
    }
  };

  updateImage();

  state.watch("image", updateImage);

  state.watch("globalTransform", function() {
    return _.pluck(state.chain, "transform");
  }, function() {
    return s.draw({
      uniforms: generate.uniforms()
    });
  });

  state.watch("polarMode", function() {
    return _.pluck(state.chain, "distortion");
  }, function() {
    return s.draw({
      fragment: generate.code(),
      uniforms: generate.uniforms()
    });
  });

}).call(this);
}, "generate": function(exports, require, module) {(function() {
  var flattenMatrix, generate, state;

  state = require("state");

  generate = {};

  generate.code = function() {
    var c, code, f, i, _i, _j, _len, _len1, _ref, _ref1;
    code = "";
    code += "\nprecision highp float;\n\nvarying vec2 position;\nuniform sampler2D image;\nuniform vec2 resolution;\nuniform vec2 imageResolution;\n\nuniform mat3 globalTransform;\n";
    _ref = _.reverse(state.chain);
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      c = _ref[i];
      code += "uniform mat3 m" + i + ";\n";
      code += "uniform mat3 m" + i + "inv;\n";
    }
    code += "\nvoid main() {\n  vec3 p = vec3(position, 1.);\n";
    code += "\n";
    code += "p = globalTransform * p;";
    code += "\n";
    if (state.polarMode) {
      code += "\np.xy = vec2(length(p.xy), atan(p.y, p.x));\n";
    }
    _ref1 = _.reverse(state.chain);
    for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
      c = _ref1[i];
      f = c.distortion.f;
      code += "\n";
      code += "p = m" + i + " * p;\n";
      code += "" + f + ";\n";
      code += "p = m" + i + "inv * p;\n";
      code += "\n";
    }
    if (state.polarMode) {
      code += "\np.xy = vec2(p.x*cos(p.y), p.x*sin(p.y));\n";
    }
    code += "\n  p.xy = (p.xy + 1.) * .5;\n\n  /*\n  if (p.x < 0. || p.x > 1. || p.y < 0. || p.y > 1.) {\n    // black if out of bounds\n    gl_FragColor = vec4(0., 0., 0., 1.);\n  } else {\n    gl_FragColor = texture2D(image, p.xy);\n  }\n  */\n\n  p.x *= (imageResolution.y / imageResolution.x);\n\n  // mirror wrap it\n  p = abs(mod((p-1.), 2.)-1.);\n\n\n\n  gl_FragColor = texture2D(image, p.xy);\n}";
    return code;
  };

  flattenMatrix = function(m) {
    return _.flatten(numeric.transpose(m));
  };

  generate.uniforms = function() {
    var c, i, uniforms, _i, _len, _ref;
    uniforms = {
      globalTransform: flattenMatrix(state.globalTransform)
    };
    _ref = _.reverse(state.chain);
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      c = _ref[i];
      uniforms["m" + i] = flattenMatrix(c.transform);
      uniforms["m" + i + "inv"] = flattenMatrix(numeric.inv(c.transform));
    }
    return uniforms;
  };

  module.exports = generate;

}).call(this);
}, "shader": function(exports, require, module) {
/*
opts
  canvas: Canvas DOM element
  vertex: glsl source string
  fragment: glsl source string
  uniforms: a hash of names to values, the type is inferred as follows:
    Number or [Number]: float
    [Number, Number]: vec2
    [Number, Number, Number]: vec3
    [Number, Number, Number, Number]: vec4
    DOMElement: Sampler2D (e.g. Image/Video/Canvas)
    TODO: a way to force an arbitrary type


to set uniforms,
*/


(function() {
  var __hasProp = {}.hasOwnProperty;

  module.exports = function(opts) {
    var bufferAttribute, draw, getTexture, gl, o, program, replaceShader, set, setUniform, shaders, textures;
    o = {
      vertex: null,
      fragment: null,
      uniforms: {},
      canvas: opts.canvas
    };
    gl = null;
    program = null;
    shaders = {};
    textures = [];
    getTexture = function(element) {
      var i, t, texture, _i, _len;
      for (_i = 0, _len = textures.length; _i < _len; _i++) {
        t = textures[_i];
        if (t.element === element) {
          return t;
        }
      }
      i = textures.length;
      texture = gl.createTexture();
      textures[i] = {
        element: element,
        texture: texture,
        i: i
      };
      gl.activeTexture(gl.TEXTURE0 + i);
      gl.bindTexture(gl.TEXTURE_2D, texture);
      gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
      return textures[i];
    };
    replaceShader = function(src, type) {
      var shader;
      if (shaders[type]) {
        gl.detachShader(program, shaders[type]);
      }
      shader = gl.createShader(type);
      gl.shaderSource(shader, src);
      gl.compileShader(shader);
      gl.attachShader(program, shader);
      gl.deleteShader(shader);
      return shaders[type] = shader;
    };
    bufferAttribute = function(attrib, data, size) {
      var buffer, location;
      if (size == null) {
        size = 2;
      }
      location = gl.getAttribLocation(program, attrib);
      buffer = gl.createBuffer();
      gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
      gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(data), gl.STATIC_DRAW);
      gl.enableVertexAttribArray(location);
      return gl.vertexAttribPointer(location, size, gl.FLOAT, false, 0, 0);
    };
    setUniform = function(name, value) {
      var location, texture;
      location = gl.getUniformLocation(program, name);
      if (_.isNumber(value)) {
        return gl.uniform1fv(location, [value]);
      } else if (_.isArray(value)) {
        switch (value.length) {
          case 1:
            return gl.uniform1fv(location, value);
          case 2:
            return gl.uniform2fv(location, value);
          case 3:
            return gl.uniform3fv(location, value);
          case 4:
            return gl.uniform4fv(location, value);
          case 9:
            return gl.uniformMatrix3fv(location, false, value);
        }
      } else if (value.nodeName) {
        texture = getTexture(value);
        gl.activeTexture(gl.TEXTURE0 + texture.i);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, value);
        return gl.uniform1i(location, texture.i);
      } else if (!value) {
        return false;
      }
    };
    set = function(opts) {
      var name, value, _ref, _ref1, _results;
      if (opts.vertex) {
        o.vertex = opts.vertex;
        replaceShader(o.vertex, gl.VERTEX_SHADER);
      }
      if (opts.fragment) {
        o.fragment = opts.fragment;
        replaceShader(o.fragment, gl.FRAGMENT_SHADER);
      }
      if (opts.vertex || opts.fragment) {
        gl.linkProgram(program);
        gl.useProgram(program);
      }
      if (opts.uniforms) {
        _ref = opts.uniforms;
        for (name in _ref) {
          if (!__hasProp.call(_ref, name)) continue;
          value = _ref[name];
          o.uniforms[name] = value;
          setUniform(name, value);
        }
      }
      if (opts.vertex || opts.fragment) {
        _ref1 = o.uniforms;
        _results = [];
        for (name in _ref1) {
          if (!__hasProp.call(_ref1, name)) continue;
          value = _ref1[name];
          _results.push(setUniform(name, value));
        }
        return _results;
      }
    };
    draw = function(opts) {
      if (opts == null) {
        opts = {};
      }
      set(opts);
      gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);
      return gl.drawArrays(gl.TRIANGLES, 0, 6);
    };
    gl = opts.canvas.getContext("experimental-webgl", {
      premultipliedAlpha: false
    });
    program = gl.createProgram();
    set(opts);
    gl.useProgram(program);
    bufferAttribute("vertexPosition", [-1.0, -1.0, 1.0, -1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0, 1.0, 1.0]);
    draw();
    return {
      get: function() {
        return o;
      },
      set: set,
      draw: draw,
      readPixels: function() {
        var arr, h, w;
        draw();
        w = gl.drawingBufferWidth;
        h = gl.drawingBufferHeight;
        arr = new Uint8Array(w * h * 4);
        gl.readPixels(0, 0, w, h, gl.RGBA, gl.UNSIGNED_BYTE, arr);
        return arr;
      },
      resize: function() {},
      ctx: function() {
        return gl;
      }
    };
  };

}).call(this);
}, "solve": function(exports, require, module) {(function() {
  var solve;

  solve = function(objective, argsToMatrix, startArgs) {
    var error, m, obj, original, solution, uncmin;
    original = argsToMatrix(startArgs);
    obj = function(args) {
      var matrix;
      matrix = argsToMatrix(args);
      return objective(matrix);
    };
    uncmin = numeric.uncmin(obj, startArgs);
    if (isNaN(uncmin.f)) {
      console.warn("NaN");
      return original;
    } else {
      error = obj(uncmin.solution);
      if (error > .000001) {
        console.warn("Error too big", error);
        return original;
      }
      solution = uncmin.solution;
      m = argsToMatrix(solution);
      return m;
    }
  };

  module.exports = solve;

}).call(this);
}, "state": function(exports, require, module) {(function() {
  var ReactiveScope, distortions, state;

  ReactiveScope = require("ReactiveScope");

  distortions = [
    {
      title: "Reflect",
      f: "p.x = abs(p.x)"
    }, {
      title: "Repeat",
      f: "p.x = fract(p.x)"
    }, {
      title: "Clamp",
      f: "p.x = min(p.x, 0.)"
    }, {
      title: "Step",
      f: "p.x = floor(p.x)"
    }, {
      title: "Wave",
      f: "p.x = sin(p.x * 3.14159)"
    }
  ];

  state = new ReactiveScope({
    distortions: distortions,
    chain: [],
    selected: false,
    globalTransform: numeric.identity(3),
    image: 0,
    polarMode: false
  });

  state.watch("selected", "chain", function() {
    if (state.selected && !_.contains(state.chain, state.selected)) {
      return state.selected = false;
    }
  });

  window.state = state;

  module.exports = state;

}).call(this);
}, "touch": function(exports, require, module) {(function() {
  var angleIncrement, applyMatrix, bounds, convertToPolar, dist, getMatrix, lerp, pointerPosition, pointers, scaleIncrement, setMatrix, solve, solveTouch, state, toLocal, tracking, trackingLoop,
    __hasProp = {}.hasOwnProperty;

  solve = require("solve");

  state = require("state");

  bounds = require("bounds");

  dist = function(p1, p2) {
    var d;
    d = numeric['-'](p1, p2);
    return numeric.dot(d, d);
  };

  lerp = function(x, min, max) {
    return min + x * (max - min);
  };

  solveTouch = function(touches) {
    var objective, transform;
    objective = function(m) {
      var currentLocal, error, touch, _i, _len, _ref;
      error = 0;
      _ref = touches.slice(0, 3);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        touch = _ref[_i];
        currentLocal = toLocal(touch.current);
        currentLocal = numeric.dot(m, currentLocal);
        error += dist(touch.original, currentLocal);
      }
      return error;
    };
    if (touches.length === 1) {
      transform = solve(objective, function(_arg) {
        var x, y;
        x = _arg[0], y = _arg[1];
        return [[1, 0, x], [0, 1, y], [0, 0, 1]];
      }, [0, 0]);
    } else if (touches.length === 2) {
      transform = solve(objective, function(_arg) {
        var r, s, x, y;
        s = _arg[0], r = _arg[1], x = _arg[2], y = _arg[3];
        return [[s, r, x], [-r, s, y], [0, 0, 1]];
      }, [1, 0, 0, 0]);
    } else if (touches.length >= 3) {
      transform = solve(objective, function(_arg) {
        var a, b, c, d, x, y;
        a = _arg[0], b = _arg[1], c = _arg[2], d = _arg[3], x = _arg[4], y = _arg[5];
        return [[a, b, x], [c, d, y], [0, 0, 1]];
      }, [1, 0, 0, 1, 0, 0]);
    }
    return transform;
  };

  getMatrix = function() {
    if (state.selected) {
      return numeric.dot(state.selected.transform, state.globalTransform);
    } else {
      return state.globalTransform;
    }
  };

  setMatrix = function(m) {
    if (state.selected) {
      return state.selected.transform = numeric.dot(m, numeric.inv(state.globalTransform));
    } else {
      return state.globalTransform = m;
    }
  };

  convertToPolar = function(v) {
    var a, r;
    r = Math.sqrt(v[0] * v[0] + v[1] * v[1]);
    a = Math.atan2(v[1], v[0]);
    return [r, a, 1];
  };

  toLocal = function(v) {
    v = numeric.dot(state.globalTransform, v);
    if (state.selected) {
      if (state.polarMode) {
        v = convertToPolar(v);
      }
      v = numeric.dot(state.selected.transform, v);
    }
    return v;
  };

  applyMatrix = function(m) {
    if (state.selected) {
      return state.selected.transform = numeric.dot(m, state.selected.transform);
    } else {
      return state.globalTransform = numeric.dot(m, state.globalTransform);
    }
  };

  pointers = {};

  $("#c").on("pointerdown", function(e) {
    e = e.originalEvent;
    return pointers[e.pointerId] = {
      x: e.clientX,
      y: e.clientY
    };
  });

  $("#c").on("pointermove", function(e) {
    var pointer;
    e = e.originalEvent;
    pointer = pointers[e.pointerId];
    if (pointer) {
      pointer.x = event.clientX;
      return pointer.y = event.clientY;
    }
  });

  $("#c").on("pointerup", function(e) {
    e = e.originalEvent;
    return delete pointers[e.pointerId];
  });

  pointerPosition = function(pointer) {
    var $el, b, height, offset, width, x, y;
    $el = $("#c");
    offset = $el.offset();
    width = $el.width();
    height = $el.height();
    x = (pointer.x - offset.left) / width;
    y = 1 - (pointer.y - offset.top) / height;
    b = bounds();
    x = lerp(x, b.boundsMin[0], b.boundsMax[0]);
    y = lerp(y, b.boundsMin[1], b.boundsMax[1]);
    return [x, y, 1];
  };

  tracking = {};

  trackingLoop = function() {
    var id, ids, pointer, t, touches, transform;
    ids = [];
    for (id in pointers) {
      if (!__hasProp.call(pointers, id)) continue;
      pointer = pointers[id];
      ids.push(id);
      if (t = tracking[id]) {
        t.current = pointerPosition(pointer);
      } else {
        t = tracking[id] = {};
        t.current = pointerPosition(pointer);
        t.original = toLocal(t.current);
      }
    }
    tracking = _.pick(tracking, ids);
    touches = _.values(tracking);
    if (touches.length > 0) {
      transform = solveTouch(touches);
      state.apply(function() {
        return applyMatrix(transform);
      });
    }
    return requestAnimationFrame(trackingLoop);
  };

  trackingLoop();

  angleIncrement = 0.02;

  scaleIncrement = 1.02;

  key(",", function(e) {
    var m, r, s;
    s = Math.cos(angleIncrement);
    r = Math.sin(angleIncrement);
    m = [[s, r, 0], [-r, s, 0], [0, 0, 1]];
    return state.apply(function() {
      return applyMatrix(m);
    });
  });

  key(".", function(e) {
    var m, r, s;
    s = Math.cos(-angleIncrement);
    r = Math.sin(-angleIncrement);
    m = [[s, r, 0], [-r, s, 0], [0, 0, 1]];
    return state.apply(function() {
      return applyMatrix(m);
    });
  });

  key("z", function(e) {
    var m, s;
    s = scaleIncrement;
    m = [[s, 0, 0], [0, s, 0], [0, 0, 1]];
    return state.apply(function() {
      return applyMatrix(m);
    });
  });

  key("x", function(e) {
    var m, s;
    s = 1 / scaleIncrement;
    m = [[s, 0, 0], [0, s, 0], [0, 0, 1]];
    return state.apply(function() {
      return applyMatrix(m);
    });
  });

}).call(this);
}, "webcam": function(exports, require, module) {(function() {
  var askForCam, streaming, video;

  video = null;

  streaming = false;

  askForCam = function() {
    var error, success;
    success = function(stream) {
      console.log("received stream");
      video.src = window.URL.createObjectURL(stream);
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
