####
# Container
#
# Choo-choo all aboard the layout train
# Splittable rect container
####

#= require "util"
#= require "rect"
#= require "seam"

class Container extends Rect
    # Constants
    VERTICAL = false
    HORIZONTAL = true

    # when splitting / adding windows
    BEFORE = true
    AFTER  = false

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


    constructor: (width, height, horiz = HORIZONTAL, spacing = SPACING) ->
        super(width, height)
        @format = horiz
        @spacing = spacing
        @ratio = 1 # how much of our parent's space should we take up?

        @managed_windows = []
        @seams = []

        @native.className += " horiz" if @format

    # given the number of children we have
    # and our spacing, how many pixels are in
    # our layout space?
    #
    # NO padding is applied on the outside edges
    # Spacing is only used *between* children
    spaceAvailible: ->
        console.log('spess', @getHeight(), @managed_windows.length, @spacing)
        if @format is VERTICAL
            @getHeight() - (@managed_windows.length - 1) * @spacing
        else
            @getWidth() - (@managed_windows.length - 1) * @spacing

    # Get a child's ratio
    # Currently this just splits our space evenly
    ratioOf: (child) ->
        1 / @managed_windows.length

    _layoutParams: ->
        params = {}
        if @format is VERTICAL
            params.ord = 'Y'
            params.off_ord = 'X'
            params.dim = 'Height'
            params.off_dim = 'Width'
        else
            params.ord = 'X'
            params.off_ord = 'Y'
            params.dim = 'Width'
            params.off_dim = 'Height'
        return params


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
        for c in @managed_windows
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

        # lay out seams
        @layoutSeams()

    # Add a managed window, which is part of layout stuff
    addWindow: (win) ->
        @addChild(win)
        @managed_windows.push(win)


    # low-level
    addWindowAtIndex: (win, idx, side = BEFORE) ->
        @addChild(win)
        if side == BEFORE
            @managed_windows.splice(idx, 0, win)
        else
            idx = @managed_windows.length + idx if idx < 0
            @managed_windows.splice(idx + 1, 0, win)

    # transform existing windows ratios to make room for new window
    # preservign thier scale to each other
    addNewWindowAtIndex: (win, idx, side = BEFORE) ->
        @addChild(win)

        # tranform exisiting to make even space for new window
        transform = @managed_windows.length / (@managed_windows.length + 1)
        for w in @managed_windows
            w.ratio = w.ratio * transform

        # insert window and set ratio
        @addWindowAtIndex(win, idx, side)
        win.ratio = 1 / @managed_windows.length

    # add a window at the top/left of the container
    # preserve the other window's relationshipts to each other,
    # giving the new window 1/N space where N is the number of total windows
    addFirst: (win) ->
        @addNewWindowAtIndex(win, 0)

    addLast: (win) ->
        @addNewWindowAtIndex(win, -1, AFTER)


    # split the space used by a current window
    splitWindowAtIndex: (win, idx, side = BEFORE) ->
        cur = @managed_windows[idx]
        # half of the current space used for each window
        ratio = cur.ratio / 2
        cur.ratio = ratio
        win.ratio = ratio
        @addWindowAtIndex(win, idx, side)


    # add a seam
    # TODO: make event handlers for seams
    addSeam: (index) ->
        seam = new Seam(this, index)
        @addChild(seam)
        @seams[index] = seam

    # create seams and move them into position
    layoutSeams: ->
        # create any undefined seams
        i = 0
        len = @managed_windows.length - 1
        while i < len
            if not @seams[i]?
                @addSeam(i)
            i += 1

        # lay out seams
        p = @_layoutParams()
        for s in @seams
            # set dimensions
            set(s, p.off_dim, get(this, p.off_dim))
            set(s, p.dim, @spacing)

            # set position
            after = @managed_windows[s.index]
            set(s, p.ord, get(after, p.ord) + get(after, p.dim))
            set(s, p.off_ord, 0)

            # win.



# export
this.Container = Container
