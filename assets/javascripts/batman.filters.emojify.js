// Renders emojis from the emoji-cheat-sheet.com
// Requirements: emojify.js (https://github.com/hassankhan/emojify.js)
// Usage:
//   <p data-bind="message.text | emojify | raw"></p>
Batman.mixin(Batman.Filters, {
  emojify: function(content){
    if(typeof(content) === "undefined" || content === null)
      return undefined;

    return emojify.replace(content);
  }
});
