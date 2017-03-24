
module.exports =
  loadCommands: -> require "./cli"
  initModule: -> require "./watchModule"
  globalDependencies: ["lotus-watch"]
