
{resolvePath} = require "resolve"

AsyncTaskGroup = require "AsyncTaskGroup"
emptyFunction = require "emptyFunction"
mergeDefaults = require "mergeDefaults"
objectify = require "objectify"
steal = require "steal"
path = require "path"
mm = require "micromatch"
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

  tasks = AsyncTaskGroup {maxConcurrent: 3}
  failed = []

  ignore = makeIgnoreFn options
  tasks.map files, (file) ->
    return if ignore file.path
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

  unless file.dest
    throw Error "File must have 'dest' defined before compiling: '#{file.path}'"

  lastModified = new Date

  babelPath = resolvePath "babel-core",
    parent: path.dirname file.path

  unless babelPath
    throw Error "Could not resolve 'babel-core' from '#{file.path}'!"

  unless babel = babelCache[babelPath]

    unless options.quiet
      {green} = log.color
      log.it "Loading: #{green lotus.relative babelPath}"

    babelCache[babelPath] = babel = require babelPath

  unless options.quiet
    {green} = log.color
    log.it "Transforming: #{green lotus.relative file.path}"

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

makeIgnoreFn = (options) ->
  ignore = steal options, "ignore"
  only = steal options, "only"
  return (file) ->
    return yes if ignore and mm.isMatch file, ignore
    return yes if only and not mm.isMatch file, only
    return no
