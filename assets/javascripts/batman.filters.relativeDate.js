Batman.mixin(Batman.Filters, {
  relativeDate: function(dateAsString){
    if(typeof(dateAsString) === "undefined")
      return undefined;

    return moment(dateAsString).relativeShort();
  }
});
