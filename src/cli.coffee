
stripAnsi = require "strip-ansi"
Promise = require "Promise"
isType = require "isType"
sync = require "sync"
Path = require "path"
log = require "log"
fs = require "io/sync"

transform = require "./transform"

module.exports = (options) ->

  moduleName = options._.shift() or "."

  lotus.Module.load moduleName

  .then (module) ->

    module.load [ "config" ]

    .then ->

      try module.src ?= "src"
      try module.spec ?= "spec"

      if module.dest
        fs.remove module.dest if options.refresh
        fs.makeDir module.dest

      if module.specDest
        fs.remove module.specDest if options.refresh
        fs.makeDir module.specDest

      patterns = []
      patterns[0] = module.src + "/**/*.js" if module.src
      patterns[1] = module.spec + "/**/*.js" if module.spec

      module.crawl patterns

      .then (files) -> transformFiles files, options

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
