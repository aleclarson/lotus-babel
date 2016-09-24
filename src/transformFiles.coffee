
{resolvePath} = require "resolve"

mergeDefaults = require "mergeDefaults"
objectify = require "objectify"
path = require "path"
fs = require "fsx"

babelKeys = [
  "presets"
  "plugins"
  "only"
  "ignore"
  "sourceMaps"
  "babelrc"
  "extends"
]

babelCache = Object.create null

module.exports = (files, options = {}) ->

  makePromise =
    if options.serial
    then Promise.chain
    else Promise.all

  failed = []
  makePromise files, (file) ->
    transformFile file, options
    .fail (error) ->
      failed.push {file, error}
      return null

  .then (results) ->

    if failed.length and not options.quiet
      failed.forEach ({ file, error }) ->
        {red} = log.color
        log.moat 1
        log.white """
          Failed to compile:
            #{red lotus.relative file.path}
        """
        log.moat 1
        log.gray.dim error.codeFrame or error.stack
        log.moat 1

    return results

transformFile = (file, options) ->

  if not file.dest
    throw Error "File must have 'dest' defined before compiling: '#{file.path}'"

  lastModified = new Date

  babelPath = resolvePath "babel-core",
    parent: path.dirname file.path

  if not babelPath
    throw Error "Could not resolve 'babel-core' from '#{file.path}'!"

  if not babel = babelCache[babelPath]

    if not options.quiet
      {green} = log.color
      log.moat 1
      log.white """
        Importing:
          #{green lotus.relative babelPath}
      """
      log.moat 1

    babelCache[babelPath] = babel = require babelPath

  if not options.quiet
    {green} = log.color
    log.moat 1
    log.white """
      Transforming:
        #{green lotus.relative file.path}
    """
    log.moat 1

  babelOptions = objectify
    keys: babelKeys
    values: options

  babelOptions.filename = file.path
  babelOptions.highlightCode = no

  babelTransform = Promise.ify babel.transformFile
  babelTransform file.path, babelOptions

  .then (transformed) ->

    fs.writeDir path.dirname file.dest
    fs.writeFile file.dest, transformed.code
    file._reading = null

    dest = lotus.File file.dest, file.module
    dest.lastModified = lastModified
    return dest
