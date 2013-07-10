state = require("state")

generate = {}

generate.code = ->
  code = ""

  code += """

    precision highp float;

    varying vec2 position;
    uniform sampler2D image;
    uniform vec2 resolution;
    uniform vec2 imageResolution;

    uniform mat3 globalTransform;

    """

  for c, i in _.reverse(state.chain)
    code += "uniform mat3 m#{i};\n"
    code += "uniform mat3 m#{i}inv;\n"

  code += """

    void main() {
      vec3 p = vec3(position, 1.);

    """

  code += "\n"
  code += "p = globalTransform * p;"
  code += "\n"

  if state.polarMode
    code += """

      p.xy = vec2(length(p.xy), atan(p.y, p.x));

    """

  for c, i in _.reverse(state.chain)
    f = c.distortion.f
    code += "\n"
    code += "p = m#{i} * p;\n"
    code += "#{f};\n"
    code += "p = m#{i}inv * p;\n"
    code += "\n"

  if state.polarMode
    code += """

      p.xy = vec2(p.x*cos(p.y), p.x*sin(p.y));

    """

  code += """

      p.xy = (p.xy + 1.) * .5;

      /*
      if (p.x < 0. || p.x > 1. || p.y < 0. || p.y > 1.) {
        // black if out of bounds
        gl_FragColor = vec4(0., 0., 0., 1.);
      } else {
        gl_FragColor = texture2D(image, p.xy);
      }
      */

      // mirror wrap it
      p = abs(mod((p-1.), 2.)-1.);

      gl_FragColor = texture2D(image, p.xy);
    }
    """

  return code


flattenMatrix = (m) ->
  _.flatten(numeric.transpose(m))

generate.uniforms = ->
  uniforms = {
    globalTransform: flattenMatrix(state.globalTransform)
  }
  for c, i in _.reverse(state.chain)
    uniforms["m#{i}"]    = flattenMatrix(c.transform)
    uniforms["m#{i}inv"] = flattenMatrix(numeric.inv(c.transform))
  return uniforms


module.exports = generate




