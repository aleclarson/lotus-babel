var fs, path;

path = require("path");

fs = require("io");

module.exports = function(name, startPath) {
  var search;
  search = function(lastPath) {
    var configPath, dirPath;
    dirPath = path.dirname(lastPath);
    if (dirPath === path.sep) {
      return null;
    }
    configPath = path.join(dirPath, name);
    return fs.async.isFile(configPath).then(function(isFile) {
      if (isFile) {
        return configPath;
      }
      return search(dirPath);
    });
  };
  return search(startPath);
};

//# sourceMappingURL=../../map/src/nearestPath.map
