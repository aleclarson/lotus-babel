exports.initCommands = function() {
  return {
    babel: function() {
      return require("./cli");
    }
  };
};

exports.initModule = function() {
  return require("./initModule");
};

exports.globalDependencies = ["lotus-watch"];

//# sourceMappingURL=../../map/src/index.map
