class Dashing.DashboardNotepad extends Dashing.Widget

  ready: ->
    @splitListItems()

  onData: (data) ->
    @splitListItems()

  splitListItems: =>
    $(@node).find("ul li").each ->
      $el = $(@)
      segments = $el.html().split(":")
      if segments.length > 1
        $el.html(
          "<span class='label'>"+segments.shift()+"</span>" +
          "<span class='value'>"+segments.join(":")+"</span>"
        )
