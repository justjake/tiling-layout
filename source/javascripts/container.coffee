####
# Container
#
# Choo-choo all aboard the layout train
# Splittable rect container
####

#= require "util"
#= require "rect"

class Container extends Rect
    # Constants
    VERTICAL = false
    HORIZONTAL = true

    # space between child rectangles
    SPACING = 5

    # derp
    get = (obj, name, params...) ->
        obj["get#{name}"].apply(obj, params)
    set = (obj, name, params...) ->
        console.log("setting #{name} on #{obj} to #{params}")
        obj["set#{name}"].apply(obj, params)

    # size ratios to fixed pixel space
    fix = (rat, total) -> 
        intended = Math.floor(total * rat)
        if intended < 0
            return 0
        return intended


    constructor: (width, height, horiz, spacing) ->
        super(width, height)
        @format = horiz ? HORIZONTAL
        @spacing = spacing ? SPACING #TODO allow other spacing
        @ratio = 1 # how much of our parent's space should we take up?

        @native.className += " horiz" if @format

    # given the number of children we have
    # and our spacing, how many pixels are in
    # our layout space?
    #
    # NO padding is applied on the outside edges
    # Spacing is only used *between* children
    spaceAvailible: ->
        console.log('spess', @getHeight(), @children.length, @spacing)
        if @format is VERTICAL
            @getHeight() - (@children.length - 1) * @spacing
        else
            @getWidth() - (@children.length - 1) * @spacing

    # Get a child's ratio
    # Currently this just splits our space evenly
    ratioOf: (child) ->
        1 / @children.length


    # lay out all children based on our HOR/VERT
    # and dimensions
    layout: ->
        # what set of properties should we use?
        if @format is VERTICAL
            console.group('Vertical layout')
            ord = 'Y'
            off_ord = 'X'
            dim = 'Height'
            off_dim = 'Width'
        else
            console.group('Horiz layout')
            ord = 'X'
            off_ord = 'Y'
            dim = 'Width'
            off_dim = 'Height'

        space_availible = @spaceAvailible()
        space_consumed = 0
        # lay out items
        for c in @children
            # size child
            ## primary dimension
            ratio = @ratioOf(c)
            size = fix(ratio, space_availible)
            console.log("layout ratio: #{ratio}, size: #{size}, spess: #{space_consumed}")
            set(c, dim, size)
            ## other dimension
            set(c, off_dim, get(this, off_dim))

            # set position
            ## primary ord
            set(c, ord, space_consumed)
            ## off ord
            set(c, off_ord, 0)

            # consume space
            space_consumed += size + @spacing
        console.groupEnd()

# export
this.Container = Container
