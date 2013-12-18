Batman.mixin(Batman.Filters, {
  relativeDate: function(dateAsString){
    if(typeof(dateAsString) === "undefined" || dateAsString === null)
      return undefined;

    return moment(dateAsString).relativeShort();
  }
});
