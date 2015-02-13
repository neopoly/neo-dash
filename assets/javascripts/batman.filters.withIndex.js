Batman.mixin(Batman.Filters, {
  withIndex: function(input) {
    var index;
    if (!input) {
      return input;
    }
    index = -1;
    input.forEach(function(data) {
      index += 1;
      if(data.set) data.set("viewIndex", index);
      else data.viewIndex = index;
      return data;
    });
    return input;
  },
  gt: function(input, value) {
    return input > value;
  }
});