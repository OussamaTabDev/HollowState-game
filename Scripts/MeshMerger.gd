@tool
extends Node3D

@export var noShadows = false
@export var createColliders = false
@export var surface: String
@export var merge: bool = false:
    set = ExecuteMerge

func ExecuteMerge(_value: bool) -> void :

    var outputMesh = MeshInstance3D.new()
    var mergedMesh = ArrayMesh.new()


    var outputColliderR = MeshInstance3D.new()
    var mergedColliderR = ArrayMesh.new()
    var STColliderR = SurfaceTool.new()


    var outputColliderP = MeshInstance3D.new()
    var mergedColliderP = ArrayMesh.new()
    var STColliderP = SurfaceTool.new()


    var materialList = {}


    for child in get_children():

        for element in child.get_children():

            if element is MeshInstance3D:

                if element.name == "Mesh" || element.name == "LOD0":

                    var targetMaterial = element.get_surface_override_material(0)


                    if !materialList.has(targetMaterial):
                        materialList[targetMaterial] = SurfaceTool.new()


                    materialList[targetMaterial].append_from(element.mesh, 0, child.transform)


                    if createColliders:

                        if element.get_child_count() != 0:

                            if element.get_child(0) is StaticBody3D:

                                STColliderR.append_from(element.mesh, 0, child.transform)
                                STColliderP.append_from(element.mesh, 0, child.transform)

                                break


                if createColliders:

                    if element.name == "Collider_R":
                        STColliderR.append_from(element.mesh, 0, child.transform)

                    if element.name == "Collider_P":
                        STColliderP.append_from(element.mesh, 0, child.transform)


    var output = Node3D.new()
    output.name = self.name + "_Merged"
    add_child(output, true)
    output.owner = get_tree().edited_scene_root


    var sortedMaterials = materialList.keys()
    sortedMaterials.sort()


    for material in sortedMaterials:
        var st = materialList[material]
        st.commit(mergedMesh)


    outputMesh.mesh = mergedMesh
    outputMesh.name = "Mesh"
    output.add_child(outputMesh, true)
    outputMesh.set_owner(get_tree().edited_scene_root)


    var surfaceIndex = 0
    for material in sortedMaterials:
        outputMesh.set_surface_override_material(surfaceIndex, material)
        surfaceIndex += 1


    if noShadows:
        outputMesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


    if createColliders:

        mergedColliderR = STColliderR.commit()
        outputColliderR.mesh = mergedColliderR
        outputColliderR.name = "Collider_R"
        output.add_child(outputColliderR, true)
        outputColliderR.set_owner(get_tree().edited_scene_root)
        outputColliderR.set_layer_mask_value(1, false)
        outputColliderR.create_trimesh_collision()
        outputColliderR.get_child(0).name = "StaticBody3D"
        outputColliderR.get_child(0).set_collision_layer_value(1, false)
        outputColliderR.get_child(0).set_collision_layer_value(5, true)
        outputColliderR.get_child(0).set_script(Surface)
        outputColliderR.get_child(0).surface = surface


        mergedColliderP = STColliderP.commit()
        outputColliderP.mesh = mergedColliderP
        outputColliderP.name = "Collider_P"
        output.add_child(outputColliderP, true)
        outputColliderP.set_owner(get_tree().edited_scene_root)
        outputColliderP.set_layer_mask_value(1, false)
        outputColliderP.create_trimesh_collision()
        outputColliderP.get_child(0).name = "StaticBody3D"
        outputColliderP.get_child(0).set_collision_layer_value(1, false)
        outputColliderP.get_child(0).set_collision_layer_value(6, true)
        outputColliderP.get_child(0).set_script(Surface)
        outputColliderP.get_child(0).surface = surface

    merge = false
