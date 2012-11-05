start
  = _? exp:additive _? { return exp; }

_
  = ws:" "* { return ws.join(""); }

add_op
  = "+" / "-"

mul_op
  = "*" / "/"

unary_op
  = "+" / "-"

func_name
  = name:[a-zA-Z]+ { return name.join(""); }


additive
  = multiplicative _? add_op _? additive
  / multiplicative

multiplicative
  = func_call _? mul_op _? multiplicative
  / func_call

func_call
  = func_name "(" _? additive _? ")"
  / primary

primary
  = number
  / "(" _? additive:additive _? ")"

number
  = u:unary_op? d1:[0-9]* "." d2:[0-9]* { return u + d1.join("") + "." + d2.join("")}