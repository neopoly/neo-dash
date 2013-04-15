class Dashing.RedmineActivityUsers extends Dashing.Widget
  onData: (data) ->
    $(@node).fadeOut().fadeIn()
