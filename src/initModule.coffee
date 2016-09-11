
fs = require "io/sync"

module.exports = (module, options = {}) ->

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
    return patterns
