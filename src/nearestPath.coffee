
path = require "path"
fs = require "io"

module.exports = (name, startPath) ->

  search = (lastPath) ->
    dirPath = path.dirname lastPath
    return null if dirPath is path.sep
    configPath = path.join dirPath, name
    fs.async.isFile configPath
      .then (isFile) ->
        return configPath if isFile
        return search dirPath

  return search startPath
