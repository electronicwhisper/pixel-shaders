module.exports = () ->
  require("../graphEditor")({
    output: $("#output")
    code: $("#code")
    src: "abs(x)"
  })
  
  require("../evaluator")({
    output: $("#eoutput")
    code: $("#ecode")
    src: "3. + 5."
  })