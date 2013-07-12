{
function flatten(x) {
  return x.reduce(function(a, b) {
    if (!Array.isArray(a)) a = [a];
    return a.concat(b);
  })
}
}

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

variable
  = v:"x" { return [v]; }

additive
  = multiplicative _? add_op _? additive
  / multiplicative

multiplicative
  = func_call _? mul_op _? multiplicative
  / func_call

func_call
  = result:(func_name "(" param_list ")") { return flatten(result); }
  / primary

param_list
  = head:(_? additive _?) tail:("," _? additive _?)* { return flatten([head].concat(tail)); }

primary
  = number
  / variable
  / "(" _? additive:additive _? ")"

number
  = u:unary_op? d1:[0-9]* "." d2:[0-9]* { return u + d1.join("") + "." + d2.join("")}