extends Node

var isEditing:bool = true
var popupIsOpen:bool = false
var colorPickerPopupIsOpen = false
var saveLoadPopupIsOpen = false

var gridSize:int = 64

signal updateHotbar(hotbarIndex, item)
signal updateHotbarSelection(hotbarIndex)
signal setItem(item)
var objectInstancesCount:int = 0

@onready var level: Level
var hotbarIndex: int = 0
var hotbar: Array[Item] = [preload("uid://bs8fbynxqm6wr"), preload("uid://c2d008ix6upm5"),null,null,null,null,null,null,null,null]
var currentLayer: int = 0
var currentRoom: int = 0

#var level : Dictionary = {"rooms":[{"background":Color.FLORAL_WHITE,"layers":{0:{"tiles":{},"objects":{}}}}]}
#var objectsHash : Dictionary = {}
#var tilemaps : Dictionary = {}
var playerProperties : Dictionary = {"position":Vector2(544,280)}

#@onready var objects
#@onready var tileMap: TileMapLayer
#@onready var tileMaps: Dictionary[int, TileMapLayer]
@onready var propertiesUI: VBoxContainer
@onready var propertiesSidebar: PropertiesSidebar
var objectBeingEdited
var isObjectBeingEdited = false

@onready var player: CharacterBody2D
const PLAYER = preload("uid://ce1i72nmpos1n")


enum Tools {place, erase, move}
@export var currentTool: Tools


func _ready() -> void:
	signalBus.setCurrentTool.connect(setCurrentTool)
	signalBus.loadedLevel.connect(reloadPlayer)
	signalBus.showPropertiesSidebar.connect(propertiesEditorIsShown)
	signalBus.hidePropertiesSidebar.connect(propertiesEditorIsHidden)
	signalBus.onLevelReady.connect(levelNodeReady)
	#signalBus.onLevelReady.emit()
func levelNodeReady(levelNode):
	level = levelNode

func _physics_process(_delta: float) -> void:
	popupIsOpen = saveLoadPopupIsOpen or colorPickerPopupIsOpen

#list of every possible object type
#var objectRoster = ["res://Scenes/Items/Objects/Spring/Spring.tres"]
var itemRoster = [preload("uid://bs8fbynxqm6wr"), preload("uid://c2d008ix6upm5"),null,null,null,null,null,null,null,null]

func placeTile(item, cell):
	#tileMap.set_cell(cursorCellCoords,0,Vector2i(1,1)) #IF WE WANTED TO PLACE A REGULAR TILE
	#tileMap.set_cells_terrain_connect([cell],item.terrainSet,item.terrain,false) #place the tile
	level.layers[currentLayer].tileMap.set_cells_terrain_connect([cell],item.terrainSet,item.terrain,false) #place the tile
func placeObject(object:objectItem, position:Vector2=Vector2.ZERO,startProperties={}, instanceID = null):
	var objectToPlace = object.objectReference.instantiate()
	objectToPlace.global_position = position
	level.layers[currentLayer].objects.add_child(objectToPlace)
	if instanceID == null:
		instanceID = objectInstancesCount
		objectInstancesCount+=1
	globalEditor.getCurrentLevelLayerDict()["objects"][instanceID] = {"object":objectToPlace, "rosterID":object.rosterID,"properties":{"position":position}}
	signalBus.placeObjectSignal.emit(instanceID, objectToPlace, startProperties)

func clearLevel():
	for layerIndex in level["rooms"][currentRoom]["layers"]:
		var layer = level["rooms"][currentRoom]["layers"][layerIndex]
		for objectIndex in layer["objects"]:
			var object = level.rooms[currentRoom]["layers"][layerIndex]["objects"][objectIndex].object
			if object == null:
				printerr("found a null object. Objects: ",layer["objects"], "\n")
			else:
				object.queue_free()
	for layer in level.layers.values():
		layer.tileMap.clear()
	level.rooms = [{"backgroundColor":Color.FLORAL_WHITE,"layers":{}  }]
	level.collectChildren()
	objectInstancesCount=0
	signalBus.loadedLevel.emit()

func reloadPlayer():
	var prevPlayerParent = player.get_parent()
	player.queue_free()
	var newPlayer = PLAYER.instantiate()
	prevPlayerParent.add_child(newPlayer)
	player.position = Vector2(544.0,280.0)

func _input(event: InputEvent) -> void:
	if isEditing:
		#selecting items in the hotbar using the number keys
		for i in range(10):
			if event.is_action_pressed(str(i)):
				setHotbarIndex(10 if i==0 else i-1)
				
		if event.is_action_pressed("nextItem"):
			setHotbarIndex(posmod(hotbarIndex-1, len(hotbar)))
		if event.is_action_pressed("previousItem"):
			setHotbarIndex(posmod(hotbarIndex+1, len(hotbar)))
		if event.is_action_pressed("eraseTool"):
			signalBus.setCurrentTool.emit(Tools.erase)
		if event.is_action_pressed("placeTool"):
			signalBus.setCurrentTool.emit(Tools.place)
		if event.is_action_pressed("nextTool"):
			signalBus.setCurrentTool.emit(posmod((currentTool+1),len(Tools)))
		if event.is_action_pressed("previousTool"):
			signalBus.setCurrentTool.emit(posmod((currentTool-1),len(Tools)))

func setHotbarIndex(newIndex):
	if newIndex < len(hotbar) and hotbar[newIndex]:
		hotbarIndex = newIndex
		setItem.emit(hotbar[hotbarIndex]) #Connected in editor.gd
		updateHotbarSelection.emit(hotbarIndex) #Connected in hotbarButton.gd

func updateHotbarUI():
	for i in range(len(hotbar)):
		updateHotbar.emit(i, hotbar[i])

func setCurrentTool(tool):
	currentTool = tool

func propertiesEditorIsShown():
	isObjectBeingEdited = true
func propertiesEditorIsHidden():
	isObjectBeingEdited = false

func getCurrentLevelRoomDict():
	return level.getCurrentRoomDict()
func getCurrentLevelLayerDict():
	return level.getCurrentLayerDict()
