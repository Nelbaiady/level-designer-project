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

var hotbarIndex: int = 0
var hotbar: Array[Item] = [preload("uid://bs8fbynxqm6wr"), preload("uid://c2d008ix6upm5"),null,null,null,null,null,null,null,null]

@onready var objects
@onready var tileMap: TileMapLayer
@onready var propertiesUI: VBoxContainer
var objectBeingEdited
var isObjectBeingEdited = false

@onready var player: CharacterBody2D
const PLAYER = preload("uid://ce1i72nmpos1n")


enum Tools {place, erase, move}
@export var currentTool: Tools

var objectsHash : Dictionary = {}
var playerProperties : Dictionary = {"position":Vector2(544,280)}

func _ready() -> void:
	signalBus.setCurrentTool.connect(setCurrentTool)
	signalBus.reloadPlayer.connect(reloadPlayer)
	signalBus.showPropertiesSidebar.connect(propertiesEditorIsShown)
	signalBus.hidePropertiesSidebar.connect(propertiesEditorIsHidden)

func _physics_process(_delta: float) -> void:
	popupIsOpen = saveLoadPopupIsOpen or colorPickerPopupIsOpen

#list of every possible object type
#var objectRoster = ["res://Scenes/Items/Objects/Spring/Spring.tres"]
var itemRoster = [preload("uid://bs8fbynxqm6wr"), preload("uid://c2d008ix6upm5"),null,null,null,null,null,null,null,null]

func placeTile(item, cell):
	#tileMap.set_cell(cursorCellCoords,0,Vector2i(1,1)) #IF WE WANTED TO PLACE A REGULAR TILE
	tileMap.set_cells_terrain_connect([cell],item.terrainSet,item.terrain,false) #place the tile

func placeObject(object:objectItem, position:Vector2):
	var objectToPlace = object.objectReference.instantiate()
	objectToPlace.global_position = position
	objects.add_child(objectToPlace)
	var instanceID = objectInstancesCount
	globalEditor.objectsHash[instanceID] = {"object":objectToPlace, "rosterID":object.rosterID,"properties":{"position":position}}
	signalBus.placeObjectSignal.emit(instanceID, objectToPlace, {})
	objectInstancesCount+=1
# placing an object when loading the level
func loadPlaceObject(loadingObject):
	var objectToPlace = itemRoster[loadingObject.rosterID].objectReference.instantiate()
	objects.add_child(objectToPlace)
	var instanceID = int(loadingObject.instanceID)
	globalEditor.objectsHash[instanceID] = {"object":objectToPlace, "rosterID":int(loadingObject.rosterID),"properties": str_to_var(loadingObject.properties) }
	signalBus.placeObjectSignal.emit(instanceID, objectToPlace, str_to_var(loadingObject.properties) )
	

func clearLevel():
	for i in objectsHash:
		if objectsHash[i].object == null:
			printerr("found a null object. ObjectHash: ",objectsHash, "\n")
		else:
			objectsHash[i].object.queue_free()
	tileMap.clear()
	objectsHash.clear()

func reloadPlayer():
	var prevPlayerParent = player.get_parent()
	player.queue_free()
	var newPlayer = PLAYER.instantiate()
	prevPlayerParent.add_child(newPlayer)

func _input(event: InputEvent) -> void:
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
