class Dashing.JenkinsBuilds extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    if data.failed_count > 0
      @set('status', 'failed')
    else
      @set('status', 'passed')
    $(@node).addClass(@get('status'))
