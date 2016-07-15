var bind, emptyFunction, fs, isType, onAdd, onChange, onReady, onTransformError, onUnlink, stripAnsi, sync, transform;

emptyFunction = require("emptyFunction");

stripAnsi = require("strip-ansi");

isType = require("isType");

bind = require("bind");

sync = require("sync");

fs = require("io/async");

transform = require("./transform");

module.exports = function(mod, options) {
  return mod.load(["config"]).then(function() {
    var context, dest, patterns, specDest;
    if (isType(options.dest, String)) {
      dest = options.dest;
    } else {
      dest = "src";
    }
    if (isType(options.specDest, String)) {
      specDest = options.specDest;
    } else {
      specDest = "spec";
    }
    if (!mod.dest) {
      log.moat(1);
      log.yellow("Warning: ");
      log.white(mod.name);
      log.moat(0);
      log.gray.dim("A valid 'dest' must exist before 'lotus-babel' can work!");
      log.moat(1);
      return;
    }
    patterns = [];
    if (dest) {
      patterns[0] = dest + "/**/*.js";
    }
    if (specDest) {
      patterns[1] = specDest + "/**/*.js";
    }
    context = {
      mod: mod,
      options: options
    };
    return mod.watch(patterns, {
      ready: bind.func(onReady, context),
      add: bind.func(onAdd, context),
      change: bind.func(onChange, context),
      unlink: bind.func(onUnlink, context)
    });
  });
};

onReady = function(files) {
  var index, next;
  index = -1;
  next = (function(_this) {
    return function() {
      var file;
      if (++index === files.length) {
        return;
      }
      file = files[index];
      return fs.isFile(file.dest).then(function(isTransformed) {
        if (isTransformed) {
          return;
        }
        return transform(file, _this).then(function() {
          log.moat(1);
          log.white("add ");
          log.yellow(lotus.relative(file.dest));
          return log.moat(1);
        }).fail(emptyFunction).then(next);
      });
    };
  })(this);
  return next();
};

onAdd = function(file) {
  log.moat(1);
  log.white("add ");
  log.yellow(lotus.relative(file.path));
  log.moat(1);
  return transform(file, this).then(function() {
    log.moat(1);
    log.white("add ");
    log.yellow(lotus.relative(file.dest));
    return log.moat(1);
  }).fail(function(error) {
    if (error instanceof SyntaxError) {
      return onTransformError(file.path, error);
    }
    throw error;
  });
};

onChange = function(file) {
  log.moat(1);
  log.white("change ");
  log.yellow(lotus.relative(file.path));
  log.moat(1);
  return transform(file, this).then(function() {
    log.moat(1);
    log.white("change ");
    log.yellow(lotus.relative(file.dest));
    return log.moat(1);
  }).fail(function(error) {
    if (error instanceof SyntaxError) {
      return onTransformError(file.path, error);
    }
    throw error;
  });
};

onUnlink = function(file) {};

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

//# sourceMappingURL=../../map/src/initModule.map
