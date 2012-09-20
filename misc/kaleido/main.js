(function() {
  var facingIntoNormal, makeKaleido, makeKaleidos, mirror1, mirror2, mirror3, mirror4, n, normalize, reflect, unitVector;

  n = numeric;

  unitVector = function(angle) {
    return [Math.cos(angle), Math.sin(angle)];
  };

  normalize = function(v) {
    return n.div(v, n.norm2(v));
  };

  facingIntoNormal = function(incident, normal) {
    return n.dot(incident, normal) < 0;
  };

  reflect = function(incident, normal) {
    return n.sub(incident, n.mul(2, n.mul(n.dot(normal, incident), normal)));
  };

  makeKaleido = function(div, mirrors, renderedImg) {
    var $div, drawLines, intersectMirrors, lineCanvas, lineCtx, picCanvas, picCtx, reflectImage;
    intersectMirrors = function(source, incident) {
      var minRatio, mirror, newIncident, newSource, ratio, reflectedRay, target, _i, _len;
      newSource = false;
      newIncident = false;
      minRatio = Infinity;
      for (_i = 0, _len = mirrors.length; _i < _len; _i++) {
        mirror = mirrors[_i];
        if (facingIntoNormal(incident, mirror.normal)) {
          ratio = n.dot(n.sub(mirror.position, source), mirror.normal) / n.dot(incident, mirror.normal);
          if (ratio >= 0 && ratio < 1) {
            if (ratio < minRatio) {
              minRatio = ratio;
              newSource = n.add(source, n.mul(incident, ratio));
              reflectedRay = reflect(incident, mirror.normal);
              newIncident = n.mul(reflectedRay, 1 - ratio);
            }
          }
        }
      }
      if (newSource === false) {
        target = n.add(source, incident);
        return [target, [0, 0]];
      } else {
        return [newSource, newIncident];
      }
    };
    reflectImage = function(ctx) {
      var i, imageData, incident, newX, newY, pixels, source, x, y, _ref;
      ctx.drawImage(img, 0, 0);
      imageData = ctx.getImageData(0, 0, 600, 600);
      pixels = imageData.data;
      for (x = 0; x < 600; x++) {
        for (y = 0; y < 600; y++) {
          source = [300, 300];
          incident = n.sub([x, y], source);
          while (!(incident[0] === 0 && incident[1] === 0)) {
            _ref = intersectMirrors(source, incident), source = _ref[0], incident = _ref[1];
          }
          newX = Math.round(source[0]);
          newY = Math.round(source[1]);
          if (!(x === newX && y === newY)) {
            for (i = 0; i < 3; i++) {
              pixels[(y * 600 + x) * 4 + i] = pixels[(newY * 600 + newX) * 4 + i];
            }
            pixels[(y * 600 + x) * 4 + 3] = 180;
          }
        }
      }
      return ctx.putImageData(imageData, 0, 0);
    };
    drawLines = function(ctx, e) {
      var center, incident, offset, p, source, _ref;
      offset = $(e.target).offset();
      p = n.sub([e.pageX, e.pageY], [offset.left, offset.top]);
      center = [300, 300];
      ctx.clearRect(0, 0, 600, 600);
      source = center;
      incident = n.sub(p, center);
      ctx.strokeStyle = "#0f0";
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo.apply(ctx, source);
      while (!(incident[0] === 0 && incident[1] === 0)) {
        _ref = intersectMirrors(source, incident), source = _ref[0], incident = _ref[1];
        ctx.lineTo.apply(ctx, source);
      }
      ctx.stroke();
      ctx.strokeStyle = "#f00";
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo.apply(ctx, center);
      ctx.lineTo.apply(ctx, p);
      return ctx.stroke();
    };
    $div = $(div);
    if (renderedImg) {
      $div.append("<img src='" + renderedImg + "' width='600' height='600' />");
    } else {
      picCanvas = $("<canvas width='600' height='600'></canvas>");
      $div.append(picCanvas);
      picCtx = picCanvas[0].getContext("2d");
      reflectImage(picCtx);
    }
    lineCanvas = $("<canvas width='600' height='600'></canvas>");
    $div.append(lineCanvas);
    lineCtx = lineCanvas[0].getContext("2d");
    lineCanvas.mousemove(function(e) {
      return drawLines(lineCtx, e);
    });
    return lineCanvas.mouseout(function(e) {
      return lineCtx.clearRect(0, 0, 600, 600);
    });
  };

  mirror1 = {
    position: [250, 250],
    normal: [1, 0]
  };

  mirror2 = {
    position: [250, 250],
    normal: [0, 1]
  };

  mirror3 = {
    position: [350, 350],
    normal: normalize([-1, -1.5])
  };

  mirror4 = {
    position: [350, 300],
    normal: normalize([-1, 0.2])
  };

  makeKaleidos = function() {
    makeKaleido("#k1", [mirror1], "k1.jpg");
    makeKaleido("#k2", [mirror1, mirror2], "k2.jpg");
    makeKaleido("#k3", [mirror1, mirror2, mirror3], "k3.jpg");
    return makeKaleido("#k4", [mirror1, mirror2, mirror3, mirror4], "k4.jpg");
  };

  makeKaleidos();

}).call(this);
