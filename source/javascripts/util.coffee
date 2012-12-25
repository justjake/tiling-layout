####
# Utilities
# Expecially getters/setters
####

# Getters and setters using {get: ->, set: ->} maps
Function::property = (prop_name, fns) ->
    Object.defineProperty(@prototype, prop_name, fns)

# toString support with UUIDs
class Id
    uuid_counter = 0
    uuid = ->
        uuid += 1

    constructor: ->
        @_id = uuid()

    toString: ->
        "#{@constructor.name}<#{@_id}>"

class Set extends Id
    constructor: (arr) ->
        super()
        @_set = {}

        for x in arr
            @add(x)

        add: (x) ->
            if @contains(x)
                return false
            @_set[x] = true

        remove: (x) ->
            if not contains(x)
                return false
            delete @_set[x]

        contains: (x) ->
            @_set[x] == true


# TODO subclass Array to use for Container.managed_windows
# because we need a way to make sure no window is in two places at once

# set up namespace
this.used_namespace = this
this.Id = Id
