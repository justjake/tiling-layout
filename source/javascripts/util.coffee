####
# Utilities
# Expecially getters/setters
####

# Getters and setters using {get: ->, set: ->} maps
Function::property = (prop_name, fns) ->
    Object.defineProperty(@prototype, prop_name, fns)

# set up namespace
this.used_namespace = this
