var fs;

fs = require("io/sync");

module.exports = function(module, options) {
  if (options == null) {
    options = {};
  }
  return module.load(["config"]).then(function() {
    var patterns;
    try {
      if (module.src == null) {
        module.src = "src";
      }
    } catch (error) {}
    try {
      if (module.spec == null) {
        module.spec = "spec";
      }
    } catch (error) {}
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
    return patterns;
  });
};

//# sourceMappingURL=map/initModule.map
