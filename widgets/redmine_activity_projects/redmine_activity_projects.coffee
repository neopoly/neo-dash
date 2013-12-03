class Dashing.RedmineActivityProjects extends Dashing.Widget
  @TIMEOUT = 5000 #ms

  constructor: () ->
    super
    @currentIndex = 0
    @cycleUsers() # start the timed cycling

  onData: (data) =>
   @expandUser()

  cycleUsers: =>
    @expandUser()
    @currentIndex++
    window.setTimeout(@cycleUsers, @constructor.TIMEOUT)

  expandUser: =>
    projects = $(@node).find("ol.projects > li.project")
    if(projects.size() > 0)
      @currentIndex = @currentIndex % projects.size()
      projects.each (index, el) =>
        if index == @currentIndex
          $(el).addClass("full")
        else
          $(el).removeClass("full")
