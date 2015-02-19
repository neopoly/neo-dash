class Dashing.Gitter extends Dashing.Widget
  @TIMEOUT = 20000 #ms

  ready: =>
    @updateTimestamps()

  updateTimestamps: =>
    $(@node).find("[data-timestamp]").each ->
      $el = $(@)
      relative = moment($el.attr("data-timestamp")).relativeShort()
      $el.html(relative)
    window.setTimeout(@updateTimestamps, @constructor.TIMEOUT)