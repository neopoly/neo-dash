class Dashing.Owncloud extends Dashing.Widget

  ready: ->
    $widget = $(@node)
    @$image          = $widget.find(".owncloud-image-container img").first()
    @image           = @$image[0]
    @canvas          = $widget.find(".owncloud-background")[0]
    @canvasSize      = 
      width:  $widget.width()
      height: $widget.height()

    @is_ready = true

  onData: (data) ->
    if @is_ready && @image.complete
      @$image.trigger('load')
