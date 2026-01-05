@tool
extends Node3D


const poleGround = preload("res://Terrains/Utility/Pole_Ribbon_Ground.tscn")
const poleWater = preload("res://Terrains/Utility/Pole_Ribbon_Water.tscn")
const ribbonMaterial = preload("res://Terrains/Utility/Files/MT_Ribbon.tres")


@export var generatePoles: bool = false: set = ExecuteGeneratePoles
@export var generateRibbon: bool = false: set = ExecuteGenerateRibbon
@export var generateCollider: bool = false: set = ExecuteGenerateCollider
@export var clear: bool = false: set = ExecuteClear

func ExecuteGeneratePoles(_value: bool) -> void :

    var poles = Node3D.new()
    poles.name = "Poles"
    add_child(poles, true)
    poles.set_owner(get_tree().edited_scene_root)


    var playableArea = 360.0
    var poleSpacing = 10.0
    var polesPerSide = int(playableArea / poleSpacing)
    var totalPoles = polesPerSide * 4


    for i in totalPoles:
        var x: float
        var z: float


        if i < polesPerSide:

            x = - playableArea / 2.0 + i * poleSpacing
            z = - playableArea / 2.0
        elif i < polesPerSide * 2:

            x = playableArea / 2.0
            z = - playableArea / 2.0 + (i - polesPerSide) * poleSpacing
        elif i < polesPerSide * 3:

            x = playableArea / 2.0 - (i - polesPerSide * 2) * poleSpacing
            z = playableArea / 2.0
        else:

            x = - playableArea / 2.0
            z = playableArea / 2.0 - (i - polesPerSide * 3) * poleSpacing


        var ray = PhysicsRayQueryParameters3D.create(Vector3(x, 100.0, z), Vector3(x, -100, z))
        var hit = get_world_3d().direct_space_state.intersect_ray(ray)

        if hit:

            if hit.collider.surface == "Water":

                var pole = poleWater.instantiate()
                poles.add_child(pole, true)
                pole.set_owner(get_tree().edited_scene_root)
                pole.global_position = hit.position
                poleSpacing = 20.0
            else:

                var pole = poleGround.instantiate()
                poles.add_child(pole, true)
                pole.set_owner(get_tree().edited_scene_root)
                pole.global_position = hit.position
                poleSpacing = 10.0

    generatePoles = false

func ExecuteGenerateRibbon(_value: bool) -> void :

    var poles = get_node("Poles").get_children()


    var output = MeshInstance3D.new()
    output.name = "Mesh"
    add_child(output, true)
    output.set_owner(get_tree().edited_scene_root)


    var ST = SurfaceTool.new()
    ST.begin(Mesh.PRIMITIVE_TRIANGLES)
    ST.set_material(ribbonMaterial)


    var ribbonWidth = 0.05
    var crossSection = [Vector3(0, ribbonWidth, 0), Vector3(0, - ribbonWidth, 0)]


    var vertexCount = 0


    for i in poles.size():

        var currentPole = poles[i]
        var nextPole = poles[(i + 1) % poles.size()]


        var currentRibbonHeight = 1.0
        var nextRibbonHeight = 1.0


        if currentPole.name.contains("Ground"):
            currentRibbonHeight = 1.4
        elif currentPole.name.contains("Water"):
            currentRibbonHeight = 0.9


        if currentPole.name.contains("Break"):
            continue
        elif nextPole.name.contains("Ground"):
            nextRibbonHeight = 1.4
        elif currentPole.name.contains("Water"):
            nextRibbonHeight = 0.9


        var polePosition = currentPole.global_position + Vector3(0, currentRibbonHeight, 0)
        var nextPolePosition = nextPole.global_position + Vector3(0, nextRibbonHeight, 0)


        var curve = Curve3D.new()
        var points = 10


        for index in range(points + 1):
            var progress = float(index) / points
            var point = polePosition.lerp(nextPolePosition, progress)
            point.y -= 1.0 * progress * (1.0 - progress)
            curve.add_point(point)


        var density = 0.5
        var length = curve.get_baked_length()
        var steps = int(length * density) + 1
        var stepSize = length / steps if steps > 0 else length


        for index in range(steps + 1):
            var point = curve.sample_baked(index * stepSize)
            var nextPoint = curve.sample_baked(min((index + 1) * stepSize, length))
            var forward = (nextPoint - point).normalized() if index < steps else (point - curve.sample_baked((index - 1) * stepSize)).normalized()
            var up = Vector3.UP
            var right = forward.cross(up).normalized()
            var normal = up.cross(forward).normalized()


            var uCoord = index * stepSize / length if length > 0 else 0.0


            for cornerIndex in range(2):
                var crossPoint = crossSection[cornerIndex]
                var vertex = point + up * crossPoint.y
                var vCoord = 0.0 if cornerIndex == 0 else 1.0
                ST.set_uv(Vector2(uCoord, vCoord))
                ST.set_normal(right)
                ST.generate_tangents()
                ST.add_vertex(vertex)
                vertexCount += 1


            if index > 0:
                var idx = vertexCount - 2
                var idxPrev = vertexCount - 4
                var idxNext = vertexCount - 1
                var idxPrevNext = vertexCount - 3
                ST.add_index(idxPrev)
                ST.add_index(idx)
                ST.add_index(idxNext)
                ST.add_index(idxPrev)
                ST.add_index(idxNext)
                ST.add_index(idxPrevNext)


    if vertexCount > 0:
        output.mesh = ST.commit()
        output.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

    generateRibbon = false

func ExecuteGenerateCollider(_value: bool) -> void :

    var poles = get_node("Poles").get_children()


    var output = MeshInstance3D.new()
    output.name = "Collider"
    add_child(output, true)
    output.set_owner(get_tree().edited_scene_root)


    var ST = SurfaceTool.new()
    ST.begin(Mesh.PRIMITIVE_TRIANGLES)


    var colliderWidth = 5.0
    var crossSection = [Vector3( - colliderWidth / 2.0, 0, 0), Vector3(colliderWidth / 2.0, 0, 0)]


    var vertexCount = 0


    for i in poles.size():

        var currentPole = poles[i]
        var nextPole = poles[(i + 1) % poles.size()]


        var colliderHeight = 1.5
        var polePosition = currentPole.global_position + Vector3(0, colliderHeight, 0)
        var nextPolePosition = nextPole.global_position + Vector3(0, colliderHeight, 0)


        var curve = Curve3D.new()
        var points = 10


        for index in range(points + 1):
            var progress = float(index) / points
            var point = polePosition.lerp(nextPolePosition, progress)
            curve.add_point(point)


        var density = 0.1
        var length = curve.get_baked_length()
        var steps = int(length * density) + 1
        var stepSize = length / steps if steps > 0 else length


        for index in range(steps + 1):
            var point = curve.sample_baked(index * stepSize)
            var nextPoint = curve.sample_baked(min((index + 1) * stepSize, length))
            var forward = (nextPoint - point).normalized() if index < steps else (point - curve.sample_baked((index - 1) * stepSize)).normalized()
            var up = Vector3.UP
            var right = forward.cross(up).normalized()


            for cornerIndex in range(2):
                var crossPoint = crossSection[cornerIndex]
                var vertex = point + right * crossPoint.x
                var vCoord = 0.0 if cornerIndex == 0 else 1.0
                ST.add_vertex(vertex)
                vertexCount += 1


            if index > 0:
                var idx = vertexCount - 2
                var idxPrev = vertexCount - 4
                var idxNext = vertexCount - 1
                var idxPrevNext = vertexCount - 3
                ST.add_index(idxPrev)
                ST.add_index(idx)
                ST.add_index(idxNext)
                ST.add_index(idxPrev)
                ST.add_index(idxNext)
                ST.add_index(idxPrevNext)


    if vertexCount > 0:
        output.mesh = ST.commit()
        output.set_layer_mask_value(1, false)

        output.create_trimesh_collision()
        output.get_child(0).name = "StaticBody3D"
        output.get_child(0).set_collision_layer_value(1, false)
        output.get_child(0).set_collision_layer_value(31, true)
        output.get_child(0).set_collision_mask_value(1, false)

    generateCollider = false

func ExecuteClear(_value: bool) -> void :

    var childCount = get_child_count()


    if childCount != 0 && childCount < 4:
        for child in get_children():
            if child.name == "Poles" || child.name == "Mesh" || child.name == "Collider":
                remove_child(child)
                child.queue_free()

    clear = false
