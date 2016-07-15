exports.initCommands = function() {
  return {
    babel: function() {
      return require("./cli");
    }
  };
};

exports.initModule = function() {
  return require("./watchModule");
};

exports.globalDependencies = ["lotus-watch"];

//# sourceMappingURL=map/index.map
