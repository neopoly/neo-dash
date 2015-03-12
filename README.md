# neo-dash

Dashboard for neopoly with http://shopify.github.com/dashing

# Install

    git clone git@github.com:neopoly/neo-dash.git
    cd neo-dash
    bundle

# ENV

```bash
export JENKINS_BUILDS_URL="http://<host>/api/json"
export REDMINE_ACTIVITY_URL="https://<username>:<password>@<host>/activity.atom?key=<key>"
export AUTH_TOKEN=""

export NICHTLUSTIG_EVERY="5m"
export NICHTLUSTIG_OVERVIEW_URL="http://static.nichtlustig.de/comics/full/"

export ERRBIT_URL=""
export ERRBIT_KEYS="<csv>"

export REDMINE_PROJECT_TIMETABLE_URL="https://<username>:<password>@<host>/projects/orga/issues/gantt.png?month=%{month}&months=4&query_id=18&year=%{year}&zoom=2&r=%{cache_key}"

export DASHBOARD_NOTEPAD_URL='https://<username>:<password>@<host>/projects/orga/wiki/DashboardNotepad.html'
export DASHBOARD_NOTEPAD_EVERY="2m"

export GITTER_ACCESS_TOKEN=""
export GITTER_ROOM_ID=""

export OWNCLOUD_OVERVIEW_URL='http://<host>/public.php?service=files&t=<share_token>'
```

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
