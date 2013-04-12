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

    # Base URL to your Jenkins server. "/api/json" will be appendend
    export JENKINS_BUILDS_URL="http://our.ci.domain"
    # How often do we fetch Jenkins status. Defaults to `5s`.
    export JENKINS_BUILDS_EVERY=5s

# Screenshot

![Screenshot](http://github.com/neopoly/neo-dash/raw/master/neo-dash.png)

Quite empty right now.

# TODO

* Extract widgets as own gems (if possible)
