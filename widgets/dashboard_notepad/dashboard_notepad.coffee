class Dashing.DashboardNotepad extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    $(@node).fadeOut().fadeIn() # will make the node flash each time data comes in.
