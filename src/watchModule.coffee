
emptyFunction = require "emptyFunction"
rimraf = require "rimraf"
path = require "path"
fs = require "fsx"

transformFiles = require "./transformFiles"
initModule = require "./initModule"

module.exports = (mod) ->
  initModule mod
  .then (include) ->
    exclude = path.join "**", "{node_modules,__tests__,__mocks__}", "**"
    listeners = createListeners mod.config.babel or {}
    mod.watch {include, exclude}, listeners

createListeners = (config) ->

  ready: emptyFunction

  add: (file) ->
    {green} = log.color
    log.moat 1
    log.white """
      File added:
        #{green file.path}
    """
    log.moat 1
    transformFiles [file]

  change: (file) ->
    transformFiles [file]

  unlink: (file) ->

    if file.dest and fs.exists file.dest
      rimraf.sync file.dest

    if file.mapDest and fs.exists file.mapDest
      rimraf.sync file.mapDest
