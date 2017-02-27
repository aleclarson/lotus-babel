
rimraf = require "rimraf"
fs = require "fsx"

module.exports = (module, options = {}) ->

  module.load [ "config" ]

  .then ->
    module.src ?= "src"
    module.spec ?= "spec"

    if module.dest
      if options.refresh
        rimraf.sync module.dest
      fs.writeDir module.dest

    if module.specDest
      if options.refresh
        rimraf.sync module.specDest
      fs.writeDir module.specDest

    patterns = []

    if fs.isDir module.src
      patterns.push module.src + "/**/*.js"

    if fs.isDir module.spec
      patterns.push module.spec + "/**/*.js"

    return patterns
