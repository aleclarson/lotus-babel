
emptyFunction = require "emptyFunction"
path = require "path"

transformFiles = require "./transformFiles"
initModule = require "./initModule"

exports.babel = (options) ->

  modNames = options._

  unless modNames.length
    return crawlModule "."
    .then (files) ->
      transformFiles files, options

  allFiles = []
  Promise.chain modNames, (modName) ->
    crawlModule modName
    .then (files) ->
      allFiles = allFiles.concat files

  .then ->
    transformFiles allFiles, options

crawlModule = (modName) ->
  mod = lotus.modules.load modName

  initModule mod
  .then (patterns) ->
    ignored = "(.git|node_modules|__tests__|__mocks__)"
    mod.crawl patterns,
      ignored: path.join "**", ignored, "**"

  .fail (error) ->
    log.moat 1
    log.white "A module threw an error: "
    log.red lotus.relative mod.path
    log.moat 0
    log.gray error.stack
    log.moat 1
