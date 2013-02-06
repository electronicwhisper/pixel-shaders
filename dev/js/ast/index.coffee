_ = require("underscore")


compareLineColumn = (a, b) ->
  if a.line == b.line
    return a.column - b.column
  else
    return a.line - b.line

getEnd = (src) ->
  lines = src.split("\n")
  {
    line: lines.length
    column: lines[lines.length-1].length
  }



extractChildren = (ast, recursing=false) ->
  if recursing && ast.type
    return [ast]
  else if _.isObject(ast) || _.isArray(ast)
    return _.flatten(_.map(ast, (v) ->
      extractChildren(v, true)
    ))
  else
    return []


markEnds = (node, end) ->
  node.end = end
  
  children = extractChildren(node)
  children.sort(compareLineColumn)
  
  for child, i in children
    if i == children.length - 1
      childEnd = end
    else
      nextChild = children[i+1]
      childEnd = {
        line: nextChild.line
        column: nextChild.column - 1
      }
    markEnds(child, childEnd)


breakdownTypes = ["identifier", "unary", "binary", "function_call"]
breakdownWorthy = (node) ->
  _.contains(breakdownTypes, node.type)

# returns a tree of the form {node, children} where each node is "worthy" of breaking down
breakdown = (node) ->
  ""


module.exports = {
  getEnd: getEnd
  markEnds: markEnds
  extractChildren: extractChildren
}