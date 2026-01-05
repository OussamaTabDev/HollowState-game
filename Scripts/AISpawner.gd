extends Node3D


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


@export var active = true
var debug = false


enum Zone{Area05, BorderZone, Vostok}
@export var zone = Zone.Area05


enum Frequency{Low, Medium, High, Debug}
@export var spawnFrequency = Frequency.Medium
@export var spawnDistance = 100
@export var spawnLimit = 3
@export var spawnPool = 10

@export_group("Initial Agents")
@export var initialGuard = false
@export var initialHider = false
@export var initialGroup = false
@export var guardChange = 0
@export var hiderChange = 0
@export var groupChange = 0

@export_group("Map Rules")
@export var noHiding = false
@export var noEvade = false

@export_group("Debug")
@export var sensorBlocked = false
@export var fireBlocked = false
@export var damageBlocked = false
@export var forcePistol = false
@export var forceRifle = false
@export var forceHeadlamps = false
@export var forceCombat = false
@export var forceDefend = false
@export var forceHunt = false
@export var forceAttack = false
@export var forceCover = false
@export var allowIK = false
@export var noVelocity = false
@export var inversePoles = false
@export var noSensorDelay = false
@export var noAnimationDelay = false
@export var infiniteHealth = false


var bandit = preload("res://AI/Bandit/AI_Bandit.tscn")
var guard = preload("res://AI/Guard/AI_Guard.tscn")
var military = preload("res://AI/Military/AI_Military.tscn")
var activeAgents = 0
var agent


var spawnTime = 1.0
var spawnTimer = 0.0


var spawns: Array
var waypoints: Array
var patrols: Array
var covers: Array
var hides: Array
var groups: Array
var BTR: Array


@onready var pool = $Pool
@onready var agents = $Agents


var groupAlerted = false

func _ready():

    GetPoints()
    HidePoints()


    if !active:
        return


    if zone == Zone.Area05:
        agent = bandit
    elif zone == Zone.BorderZone:
        agent = guard
    elif zone == Zone.Vostok:
        agent = military


    CreatePool()


    if initialGuard:
        var guardRoll = randi_range(0, 100)
        if guardRoll < guardChange:
            SpawnGuard()


    if initialHider:
        var hiderRoll = randi_range(0, 100)
        if hiderRoll < hiderChange:
            SpawnHider()


    if initialGroup:
        var groupRoll = randi_range(0, 100)
        if groupRoll < groupChange:
            SpawnGroup()

func _physics_process(delta):

    if !active:
        return

    spawnTime -= delta


    if spawnTime <= 0:

        if activeAgents < spawnLimit:
            SpawnWanderer()

        elif spawnFrequency != Frequency.Debug:
            print("AI Spawner: Spawn limit reached")


        if spawnFrequency == Frequency.Low:
            spawnTime = randf_range(60, 120)
        elif spawnFrequency == Frequency.Medium:
            spawnTime = randf_range(10, 60)
        elif spawnFrequency == Frequency.High:
            spawnTime = randf_range(1, 10)
        elif spawnFrequency == Frequency.Debug:
            spawnTime = 1

func CreatePool():

    pool.global_position = Vector3(0, 1000, 0)


    for amount in spawnPool:

        var newAgent = agent.instantiate()
        pool.add_child(newAgent)


        newAgent.AISpawner = self
        newAgent.global_position = pool.global_position + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
        newAgent.Pause()

    print("AI Spawner: Pool created")

func SpawnWanderer():

    if pool.get_child_count() == 0:
        print("AI Spawner: Pool ended (Wanderer)")
        return


    var validPoints: Array[Node3D]


    for point in spawns:

        var distanceToPlayer = point.global_position.distance_to(gameData.playerPosition)

        if distanceToPlayer > spawnDistance:

            validPoints.append(point)


    if validPoints.size() != 0:

        var spawnPoint = validPoints[randi_range(0, validPoints.size() - 1)]


        var newAgent = pool.get_child(0)
        newAgent.reparent(agents)


        newAgent.global_transform = spawnPoint.global_transform
        newAgent.currentPoint = spawnPoint


        newAgent.ActivateWanderer()
        activeAgents += 1
        print("AI Spawner: Agent active (Wanderer)")
    else:
        print("AI Spawner: No valid spawn points (Wanderer)")

func SpawnGuard():

    if pool.get_child_count() == 0:
        print("AI Spawner: Pool ended (Guard)")
        return


    if patrols.size() != 0:

        var patrolPoint = patrols[randi_range(0, patrols.size() - 1)]


        var newAgent = pool.get_child(0)
        newAgent.reparent(agents)


        newAgent.global_transform = patrolPoint.global_transform
        newAgent.currentPoint = patrolPoint


        newAgent.ActivateGuard()
        activeAgents += 1
        print("AI Spawner: Agent active (Guard)")
    else:
        print("AI Spawner: No valid patrol points (Guard)")

func SpawnHider():
    if pool.get_child_count() == 0:
        print("Spawn blocked (Hider): Pool ended")
        return


    var randomIndex = randi_range(0, hides.size() - 1)
    var hidePoint = hides[randomIndex]


    var newAgent = pool.get_child(0)
    newAgent.reparent(agents)


    newAgent.global_transform = hidePoint.global_transform
    newAgent.currentPoint = hidePoint


    newAgent.ActivateHider()
    activeAgents += 1
    print("Hider spawned")

func SpawnGroup():
    if pool.get_child_count() == 0:
        print("Spawn blocked (Group): Pool ended")
        return


    var randomIndex = randi_range(0, groups.size() - 1)
    var group = groups[randomIndex]


    for groupPoint in group.get_children():

        var newAgent = pool.get_child(0)
        newAgent.reparent(agents)


        newAgent.global_transform = groupPoint.global_transform
        newAgent.currentPoint = groupPoint


        newAgent.ActivateGroup()
        activeAgents += 1
        print("GROUP SPAWNED")

func AlertGroup():
    if !groupAlerted:
        groupAlerted = true
        print("Group Alerted")

        for child in agents.get_children():
            if child.currentState == child.State.Group:
                await get_tree().create_timer(randi_range(0, 2), false).timeout;
                child.lastKnownLocation = gameData.playerPosition
                child.Decision()

func AlertGuards():

    PlayVostokEnter()


    if agents.get_child_count() != 0:

        for child in agents.get_children():
            await get_tree().create_timer(randf_range(0.5, 2.0), false).timeout;
            child.lastKnownLocation = gameData.playerPosition
            child.attackReturn = true
            child.ChangeState("Attack")

    await get_tree().create_timer(10.0).timeout;


    if agents.get_child_count() != 0:

        for child in agents.get_children():
            await get_tree().create_timer(randf_range(0.5, 2.0), false).timeout;
            child.lastKnownLocation = gameData.playerPosition

func DestroyAllAI():
    activeAgents = 0
    var childCount = agents.get_child_count()

    if childCount != 0:
        for child in agents.get_children():
            remove_child(child)
            child.queue_free()

func GetPoints():
    spawns = get_tree().get_nodes_in_group("AI_SP")
    waypoints = get_tree().get_nodes_in_group("AI_WP")
    patrols = get_tree().get_nodes_in_group("AI_PP")
    covers = get_tree().get_nodes_in_group("AI_CP")
    hides = get_tree().get_nodes_in_group("AI_HP")
    groups = get_tree().get_nodes_in_group("AI_GP")
    BTR = get_tree().get_nodes_in_group("AI_BTR")

func ShowPoints():
    for point in spawns:
        point.show()
    for point in waypoints:
        point.show()
    for point in patrols:
        point.show()
    for point in covers:
        point.show()
    for point in hides:
        point.show()
    for point in groups:
        point.show()
    for point in BTR:
        point.show()

func HidePoints():
    for point in spawns:
        point.hide()
    for point in waypoints:
        point.hide()
    for point in patrols:
        point.hide()
    for point in covers:
        point.hide()
    for point in hides:
        point.hide()
    for point in groups:
        point.hide()
    for point in BTR:
        point.hide()

func ShowGizmos():
    var childCount = agents.get_child_count()

    if childCount != 0:
        for child in agents.get_children():
            child.ShowGizmos()

func HideGizmos():
    var childCount = agents.get_child_count()

    if childCount != 0:
        for child in agents.get_children():
            child.HideGizmos()

func ForceState(state):
    var childCount = agents.get_child_count()

    if childCount != 0:
        for child in agents.get_children():
            child.ChangeState(state)

func AIHide():
    var childCount = agents.get_child_count()

    if childCount != 0:
        for child in agents.get_children():
            child.animator.active = false
            child.hide()
            child.pause = true

func AIShow():
    var childCount = agents.get_child_count()

    if childCount != 0:
        for child in agents.get_children():
            child.animator.active = true
            child.show()
            child.pause = false

func PlayVostokEnter():
    var vostokEnter = audioInstance2D.instantiate()
    add_child(vostokEnter)
    vostokEnter.PlayInstance(audioLibrary.vostokEnter)
