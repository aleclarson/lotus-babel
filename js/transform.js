var Promise, fs, hasKeys, mergeDefaults, nearestPath, path;

mergeDefaults = require("mergeDefaults");

Promise = require("Promise");

hasKeys = require("hasKeys");

path = require("path");

fs = require("io");

nearestPath = require("./nearestPath");

module.exports = Promise.wrap(function(file, options) {
  if (!file.dest) {
    throw Error("File must have 'dest' defined before compiling: '" + file.path + "'");
  }
  return nearestPath("package.json", file.path).then(function(pkgPath) {
    var babelPath;
    babelPath = path.dirname(pkgPath) + "/node_modules/babel-core";
    if (fs.sync.isDir(babelPath)) {
      return require(babelPath);
    }
    babelPath = lotus.resolve("babel-core", file.path);
    if (fs.sync.isFile(babelPath)) {
      return require(babelPath);
    }
    throw Error("Failed to load 'babel-core' for '" + file.path + "'!");
  }).then(function(babel) {
    return file.read({
      force: true
    }).then(function(contents) {
      var code, dest;
      code = babel.transform(contents, {
        filename: file.path
      }).code;
      dest = lotus.File(file.dest, file.module);
      dest.lastModified = new Date;
      return fs.sync.write(dest.path, code);
    }).fail(function(error) {
      error.babelVersion = babel.version;
      throw error;
    });
  });
});

//# sourceMappingURL=map/transform.map
