
emptyFunction = require "emptyFunction"

transformFiles = require "./transformFiles"
initModule = require "./initModule"

module.exports = (options) ->

  moduleNames = options._

  if not moduleNames.length
    return crawlModule "."
    .then (files) ->
      transformFiles files, options

  allFiles = []
  Promise.chain moduleNames, (moduleName) ->
    return crawlModule moduleName
    .then (files) -> allFiles = allFiles.concat files
  .then -> transformFiles allFiles, options

crawlModule = (moduleName) ->

  lotus.Module.load moduleName

  .then (module) ->
    initModule module

    .then (patterns) ->
      module.crawl patterns,
        ignore: "**/{node_modules,__tests__,__mocks__}/**"

    .fail (error) ->
      log.moat 1
      log.red "Module error: "
      log.white module.path
      log.moat 0
      log.gray.dim error.stack
      log.moat 1
