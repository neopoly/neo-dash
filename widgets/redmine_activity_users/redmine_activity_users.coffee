class Dashing.RedmineActivityUsers extends Dashing.Widget
  @TIMEOUT = 10000 #ms

  onData: (data) ->
    clearInterval @interval if @interval
    if data.users.length > 0
      @start()

  start: ->
    @views().hide()
    @firstView().show()

    @index = 0
    @startAnimation()

  startAnimation: ->
    @interval = setInterval @animateView, @constructor.TIMEOUT

  animateView: =>
    @currentView().hide()
    @determineNextView()
    if @views().length == 1
      @currentView().show()
    else
      @currentView().fadeIn()

  determineNextView: ->
    if (@index + 1) >= @views().length
      @index = 0
    else
      @index += 1

  currentView: ->
    $(@views()[@index])

  firstView: ->
    $(@views()[0])

  views: ->
    $(@node).find "ol.users > li"