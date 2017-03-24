
emptyFunction = require "emptyFunction"
rimraf = require "rimraf"
path = require "path"
fs = require "fsx"

transformFiles = require "./transformFiles"
initModule = require "./initModule"

module.exports = (mod) ->

  initModule mod
  .then (patterns) ->
    ignored = "(.git|node_modules|__tests__|__mocks__)"

    watcher = mod.watch patterns,
      ignored: path.join "**", ignored, "**"

    watcher.on "add", (file) ->
      {green} = log.color
      log.it "File added: #{green lotus.relative file.path}"
      transformFiles [file]

    watcher.on "change", (file) ->
      transformFiles [file]

    watcher.on "unlink", (file) ->

      {red} = log.color
      log.it "File deleted: #{red lotus.relative file.path}"

      if file.dest and fs.exists file.dest
        rimraf.sync file.dest

      if file.mapDest and fs.exists file.mapDest
        rimraf.sync file.mapDest

    return watcher
