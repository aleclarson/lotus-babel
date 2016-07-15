var Promise, getValue, initModule, isMatch, isType, path, stripAnsi, sync, transform, transformFiles;

isMatch = require("micromatch").isMatch;

stripAnsi = require("strip-ansi");

getValue = require("get-value");

Promise = require("Promise");

isType = require("isType");

sync = require("sync");

path = require("path");

initModule = require("./initModule");

transform = require("./transform");

module.exports = function(options) {
  var moduleName;
  moduleName = options._.shift() || ".";
  return lotus.Module.load(moduleName).then(function(module) {
    return initModule(module).then(function(patterns) {
      return module.crawl(patterns);
    }).then(function(files) {
      var config;
      config = getValue(module.config, "lotus.babel");
      if (config && isType(config.ignore, Array)) {
        files = sync.filter(files, function(file) {
          var filePath, i, len, pattern, ref;
          filePath = path.relative(module.path, file.path);
          ref = config.ignore;
          for (i = 0, len = ref.length; i < len; i++) {
            pattern = ref[i];
            if (isMatch(filePath, pattern)) {
              return false;
            }
          }
          return true;
        });
      }
      return transformFiles(files, options);
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
      if (/File must have 'dest' defined before compiling/.test(error.message)) {
        log.moat(1);
        log.yellow("WARN: ");
        log.white(lotus.relative(file.path));
        log.moat(0);
        log.gray.dim(error.message);
        log.moat(1);
        return;
      }
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

//# sourceMappingURL=map/cli.map
