
rimraf = require "rimraf"
path = require "path"
fs = require "fsx"

module.exports = (mod, options = {}) ->

  mod.load ["config"]
  .then ->

    mod.src ?= "src"
    mod.spec ?= "spec"

    if mod.dest
      if options.refresh
        rimraf.sync mod.dest
      fs.writeDir mod.dest

    if mod.specDest
      if options.refresh
        rimraf.sync mod.specDest
      fs.writeDir mod.specDest

    patterns = []

    if fs.isDir mod.src
      pattern = path.join mod.src, "**", "*.js"
      patterns.push pattern

    if fs.isDir mod.spec
      pattern = path.join mod.spec, "**", "*.js"
      patterns.push pattern

    return patterns
