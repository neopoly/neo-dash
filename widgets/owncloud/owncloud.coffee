class Dashing.Owncloud extends Dashing.Widget

  ready: () =>
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
  
  creditsTemplate: (data) =>
    "<div class='credits'>#{data.label} <span>#{data.counter}</span></div>"
  
  foregroundImageTemplate: (image, data) =>
    if(image.width > 0 && image.height > 0)
      target_ratio = @size.w / @size.h
      image_ratio = image.widht / image.height
      factor = 0

      if(target_ratio < image_ratio)
        factor = @size.h / image.height
      else
        factor = @size.w / image.width

      placement = {
        w: image.width * factor,
        h: image.height * factor,
      }

      placement.x = (@size.w - placement.w) / 2
      placement.y = (@size.h - placement.h) / 2

      "<div class='foreground'><img style='position: absolute; width: #{placement.w}px !important; height: #{placement.h}px !important; margin-top: #{placement.y}px; margin-left: #{placement.x}px' src='#{data.url}'></div>"
    else
      ""

  loadImageThen: (data, callback) =>
    image = new Image()
    image.onload = () =>
      callback(image, data)
    image.src = data.url

  updateImage: (data) =>
    window.console.log("update image")
    @loadImageThen(data, (image) =>
      @$widget.children().animate({opacity: 0}, 250, ()=>
        @$widget.children().remove()
        @$widget.append($(@backgroundImageTemplate(image, data)).css("opacity", 0).animate({opacity: 1}, 1300))
        @$widget.append($(@foregroundImageTemplate(image, data)).css("opacity", 0).animate({opacity: 1}, 1000))
        @$widget.append($(@creditsTemplate(data)).css("opacity", 0).animate({opacity: 1}, 1000))
      )
    )
