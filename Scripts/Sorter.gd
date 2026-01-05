@tool
extends Node

@export var sort: bool = false: set = ExecuteSort

func ExecuteSort(_value: bool) -> void :

    var children = get_children()


    if children.size() == 0:
        return


    children.sort_custom( func(a, b): return a.name.to_lower() < b.name.to_lower())


    for i in range(children.size()):
        move_child(children[i], i)


    print("Nodes sorted: ", get_child_count())

    sort = false
