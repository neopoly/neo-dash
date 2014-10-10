class Dashing.DashboardNotepad extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    $(@node).find('.content').html(data.content)
    console.log($(@node).find('.content'))
    $(@node).fadeOut().fadeIn() # will make the node flash each time data comes in.
