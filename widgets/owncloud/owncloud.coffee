class Dashing.Owncloud extends Dashing.Widget

  ready: (data) =>
    @size = {w: 370, h: 340}
    @$widget = $(@node)
    $initial_data = @$widget.find(".initial-data");
    @updateImage({
      url: $initial_data.find(".data-url").text(),
      label: $initial_data.find(".data-label").text(),
      counter: $initial_data.find(".data-counter").text()
    })

  onData: (data) =>
    @updateImage(data)

  backgroundImageTemplate: (image, data) =>
    offset = 20
    "<div class='background'><img style='width: #{@size.w + 2*offset}px !important; height: #{@size.h + 2*offset}px !important; margin-top: -#{offset}px; margin-left: -#{offset}px' src='#{data.url}'></div>"

  loadImageThen: (data, callback) =>
    image = new Image();
    image.onload = () =>
      callback(image, data)
    image.src = data.url

  updateImage: (data) =>
    @loadImageThen(data, (image) =>
      @$widget.html(
        
        @backgroundImageTemplate(image, data)
      )
    )
