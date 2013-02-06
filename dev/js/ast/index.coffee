_ = require("underscore")



extractChildren = (ast, recursing=false) ->
  if recursing && ast.type
    return [ast]
  else if _.isObject(ast) || _.isArray(ast)
    return _.flatten(_.map(ast, (v) ->
      extractChildren(v, true)
    ))
  else
    return []


markEnds = (node, endOffset) ->
  node.endOffset = endOffset
  
  children = extractChildren(node)
  children = _.sortBy(children, "offset")
  
  for child, i in children
    if i == children.length - 1
      childEndOffset = endOffset
    else
      nextChild = children[i+1]
      childEndOffset = nextChild.offset
    markEnds(child, childEndOffset)


stringify = (ast, src) ->
  s = src.substring(ast.offset, ast.endOffset)
  
  # remove trailing white space
  s = s.replace(/\s+$/, "")
  
  # remove trailing commas
  s = s.replace(/,+$/, "")
  
  # remove unbalanced parentheses from the end
  # this is super hacky that you even have to do this -Toby
  endParens = 0
  for ch in s
    if ch == "("
      endParens--
    else if ch == ")"
      endParens++
  s = s.substr(0, s.length - endParens)
  
  return s



breakdownTypes = ["identifier", "unary", "binary", "function_call"]
breakdownWorthy = (node) ->
  _.contains(breakdownTypes, node.type)

# returns a tree of the form {node, children} where each node is "worthy" of breaking down
breakdown = (node) ->
  children = _.flatten(_.map(extractChildren(node), breakdown))
  if breakdownWorthy(node)
    return [{
      node: node
      children: children
    }]
  else
    return children


module.exports = {
  markEnds: markEnds
  extractChildren: extractChildren
  breakdown: breakdown
  stringify: stringify
}