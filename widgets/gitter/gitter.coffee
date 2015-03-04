class Dashing.Gitter extends Dashing.Widget
  @TIMEOUT = 20000 #ms
  @spoken = []

  ready: =>
    @updateTimestamps()
    @findThingsToSay()

  onData: (data) ->
    @findThingsToSay()

  wasAlreadySpoken: (message_id) =>
    @constructor.spoken.indexOf(message_id) != -1

  markSpoken: (message_id) =>
    @constructor.spoken.push(message_id)

  findThingsToSay: =>
    outer = @

    $(@node).find("[data-item-id]").each ->
      $el = $(@)
      item_id = $el.data("item-id")
      text = $el.find(".message-body").text()
      console.log(text)
      if(!outer.wasAlreadySpoken(item_id) && (text.indexOf("say:") != -1))
        outer.say(text.split("say:").join(""))
        outer.markSpoken(item_id)

    console.log("spoken:", @constructor.spoken)

  say: (text) => 
    if (window.speechSynthesis)
      window.speechSynthesis.speak(new SpeechSynthesisUtterance(text))
    else if (window.console)
      window.console.log(text)

  updateTimestamps: =>
    $(@node).find("[data-timestamp]").each ->
      $el = $(@)
      relative = moment($el.attr("data-timestamp")).relativeShort()
      $el.html(relative)
    window.setTimeout(@updateTimestamps, @constructor.TIMEOUT)