module.exports = () ->
  require("../graph")({
    output: $("#output")
    code: $("#code")
    src: "abs(x)"
  })