
{ isMatch } = require "micromatch"

emptyFunction = require "emptyFunction"
stripAnsi = require "strip-ansi"
getValue = require "get-value"
isType = require "isType"
bind = require "bind"
sync = require "sync"
path = require "path"
fs = require "io/async"

initModule = require "./initModule"
transform = require "./transform"

module.exports = (module) ->

  config = getValue module.config, "lotus.babel"
  config ?= {}

  ignoredPatterns = config.ignore
  if Array.isArray ignoredPatterns
    config.ignore = (file) ->
      filePath = path.relative module.path, file.path
      for pattern in ignoredPatterns
        return no if isMatch filePath, pattern
      return yes
  else
    config.ignore = emptyFunction.thatReturnsFalse

  initModule module
  .then (patterns) ->
    listeners = createListeners config
    module.watch patterns, listeners

createListeners = (config) ->

  ready: (files) ->

    index = -1
    next = =>
      return if ++index is files.length

      file = files[index]
      return next() if config.ignore file

      fs.isFile file.dest
      .then (isTransformed) ->
        return next() if isTransformed

        transform file

        .then -> printEvent "add", file.dest

        # Ignore compiler errors on startup.
        .fail emptyFunction

        # Transform the next file.
        .then next

    # Transform the first file.
    next()

  add: (file) ->

    event = "add"
    printEvent event, file.path

    transform file

    .then ->
      printEvent event, file.dest

    .fail (error) ->

      if error instanceof SyntaxError
        return onTransformError file.path, error

      if /File must have 'dest' defined before compiling/.test error.message
        log.moat 1
        log.yellow "WARN: "
        log.white lotus.relative file.path
        log.moat 0
        log.gray.dim error.message
        log.moat 1
        return

      throw error

  change: (file) ->

    event = "change"
    printEvent event, file.path

    transform file

    .then ->
      printEvent event, file.dest

    .fail (error) ->
      if error instanceof SyntaxError
        return onTransformError file.path, error
      throw error

  unlink: (file) ->

    event = "unlink"
    printEvent event, file.path

    if file.dest and fs.exists file.dest
      fs.remove file.dest
      .then -> printEvent event, file.dest

    if file.mapDest and fs.exists file.mapDest
      fs.remove file.mapDest
      .then -> printEvent event, file.mapDest

printEvent = (event, filePath) ->
  log.moat 1
  log.white event, " "
  log.yellow lotus.relative filePath
  log.moat 1

onTransformError = (filePath, error) ->
  log.moat 1
  log.red "Failed to compile: "
  log.white lotus.relative filePath
  log.moat 1
  if error.codeFrame
    log.gray.dim stripAnsi error.codeFrame
  else log.gray.dim error.stack
  log.moat 1
  return
