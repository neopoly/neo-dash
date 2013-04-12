class Dashing.JenkinsBuilds extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    if data.failed_jobs.length > 0
      @set('status', 'failed')
    else
      @set('status', 'passed')
    $(@node).removeClass('failed passed')
    $(@node).addClass(@get('status'))
