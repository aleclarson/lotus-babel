var Path, Promise, fs, isType, log, stripAnsi, sync, transform, transformFiles;

stripAnsi = require("strip-ansi");

Promise = require("Promise");

isType = require("isType");

sync = require("sync");

Path = require("path");

log = require("log");

fs = require("io/sync");

transform = require("./transform");

module.exports = function(options) {
  var moduleName;
  moduleName = options._.shift() || ".";
  return lotus.Module.load(moduleName).then(function(module) {
    return module.load(["config"]).then(function() {
      var patterns;
      try {
        if (module.src == null) {
          module.src = "src";
        }
      } catch (error1) {}
      try {
        if (module.spec == null) {
          module.spec = "spec";
        }
      } catch (error1) {}
      if (module.dest) {
        if (options.refresh) {
          fs.remove(module.dest);
        }
        fs.makeDir(module.dest);
      }
      if (module.specDest) {
        if (options.refresh) {
          fs.remove(module.specDest);
        }
        fs.makeDir(module.specDest);
      }
      patterns = [];
      if (module.src) {
        patterns[0] = module.src + "/**/*.js";
      }
      if (module.spec) {
        patterns[1] = module.spec + "/**/*.js";
      }
      return module.crawl(patterns).then(function(files) {
        return transformFiles(files, options);
      });
    }).fail(function(error) {
      if (typeof error["catch"] === "function") {
        error["catch"]();
      }
      log.moat(1);
      log.red("Module error: ");
      log.white(module.path);
      log.moat(0);
      log.gray.dim(error.stack);
      return log.moat(1);
    });
  });
};

transformFiles = function(files, options) {
  var startTime;
  log.moat(1);
  log.green.bold("start: ");
  log.gray.dim(files.length + " files");
  log.moat(1);
  startTime = Date.now();
  return Promise.chain(files, function(file) {
    return transform(file, options).then(function() {
      if (options.verbose) {
        log.moat(1);
        log.cyan("• ");
        log.white(lotus.relative(file.path));
        return log.moat(1);
      } else {
        if (25 <= log.line.length - log.indent) {
          log.moat(0);
        }
        return log.cyan("•");
      }
    }).fail(function(error) {
      log.moat(1);
      log.red("Failed to compile: ");
      log.white(lotus.relative(file.path));
      log.moat(1);
      if (error.codeFrame) {
        log.gray.dim(stripAnsi(error.codeFrame));
      } else {
        log.gray.dim(error.message);
      }
      log.moat(1);
      log.gray.dim("babel.version = ");
      log.white(error.babelVersion);
      return log.moat(1);
    });
  }).then(function() {
    log.moat(1);
    log.green.bold("finish: ");
    log.gray.dim((Date.now() - startTime) + " ms");
    return log.moat(1);
  });
};

//# sourceMappingURL=../../map/src/cli.map
