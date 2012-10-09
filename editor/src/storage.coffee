module.exports = {
  loadLast: () ->
    localStorage["last"]
  saveLast: (src) ->
    localStorage["last"] = src
}