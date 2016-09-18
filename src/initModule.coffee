
fs = require "io/sync"

module.exports = (module, options = {}) ->

  module.load [ "config" ]

  .then ->
    module.src ?= "src"
    module.spec ?= "spec"

    if module.dest
      fs.remove module.dest if options.refresh
      fs.makeDir module.dest

    if module.specDest
      fs.remove module.specDest if options.refresh
      fs.makeDir module.specDest

    patterns = []

    if fs.isDir module.src
      patterns.push module.src + "/**/*.js"

    if fs.isDir module.spec
      patterns.push module.spec + "/**/*.js"

    return patterns
