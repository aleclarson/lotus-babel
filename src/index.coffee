
exports.initCommands = ->
  babel: -> require "./cli"

exports.initModule = ->
  require "./initModule"

exports.globalDependencies = [
  "lotus-watch"
]
