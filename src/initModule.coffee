
emptyFunction = require "emptyFunction"
stripAnsi = require "strip-ansi"
isType = require "isType"
bind = require "bind"
sync = require "sync"
fs = require "io/async"

transform = require "./transform"

module.exports = (mod, options) ->

  mod.load [ "config" ]

  .then ->

    if isType options.dest, String
      dest = options.dest
    else dest = "src"

    if isType options.specDest, String
      specDest = options.specDest
    else specDest = "spec"

    unless mod.dest
      log.moat 1
      log.yellow "Warning: "
      log.white mod.name
      log.moat 0
      log.gray.dim "A valid 'dest' must exist before 'lotus-babel' can work!"
      log.moat 1
      return

    patterns = []
    patterns[0] = dest + "/**/*.js" if dest
    patterns[1] = specDest + "/**/*.js" if specDest

    context = { mod, options }
    mod.watch patterns,
      ready: bind.func onReady, context
      add: bind.func onAdd, context
      change: bind.func onChange, context
      unlink: bind.func onUnlink, context

onReady = (files) ->

  index = -1
  next = =>
    return if ++index is files.length
    file = files[index]
    fs.isFile file.dest
    .then (isTransformed) =>
      return if isTransformed
      transform file, this
      .then ->
        log.moat 1
        log.white "add "
        log.yellow lotus.relative file.dest
        log.moat 1

      # Ignore compiler errors on startup.
      .fail emptyFunction

      # Transform the next file.
      .then next

  # Transform the first file.
  next()

onAdd = (file) ->

  log.moat 1
  log.white "add "
  log.yellow lotus.relative file.path
  log.moat 1

  transform file, this

  .then ->
    log.moat 1
    log.white "add "
    log.yellow lotus.relative file.dest
    log.moat 1

  .fail (error) ->
    if error instanceof SyntaxError
      return onTransformError file.path, error
    throw error

onChange = (file) ->

  log.moat 1
  log.white "change "
  log.yellow lotus.relative file.path
  log.moat 1

  transform file, this

  .then ->
    log.moat 1
    log.white "change "
    log.yellow lotus.relative file.dest
    log.moat 1

  .fail (error) ->
    if error instanceof SyntaxError
      return onTransformError file.path, error
    throw error

onUnlink = (file) ->

  # event = "unlink"
  # alertEvent event, file.path
  #
  # if file.dest
  #   fs.remove file.dest
  #   .then -> alertEvent event, file.dest
  #
  # if file.mapDest
  #   fs.remove file.mapDest
  #   .then -> alertEvent event, file.mapDest

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
