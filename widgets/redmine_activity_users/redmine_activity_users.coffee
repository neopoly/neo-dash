class Dashing.RedmineActivityUsers extends Dashing.Widget
  # How many columns should be used, this should match the CSS
  @COLUMNS = 2

  @accessor "columns", ->
    users = @get("users")
    # Initialize an empty array of columns
    columns = []
    for i in [1..@constructor.COLUMNS]
      columns.push({users: [], projectsCount: 0})

    # Partition the user into columns (groups) based on their amount of projects.
    # Goal is to have an equal amount of user projects in each column.
    # This is a "bin packing problem" which is approxmiated by a greedy algorithm
    if users 
      totalProjects = 0
      for user in users
        totalProjects += user.projects?.length || 0

      # Sort the users by their name
      users.sort (a,b) -> 
        return -1 if a.name < b.name
        return  1 if a.name > b.name
        return  0

      # Each column should have an equal amount of projects
      limit   = Math.ceil(totalProjects / @constructor.COLUMNS)

      # Greedy algorithm
      for user in @get("users")
        placed   = false
        projects = user.projects || []

        for column in columns
          if (column.projectsCount + projects.length) <= limit
            column.users.push user
            column.projectsCount += projects.length
            placed = true
            break

        # use the first column as fallback
        columns[0].users.push(user) unless placed

    # return all columns
    columns