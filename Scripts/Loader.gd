extends CanvasLayer


var gameData = preload("res://Resources/GameData.tres")
var audioLibrary = preload("res://Resources/AudioLibrary.tres")
var audioInstance2D = preload("res://Resources/AudioInstance2D.tscn")


const message = preload("res://UI/Elements/Message.tscn")


var gameVersion = "RTV_Demo"


@onready var screen = $Screen
@onready var overlay = $Overlay
@onready var animation = $Animation
@onready var label = $Screen / Label
@onready var circle = $Screen / Circle


const Menu = "res://Scenes/Menu.tscn"
const Death = "res://Scenes/Death.tscn"
const Tutorial = "res://Scenes/Tutorial.tscn"
const Cabin = "res://Scenes/Cabin.tscn"
const Village = "res://Scenes/Village.scn"
const Minefield = "res://Scenes/Minefield.scn"
const Apartments = "res://Scenes/Apartments.scn"
const Template = "res://Scenes/Template.scn"
var area05Scenes = [Template, Template, Template]
var scenePath: String


@export var startingKits: Array[LootTable]

var masterBus = AudioServer.get_bus_index("Master")
var masterAmplify: AudioEffectAmplify = AudioServer.get_bus_effect(0, 1)
var masterValue = 0.0
var masterActive = false

func _ready():
	if masterAmplify:
		masterAmplify.volume_db = linear_to_db(0.0)



func CreateVersion():

	var version: Version = Version.new()

	version.name = gameVersion

	ResourceSaver.save(version, "user://Version.tres")
	print("Version created: " + gameVersion)

func ValidateVersion() -> bool:

	if !FileAccess.file_exists("user://Version.tres"):
		print("Version missing -> Format all")
		return false


	else:

		var version = load("user://Version.tres") as Version

		if version.name == gameVersion:

			print("Version valid")
			return true


	print("Version invalid -> Format all")
	return false

func ValidateShelter() -> bool:

	if !FileAccess.file_exists("user://Cabin.tres"):
		print("Shelter missing -> Load disabled")
		return false


	print("Shelter available -> Load available")
	return true

func FormatAll():

	var directory = DirAccess.open("user://")


	if !directory:
		print("Error accessing user:// directory")
		return


	directory.list_dir_begin()
	var file = directory.get_next()


	while file != "":

		if file.ends_with(".tres"):

			var filePath = "user://" + file

			var removal = directory.remove(filePath)

			if removal == OK:
				print("File removed: " + file)

			else:
				print("File removal failed: " + file)


		file = directory.get_next()


	directory.list_dir_end()


	var preferences: Preferences = Preferences.new()
	ResourceSaver.save(preferences, "user://Preferences.tres")
	print("Preferences resetted")

func FormatSave():

	var directory = DirAccess.open("user://")


	if !directory:
		print("Error accessing user:// directory")
		return


	directory.list_dir_begin()
	var file = directory.get_next()


	while file != "":

		if file.ends_with(".tres") && file != "Version.tres" && file != "Preferences.tres":

			var filePath = "user://" + file

			var removal = directory.remove(filePath)

			if removal == OK:
				print("File removed: " + file)

			else:
				print("File removal failed: " + file)


		file = directory.get_next()


	directory.list_dir_end()

func CurrentSeason() -> int:

	if !FileAccess.file_exists("user://World.tres"):
		return 0


	var world: WorldSave = load("user://World.tres") as WorldSave


	var currentSeason = world.season
	return currentSeason

func ForceSeason(season: int):

	if !FileAccess.file_exists("user://World.tres"):
		return


	var world: WorldSave = load("user://World.tres") as WorldSave

	if season == 1:
		world.season = 1
	elif season == 2:
		world.season = 2


	ResourceSaver.save(world, "user://World.tres")
	print("SAVE: World (Season override) | Forced to " + str(season))



func LoadScene(scene: String):
	FadeInLoading()
	gameData.freeze = true


	if scene == "Menu" || scene == "Death":
		label.hide()
		circle.hide()
	else:
		label.show()
		circle.show()

	if label.visible:
		label.text = "Loading " + scene + "..."



	if scene == "Menu":
		scenePath = Menu
	elif scene == "Death":
		scenePath = Death
	elif scene == "Tutorial":
		scenePath = Tutorial
		gameData.menu = false
		gameData.shelter = false
		gameData.permadeath = false
		gameData.tutorial = true



	elif scene == "Cabin":
		scenePath = Cabin
		gameData.menu = false
		gameData.shelter = true
		gameData.permadeath = false
		gameData.tutorial = false



	elif scene == "Village":
		scenePath = Village
		gameData.menu = false
		gameData.shelter = false
		gameData.permadeath = false
		gameData.tutorial = false



	elif scene == "Minefield":
		scenePath = Minefield
		gameData.menu = false
		gameData.shelter = false
		gameData.permadeath = false
		gameData.tutorial = false



	elif scene == "Apartments":
		scenePath = Apartments
		gameData.menu = false
		gameData.shelter = false
		gameData.permadeath = true
		gameData.tutorial = false



	elif scene == "Template":
		scenePath = Template
		gameData.menu = false
		gameData.shelter = false
		gameData.permadeath = false
		gameData.tutorial = true

	await get_tree().create_timer(2.0).timeout;
	get_tree().change_scene_to_file(scenePath)

func LoadSceneRandom():
	FadeInLoading()
	HideCursor()
	gameData.freeze = true
	gameData.menu = false
	gameData.shelter = false
	gameData.permadeath = false
	gameData.tutorial = false
	await get_tree().create_timer(2.0).timeout;
	var randomScene = randf_range(0, area05Scenes.size() - 1)
	get_tree().change_scene_to_file(area05Scenes[randomScene])



func NewGame(difficulty, season):



	var world: WorldSave = WorldSave.new()
	world.difficulty = difficulty
	world.season = season
	world.day = 1
	world.time = 1200
	ResourceSaver.save(world, "user://World.tres")



	var character: CharacterSave = CharacterSave.new()
	character.initialSpawn = true


	if world.difficulty == 1:
		if startingKits.size() != 0:
			var randomKit = randi_range(0, startingKits.size() - 1)
			if startingKits[randomKit].items.size() != 0:
				character.startingKit = startingKits[randomKit]

	ResourceSaver.save(character, "user://Character.tres")
	print("Loader: Starting kit set")



	var generalist: TraderSave = TraderSave.new()
	ResourceSaver.save(generalist, "user://Generalist.tres")



	var shelter: ShelterSave = ShelterSave.new()
	shelter.initialSpawn = true
	ResourceSaver.save(shelter, "user://Cabin.tres")

	print("Loader: New Game (" + str(difficulty) + " / " + str(season) + ")")

func ResetCharacter():

	var character: CharacterSave = CharacterSave.new()


	ResourceSaver.save(character, "user://Character.tres")
	print("Loader: Reset Character")



func SaveCharacter():

	var character: CharacterSave = CharacterSave.new()


	character.initialSpawn = false
	character.startingKit = null


	var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")


	character.health = gameData.health
	character.energy = gameData.energy
	character.hydration = gameData.hydration
	character.mental = gameData.mental
	character.temperature = gameData.temperature
	character.cat = gameData.cat
	character.bodyStamina = gameData.bodyStamina
	character.armStamina = gameData.armStamina
	character.overweight = gameData.overweight
	character.starvation = gameData.starvation
	character.dehydration = gameData.dehydration
	character.bleeding = gameData.bleeding
	character.fracture = gameData.fracture
	character.burn = gameData.burn
	character.frostbite = gameData.frostbite
	character.insanity = gameData.insanity
	character.rupture = gameData.rupture
	character.headshot = gameData.headshot


	character.primary = gameData.primary
	character.secondary = gameData.secondary
	character.knife = gameData.knife
	character.grenade1 = gameData.grenade1
	character.grenade2 = gameData.grenade2
	character.flashlight = gameData.flashlight
	character.NVG = gameData.NVG


	character.inventory.clear()
	character.equipment.clear()
	character.catalog.clear()


	for item in interface.inventoryGrid.get_children():

		var newSlotData = SlotData.new()
		newSlotData.Update(item.slotData)

		newSlotData.GridSave(item.position, item.rotated)

		character.inventory.append(newSlotData)


	for equipmentSlot in interface.equipment.get_children():
		if equipmentSlot is Slot && equipmentSlot.get_child_count() != 0:

			var slotItem = equipmentSlot.get_child(0)

			var newSlotData = SlotData.new()
			newSlotData.Update(slotItem.slotData)

			newSlotData.SlotSave(equipmentSlot.name)

			character.equipment.append(newSlotData)


	for item in interface.catalogGrid.get_children():

		var newSlotData = SlotData.new()
		newSlotData.Update(item.slotData)

		newSlotData.GridSave(item.position, item.rotated)


		if item.slotData.storage.size() != 0:
			newSlotData.storage = item.slotData.storage


		character.catalog.append(newSlotData)


	ResourceSaver.save(character, "user://Character.tres")
	print("SAVE: Character")

func LoadCharacter():

	await get_tree().create_timer(0.1).timeout;


	if !FileAccess.file_exists("user://Character.tres"):
		return


	var character: CharacterSave = load("user://Character.tres") as CharacterSave


	var rigManager = get_tree().current_scene.get_node("/root/Map/Core/Camera/Manager")
	var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")
	var flashlight = get_tree().current_scene.get_node("/root/Map/Core/Camera/Flashlight")
	var NVG = get_tree().current_scene.get_node("/root/Map/Core/UI/NVG")


	if character.initialSpawn && character.startingKit:
		for item in character.startingKit.items:
			var newSlotData = SlotData.new()
			newSlotData.itemData = item

			if newSlotData.itemData.stackable:
				newSlotData.amount = newSlotData.itemData.defaultAmount

			interface.Create(newSlotData, interface.inventoryGrid, false)


	for slotData in character.inventory:
		interface.LoadGridItem(slotData, interface.inventoryGrid, slotData.gridPosition)


	for slotData in character.equipment:
		interface.LoadSlotItem(slotData, slotData.slot)


	for slotData in character.catalog:
		interface.LoadGridItem(slotData, interface.catalogGrid, slotData.gridPosition)


	interface.UpdateStats(false)


	gameData.health = character.health
	gameData.energy = character.energy
	gameData.hydration = character.hydration
	gameData.mental = character.mental
	gameData.temperature = character.temperature
	gameData.cat = character.cat
	gameData.bodyStamina = character.bodyStamina
	gameData.armStamina = character.armStamina
	gameData.overweight = character.overweight
	gameData.starvation = character.starvation
	gameData.dehydration = character.dehydration
	gameData.bleeding = character.bleeding
	gameData.fracture = character.fracture
	gameData.burn = character.burn
	gameData.frostbite = character.frostbite
	gameData.insanity = character.insanity
	gameData.rupture = character.rupture
	gameData.headshot = character.headshot


	gameData.primary = character.primary
	gameData.secondary = character.secondary
	gameData.knife = character.knife
	gameData.grenade1 = character.grenade1
	gameData.grenade2 = character.grenade2
	gameData.flashlight = character.flashlight
	gameData.NVG = character.NVG


	if gameData.primary:
		rigManager.LoadPrimary()
		gameData.weaponPosition = character.weaponPosition
	elif gameData.secondary:
		rigManager.LoadSecondary()
		gameData.weaponPosition = character.weaponPosition
	elif gameData.knife:
		rigManager.LoadKnife()
	elif gameData.grenade1:
		rigManager.LoadGrenade1()
	elif gameData.grenade2:
		rigManager.LoadGrenade2()


	if gameData.NVG:
		NVG.Load()
	if gameData.flashlight:
		flashlight.Load()


	UpdateProgression()

	print("LOAD: Character")



func SaveWorld():

	var world: WorldSave = WorldSave.new()


	#world.difficulty = Simulation.difficulty
	#world.season = Simulation.season
	#world.time = Simulation.time
	#world.day = Simulation.day
	#world.weather = Simulation.weather
	#world.weatherTime = Simulation.weatherTime


	ResourceSaver.save(world, "user://World.tres")
	print("SAVE: World")

func LoadWorld():

	await get_tree().create_timer(0.1).timeout;


	if !FileAccess.file_exists("user://World.tres"):
		return


	var world: WorldSave = load("user://World.tres") as WorldSave


	#Simulation.difficulty = world.difficulty
	#Simulation.season = world.season
	#Simulation.time = world.time
	#Simulation.day = world.day
	#Simulation.weather = world.weather
	#Simulation.weatherTime = world.weatherTime

	print("LOAD: World")



func SaveShelter(targetShelter):

	var shelter: ShelterSave = ShelterSave.new()


	shelter.initialSpawn = false




	var furnitures = get_tree().get_nodes_in_group("Furniture")


	for furniture in furnitures:

		var furnitureComponent: Furniture


		for child in furniture.owner.get_children():
			if child is Furniture:
				furnitureComponent = child


		if furnitureComponent:

			var furnitureSave = FurnitureSave.new()
			furnitureSave.name = furnitureComponent.itemData.name
			furnitureSave.itemData = furnitureComponent.itemData
			furnitureSave.position = furniture.owner.global_position
			furnitureSave.rotation = furniture.owner.global_rotation
			furnitureSave.scale = furniture.owner.scale


			if furniture.owner is LootContainer:

				if furniture.owner.storage.size() != 0:
					furnitureSave.storage = furniture.owner.storage


			shelter.furnitures.append(furnitureSave)




	var items = get_tree().get_nodes_in_group("Item")


	for item in items:

		var itemSave = ItemSave.new()
		itemSave.name = item.slotData.itemData.name
		itemSave.slotData = item.slotData
		itemSave.position = item.global_position
		itemSave.rotation = item.global_rotation

		shelter.items.append(itemSave)




	var switches = get_tree().get_nodes_in_group("Switch")


	for switch in switches:

		var switchSave = SwitchSave.new()
		switchSave.name = switch.name
		switchSave.active = switch.active

		shelter.switches.append(switchSave)




	ResourceSaver.save(shelter, "user://" + targetShelter + ".tres")
	print("SAVE: " + targetShelter)

func LoadShelter(targetShelter):

	await get_tree().create_timer(0.1).timeout;


	if !FileAccess.file_exists("user://" + targetShelter + ".tres"):
		return


	var shelter: ShelterSave = load("user://" + targetShelter + ".tres") as ShelterSave
	print("LOAD: " + targetShelter)



	if !shelter.initialSpawn:
		var furnitures = get_tree().get_nodes_in_group("Furniture")
		for furniture in furnitures:
			furniture.owner.global_position.y = -100.0
			furniture.queue_free()




	for furnitureSave in shelter.furnitures:

		var file = Database.get(furnitureSave.itemData.file)
		if !file:
			print("File missing: " + furnitureSave.itemData.file)
			return


		var furniture = Database.get(furnitureSave.itemData.file).instantiate()
		var map = get_tree().current_scene.get_node("/root/Map")
		map.add_child(furniture)


		furniture.name = furnitureSave.name
		furniture.global_position = furnitureSave.position
		furniture.global_rotation = furnitureSave.rotation
		furniture.scale = furnitureSave.scale


		if furniture is LootContainer:

			if furnitureSave.storage.size() != 0:
				furniture.storage = furnitureSave.storage
				furniture.storaged = true




	var itemReturn = false
	var itemsReturned = 0


	for item in shelter.items:


		var file = Database.get(item.slotData.itemData.file)
		if !file:
			print("File missing: " + item.slotData.itemData.file)
			return


		var pickup = Database.get(item.slotData.itemData.file).instantiate()
		var map = get_tree().current_scene.get_node("/root/Map")
		map.add_child(pickup)


		pickup.slotData.Update(item.slotData)
		pickup.name = item.name
		pickup.global_position = item.position
		pickup.global_rotation = item.rotation
		pickup.Freeze()
		pickup.UpdateAttachments()


		if pickup.global_position.y < -10.0:
			pickup.global_position = Vector3(-0.5, 1.5, -2.0)
			itemsReturned += 1
			itemReturn = true


	if itemsReturned:

		await get_tree().create_timer(1.0).timeout;


		var newMessage = message.instantiate()
		get_tree().get_root().add_child(newMessage)
		newMessage.Text("Item Return: " + str(itemsReturned) + " fallen items returned")




	var switches = get_tree().get_nodes_in_group("Switch")


	if shelter.initialSpawn:
		for switch in switches:
			switch.Activate()

	else:
		for switch in switches:
			for switchSave in shelter.switches:

				if switchSave.name == switch.name:

					if switchSave.active:
						switch.Activate()
					else:
						switch.Deactivate()



func SaveTrader(trader: String):

	if gameData.tutorial:
		return


	var traderSave: TraderSave = TraderSave.new()


	var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")


	for taskString in interface.trader.tasksCompleted:
		traderSave.tasksCompleted.append(taskString)


	if trader == "Generalist":
		ResourceSaver.save(traderSave, "user://Generalist.tres")
		print("SAVE: Generalist")


	elif trader == "Doctor":
		ResourceSaver.save(traderSave, "user://Doctor.tres")
		print("SAVE: Doctor")

func LoadTrader(trader: String):

	await get_tree().create_timer(0.1).timeout;


	if gameData.tutorial:
		return


	var traderSave: TraderSave


	if trader == "Generalist":
		if !FileAccess.file_exists("user://Generalist.tres"):
			return
		else:
			traderSave = load("user://Generalist.tres") as TraderSave
			print("LOAD: Generalist")


	var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")


	interface.trader.tasksCompleted.clear()


	for taskString in traderSave.tasksCompleted:
		interface.trader.tasksCompleted.append(taskString)


	interface.UpdateTraderInfo()



func UpdateProgression():

	if gameData.tutorial:
		return


	var interface = get_tree().current_scene.get_node("/root/Map/Core/UI/Interface")

	#interface.day.text = str("%02d" % Simulation.day)

	if FileAccess.file_exists("user://Generalist.tres"):
		var traderSave = load("user://Generalist.tres") as TraderSave
		interface.tasks.text = str("%02d" % traderSave.tasksCompleted.size())



func _physics_process(delta):
	if masterActive:
		masterValue = move_toward(masterValue, 1.0, delta / 2.0)
	else:
		masterValue = move_toward(masterValue, 0.0, delta / 2.0)
	
	if not masterAmplify:
		return
	masterAmplify.volume_db = linear_to_db(masterValue)



func FadeIn():
	HideCursor()
	PlayTransition()
	animation.play("Fade_In")
	masterActive = false

func FadeOut():
	ShowCursor()
	animation.play("Fade_Out")
	await get_tree().create_timer(1).timeout;
	masterActive = true

func FadeInLoading():
	HideCursor()
	PlayTransition()
	animation.play("Fade_In_Loading")
	masterActive = false

func FadeOutLoading():
	ShowCursor()
	animation.play("Fade_Out_Loading")
	await get_tree().create_timer(1).timeout;
	masterActive = true

func ShowLoadingScreen():
	screen.show()

func HideLoadingScreen():
	screen.hide()

func ShowOverlay():
	overlay.show()

func HideOverlay():
	overlay.hide()



func PlayTransition():
	var transition = audioInstance2D.instantiate()
	add_child(transition)
	transition.PlayInstance(audioLibrary.transition)

func HideCursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

func ShowCursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func Quit():
	FadeIn()
	HideCursor()
	await get_tree().create_timer(2.0).timeout;
	get_tree().quit()
