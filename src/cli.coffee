
{ isMatch } = require "micromatch"

stripAnsi = require "strip-ansi"
getValue = require "get-value"
Promise = require "Promise"
isType = require "isType"
sync = require "sync"
path = require "path"

initModule = require "./initModule"
transform = require "./transform"

module.exports = (options) ->

  moduleName = options._.shift() or "."

  lotus.Module.load moduleName

  .then (module) ->
    initModule module

    .then (patterns) ->
      module.crawl patterns,
        ignore: "**/{node_modules,__tests__,__mocks__}/**"

    .then (files) ->

      # Remove any ignored files.
      config = getValue module.config, "lotus.babel"
      if config and isType config.ignore, Array
        files = sync.filter files, (file) ->
          filePath = path.relative module.path, file.path
          for pattern in config.ignore
            return no if isMatch filePath, pattern
          return yes

      transformFiles files, options

    .fail (error) ->
      error.catch?()
      log.moat 1
      log.red "Module error: "
      log.white module.path
      log.moat 0
      log.gray.dim error.stack
      log.moat 1

transformFiles = (files, options) ->

  log.moat 1
  log.green.bold "start: "
  log.gray.dim files.length + " files"
  log.moat 1

  startTime = Date.now()

  Promise.chain files, (file) ->

    transform file, options

    .then ->
      if options.verbose
        log.moat 1
        log.cyan "• "
        log.white lotus.relative file.path
        log.moat 1
      else
        log.moat 0 if 25 <= log.line.length - log.indent
        log.cyan "•"

    .fail (error) ->

      if /File must have 'dest' defined before compiling/.test error.message
        log.moat 1
        log.yellow "WARN: "
        log.white lotus.relative file.path
        log.moat 0
        log.gray.dim error.message
        log.moat 1
        return

      log.moat 1
      log.red "Failed to compile: "
      log.white lotus.relative file.path
      log.moat 1

      if error.codeFrame
        log.gray.dim stripAnsi error.codeFrame
      else log.gray.dim error.message

      log.moat 1
      log.gray.dim "babel.version = "
      log.white error.babelVersion
      log.moat 1

  .then ->
    log.moat 1
    log.green.bold "finish: "
    log.gray.dim (Date.now() - startTime) + " ms"
    log.moat 1
