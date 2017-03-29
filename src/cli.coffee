
{isMatch} = require "micromatch"

emptyFunction = require "emptyFunction"
path = require "path"
fs = require "fsx"

transformFiles = require "./transformFiles"
initModule = require "./initModule"

ignored = "{.git,node_modules,__tests__,__mocks__,__fixtures__}"
crawlModule = (mod) ->

  unless mod.src
    log.warn "Missing source root!"
    return Promise.resolve []

  mod.crawl path.join(mod.src, "**", "*"),
    ignore: path.join("**", ignored, "**")

exports.babel = (options) ->

  modNames = options._
  unless modNames.length
    modNames.push "."

  sourceFiles = []
  Promise.chain modNames, (modName) ->
    mod = lotus.modules.load modName

    initModule mod
    .then (sourceGlobs) ->
      sourceRoot = mod.src
      destRoot = mod.dest

      crawlModule mod
      .then (files) ->
        log.it "files.length = #{files.length}"
        files.forEach (file) ->

          for glob in sourceGlobs
            if isMatch file.path, glob
              sourceFiles.push file
              return

          # All unmatched files are copied into the destination root.
          sourcePath = path.relative sourceRoot, file.path
          destPath = path.join destRoot, sourcePath
          fs.writeDir path.dirname destPath
          fs.writeFile destPath, fs.readFile file.path

          log.moat 0
          log.white "Copied: "
          log.green sourcePath
          log.moat 0
          return

    .fail (error) ->
      log.moat 1
      log.white "A module threw an error: "
      log.red lotus.relative mod.path
      log.moat 0
      log.gray error.stack
      log.moat 1

  .then ->
    transformFiles sourceFiles, options
