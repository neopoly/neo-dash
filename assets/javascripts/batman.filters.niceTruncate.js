// Truncates (HTML) content
// Requirements: jquery.truncate (https://github.com/pathable/truncate/blob/master/jquery.truncate.js)
// Usage:
//   <p data-bind="message.content | truncateHTML 200 | raw"></p>
Batman.mixin(Batman.Filters, {
  niceTruncate: function(content, length, stripTags, words, noBreak, ellipsis){
    if(typeof(content) === "undefined" || content === null)
      return undefined;

    if(length == null)    length = Infinity;
    if(stripTags == null) stripTags = false;
    if(words == null)     words = true;
    if(noBreak == null)   noBreak = false;
    if(ellipsis == null)  ellipsis = '\u2026';

    return $.truncate(content,{
      stripTags: stripTags,
      length: length,
      words: words,
      noBreak: noBreak,
      ellipsis: ellipsis
    });
  }
});
