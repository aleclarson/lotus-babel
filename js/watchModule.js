var bind, createListeners, emptyFunction, fs, getValue, initModule, isMatch, isType, onTransformError, path, printEvent, stripAnsi, sync, transform;

isMatch = require("micromatch").isMatch;

emptyFunction = require("emptyFunction");

stripAnsi = require("strip-ansi");

getValue = require("get-value");

isType = require("isType");

bind = require("bind");

sync = require("sync");

path = require("path");

fs = require("io/async");

initModule = require("./initModule");

transform = require("./transform");

module.exports = function(module) {
  var config, ignoredPatterns;
  config = getValue(module.config, "lotus.babel");
  if (config == null) {
    config = {};
  }
  ignoredPatterns = config.ignore;
  if (Array.isArray(ignoredPatterns)) {
    config.ignore = function(file) {
      var filePath, i, len, pattern;
      filePath = path.relative(module.path, file.path);
      for (i = 0, len = ignoredPatterns.length; i < len; i++) {
        pattern = ignoredPatterns[i];
        if (isMatch(filePath, pattern)) {
          return false;
        }
      }
      return true;
    };
  } else {
    config.ignore = emptyFunction.thatReturnsFalse;
  }
  return initModule(module).then(function(patterns) {
    var listeners;
    listeners = createListeners(config);
    return module.watch(patterns, listeners);
  });
};

createListeners = function(config) {
  return {
    ready: function(files) {
      var index, next;
      index = -1;
      next = (function(_this) {
        return function() {
          var file;
          if (++index === files.length) {
            return;
          }
          file = files[index];
          if (config.ignore(file)) {
            return next();
          }
          return fs.isFile(file.dest).then(function(isTransformed) {
            if (isTransformed) {
              return next();
            }
            return transform(file).then(function() {
              return printEvent("add", file.dest);
            }).fail(emptyFunction).then(next);
          });
        };
      })(this);
      return next();
    },
    add: function(file) {
      var event;
      event = "add";
      printEvent(event, file.path);
      return transform(file).then(function() {
        return printEvent(event, file.dest);
      }).fail(function(error) {
        if (error instanceof SyntaxError) {
          return onTransformError(file.path, error);
        }
        if (/File must have 'dest' defined before compiling/.test(error.message)) {
          log.moat(1);
          log.yellow("WARN: ");
          log.white(lotus.relative(file.path));
          log.moat(0);
          log.gray.dim(error.message);
          log.moat(1);
          return;
        }
        throw error;
      });
    },
    change: function(file) {
      var event;
      event = "change";
      printEvent(event, file.path);
      return transform(file).then(function() {
        return printEvent(event, file.dest);
      }).fail(function(error) {
        if (error instanceof SyntaxError) {
          return onTransformError(file.path, error);
        }
        throw error;
      });
    },
    unlink: function(file) {
      var event;
      event = "unlink";
      printEvent(event, file.path);
      if (file.dest && fs.exists(file.dest)) {
        fs.remove(file.dest).then(function() {
          return printEvent(event, file.dest);
        });
      }
      if (file.mapDest && fs.exists(file.mapDest)) {
        return fs.remove(file.mapDest).then(function() {
          return printEvent(event, file.mapDest);
        });
      }
    }
  };
};

printEvent = function(event, filePath) {
  log.moat(1);
  log.white(event, " ");
  log.yellow(lotus.relative(filePath));
  return log.moat(1);
};

onTransformError = function(filePath, error) {
  log.moat(1);
  log.red("Failed to compile: ");
  log.white(lotus.relative(filePath));
  log.moat(1);
  if (error.codeFrame) {
    log.gray.dim(stripAnsi(error.codeFrame));
  } else {
    log.gray.dim(error.stack);
  }
  log.moat(1);
};

//# sourceMappingURL=map/watchModule.map
