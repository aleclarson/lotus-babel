
mergeDefaults = require "mergeDefaults"
Promise = require "Promise"
hasKeys = require "hasKeys"
path = require "path"
fs = require "io"

nearestPath = require "./nearestPath"

module.exports = Promise.wrap (file, options) ->

  if not file.dest
    throw Error "File must have 'dest' defined before compiling: '#{file.path}'"

  nearestPath "package.json", file.path

  .then (pkgPath) ->

    babelPath = path.dirname(pkgPath) + "/node_modules/babel-core"
    if fs.sync.isDir babelPath
      return require babelPath

    babelPath = lotus.resolve "babel-core", file.path
    if fs.sync.isFile babelPath
      return require babelPath

    throw Error "Failed to load 'babel-core' for '#{file.path}'!"

  .then (babel) ->

    file.read { force: yes }

    .then (contents) ->

      { code } = babel.transform contents, { filename: file.path }

      dest = lotus.File file.dest, file.module
      dest.lastModified = new Date

      fs.sync.write dest.path, code

    .fail (error) ->
      error.babelVersion = babel.version
      throw error
