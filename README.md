# neo-dash

Dashboard for neopoly with http://shopify.github.com/dashing

# Install

    git clone git@github.com:neopoly/neo-dash.git
    cd neo-dash
    bundle

# Run

    # client need it eventually
    export AUTH_TOKEN="my secret token"

## Jenkins builds widget

    # URL to Jenkins' JSON API.
    export JENKINS_BUILDS_URL="http://our.ci.domain/api/json"
    # How often do we fetch Jenkins status. Defaults to `5s`.
    export JENKINS_BUILDS_EVERY=5s

## Redmine activity widgets

    # URL to your activity feed.
    export REDMINE_ACTIVITY_URL="http://redmine.yourhost.com/activity.atom?key=<secret key>"
    # How often do we fetch the activity. Defaults to `120s`.
    export REDMINE_ACTIVITY_EVERY=120s

# Screenshot

![Screenshot](http://github.com/neopoly/neo-dash/raw/master/neo-dash.png)

Quite empty right now.

# TODO

* Extract widgets as own gems (if possible)
