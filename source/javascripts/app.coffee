####
# Entry point
####

#= require "util"
#= require "rect"
#= require "container"

window.onload = ->

    W = 1980
    H = 1050

    select_random = ->
        return Math.random() < 0.5

    select_alternate = (initial) ->
        prev = ! initial
        return ->
            prev = ! prev
            return prev

    select_alternate_actual = select_alternate(true)

    super_tree = (cur_depth) ->
        # all params in source
        # duur
        MAX_DEPTH    = 4
        MAX_CHILDREN = 3
        CHILD_CHANCE = 1
        SUBTREE_CHANCE = 1

        DIRECTION = select_random

        # base case
        if cur_depth > MAX_DEPTH
            return new Container(500, 500)

        root = new Container(W, H, DIRECTION())
        while (Math.random() < CHILD_CHANCE) and root.children.length <= MAX_CHILDREN
            if Math.random() < CHILD_CHANCE
                child = super_tree(cur_depth + 1)
            else
                child = new Container(500, 500)
            root.addChild(child)

        return root


    
    create_tree = (dir_selector, count) ->
        # base case: return a plain container
        if count == 0
            return new Container(400, 400)

        # reverse the direction
        root = new Container(W, H, dir_selector())

        empty_child = new Container(400, 400)

        # sub-tree
        full_child = create_tree(dir_selector, count - 1)

        # add children
        root.addChild(empty_child)
        root.addChild(full_child)

        return root

    layout_tree = (container) ->
        container.layout()
        if container.children.length
            for c in container.children
                layout_tree(c)

    root = super_tree(0)
    layout_tree(root)
    console.log(root)

    # break abstractions
    document.body.appendChild(root.native)
