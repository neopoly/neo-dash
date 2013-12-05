class Dashing.RemoteImage extends Dashing.Widget

  ready: ->

  onData: (data) ->
    $(@node).fadeOut().fadeIn()
