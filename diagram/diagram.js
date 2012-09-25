(function() {
  var canvasToModel, clamp, diagram, getOffset, graphPos, graphSize, makeAdjustable, max, min, modelToCanvas, precision, smoothstep,
    __slice = Array.prototype.slice;

  min = Math.min;

  max = Math.max;

  clamp = function(x, minVal, maxVal) {
    return min(max(x, minVal), maxVal);
  };

  smoothstep = function(edge0, edge1, x) {
    var t;
    t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
  };

  ko.bindingHandlers.canvas = {
    init: function(element, valueAccessor, allBindingsAccessor, viewModel) {
      var ctx, draw;
      ctx = element.getContext("2d");
      draw = valueAccessor();
      return ko.computed(function() {
        return draw(ctx);
      });
    }
  };

  ko.bindingHandlers.position = {
    update: function(element, valueAccessor, allBindingsAccessor) {
      var position;
      position = ko.utils.unwrapObservable(valueAccessor());
      return $(element).css({
        left: position[0],
        top: position[1],
        width: position[2],
        height: position[3]
      });
    }
  };

  precision = 3;

  graphPos = [20, 20];

  graphSize = [300, 200];

  canvasToModel = function(p) {
    return numeric.div(numeric.sub(p, graphPos), graphSize);
  };

  modelToCanvas = function(p) {
    return numeric.add(numeric.mul(p, graphSize), graphPos);
  };

  getOffset = function(el) {
    var offset;
    offset = $(el).parents(".diagram").offset();
    return offset = [offset.left, offset.top];
  };

  makeAdjustable = function(v) {
    var adjustable;
    return adjustable = {
      value: ko.observable(v.toFixed(precision)),
      constrain: function() {
        return [0, 1];
      },
      mousedown: function(data, e) {
        var mousemove, mouseup, offset;
        offset = getOffset(e.target);
        mousemove = function(e) {
          var constrain, newVal, p;
          p = [e.pageX, e.pageY];
          p = canvasToModel(numeric.sub(p, offset));
          constrain = adjustable.constrain();
          newVal = clamp.apply(null, [p[0]].concat(__slice.call(constrain)));
          return adjustable.value(newVal.toFixed(precision));
        };
        mouseup = function(e) {
          $(document).off("mousemove", mousemove);
          return $(document).off("mouseup", mouseup);
        };
        $(document).on("mousemove", mousemove);
        return $(document).on("mouseup", mouseup);
      }
    };
  };

  diagram = {
    canvasToModel: canvasToModel,
    modelToCanvas: modelToCanvas,
    domain: [0, 1],
    range: [0, 1],
    edge0: makeAdjustable(0.3000),
    edge1: makeAdjustable(0.8000),
    x: ko.observable(0),
    y: ko.observable(0),
    mousemove: function(data, e) {
      var offset, p, x, y;
      offset = getOffset(e.target);
      p = numeric.sub([e.pageX, e.pageY], offset);
      p = canvasToModel(p);
      x = clamp(p[0], 0, 1).toFixed(precision);
      y = smoothstep(diagram.edge0.value(), diagram.edge1.value(), x).toFixed(precision);
      diagram.x(x);
      return diagram.y(y);
    },
    draw: function(ctx) {
      var graphHeight, graphWidth, labelOffset, x, xp, y, yp;
      ctx.setTransform(1, 0, 0, 1, 0, 0);
      ctx.clearRect(0, 0, 500, 500);
      labelOffset = 0;
      ctx.translate.apply(ctx, graphPos);
      graphWidth = graphSize[0], graphHeight = graphSize[1];
      ctx.lineWidth = 0.5;
      ctx.strokeStyle = "#999";
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(0, graphHeight);
      ctx.lineTo(graphWidth, graphHeight);
      ctx.stroke();
      ctx.textBaseline = "middle";
      ctx.textAlign = "right";
      ctx.fillText("0.0 ", -labelOffset, graphHeight);
      ctx.fillText("1.0 ", -labelOffset, 0);
      ctx.lineWidth = 1.5;
      ctx.strokeStyle = "#009";
      ctx.beginPath();
      for (xp = 0; 0 <= graphWidth ? xp < graphWidth : xp > graphWidth; 0 <= graphWidth ? xp++ : xp--) {
        x = xp / graphWidth;
        y = smoothstep(diagram.edge0.value(), diagram.edge1.value(), x);
        yp = (1 - y) * graphHeight;
        if (xp === 0) {
          ctx.moveTo(xp, yp);
        } else {
          ctx.lineTo(xp, yp);
        }
      }
      return ctx.stroke();
    }
  };

  window.diagram = diagram;

  ko.applyBindings(diagram);

}).call(this);
