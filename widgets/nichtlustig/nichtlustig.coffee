class Dashing.Nichtlustig extends Dashing.Widget

  ready: ->
    $widget = $(@node)
    @$image          = $widget.find(".nichtlustig-image-container img").first()
    @image           = @$image[0]
    @canvas          = $widget.find(".nichtlustig-background")[0]
    @canvasSize      = 
      width:  $widget.width()
      height: $widget.height()

    @$image.load @updateBackground
    @is_ready = true

  onData: (data) ->
    if @is_ready && @image.complete
      @$image.trigger('load')

  updateBackground: =>
    context = @canvas.getContext("2d")
    context.drawImage(@image, 1, 1, 2, 2, 0, 0, @canvasSize.width, @canvasSize.height)