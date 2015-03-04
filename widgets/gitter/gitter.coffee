class Dashing.Gitter extends Dashing.Widget
  @TIMEOUT = 20000 #ms
  @spoken = []

  ready: =>
    @updateTimestamps()
    @findThingsToSay()

  onData: (data) =>
    @findThingsToSay()

  wasAlreadySpoken: (message_id) =>
    @constructor.spoken.indexOf(message_id) != -1

  markSpoken: (message_id) =>
    @constructor.spoken.push(message_id)

  findThingsToSay: =>
    outer = @

    window.setTimeout(
      () => 
        $(@node).find(".gitter-message").each ->
          $el = $(@)
          item_id = $el.data("item-id")
          text = $el.find(".message-body").text()
          # console.log("  text", text)
          if(!outer.wasAlreadySpoken(item_id) && (text.indexOf("say:") != -1))
            # console.log("    -> say!")
            outer.say(text.split("say:").join(""))
            outer.markSpoken(item_id)
        # console.log("after")

        # window.console.log("spoken:", @constructor.spoken)

      , 1000
    )

  say: (text) -> 
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