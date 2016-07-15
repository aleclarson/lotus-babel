
exports.initCommands = ->
  babel: -> require "./cli"

exports.initModule = ->
  require "./watchModule"

exports.globalDependencies = [
  "lotus-watch"
]
