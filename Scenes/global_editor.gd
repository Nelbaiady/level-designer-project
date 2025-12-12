extends Node

var isEditing:bool = true
var popupIsOpen:bool = false
var gridSize:int = 64

@warning_ignore("unused_signal")
signal resetStage()
@warning_ignore("unused_signal")
signal updateProperty(property,value)
@warning_ignore("unused_signal")
signal showPropertiesSidebar()
signal updateHotbar(hotbarIndex, item)
signal updateHotbarSelection(hotbarIndex)
signal setItem(item)

var hotbarIndex: int = 0
var hotbar: Array[Item] = [preload("uid://bs8fbynxqm6wr"), preload("uid://c2d008ix6upm5"),null,null,null,null,null,null,null,null]

@onready var objects
@onready var tileMap: TileMapLayer
@onready var propertiesUI: VBoxContainer
var objectBeingEdited

enum Tools {place, move, erase}
@export var currentTool: Tools

var objectPosHash : Dictionary = {}

func _ready() -> void:
	signalBus.setCurrentTool.connect(setCurrentTool)

#list of every possible object type
#var objectRoster = ["res://Scenes/Items/Objects/Spring/Spring.tres"]
var itemRoster = [preload("uid://bs8fbynxqm6wr"), preload("uid://c2d008ix6upm5"),null,null,null,null,null,null,null,null]

func placeTile(item, cell):
	tileMap.set_cells_terrain_connect([cell],item.terrainSet,item.terrain,false) #place the tile
	#globalEditor.levelSaveStruct.tiles.append( { "pos":[cell.x, cell.y], "sourceID":tileMap.get_cell_source_id(cell), "atlasCoords":[tileMap.get_cell_atlas_coords(cell).x,tileMap.get_cell_atlas_coords(cell).y], "altTile":tileMap.get_cell_alternative_tile(cell)} ) #add the tile to the items struct

func placeObject(object:objectItem, cell:Vector2i):
	var placedObjectPosition: Vector2i = cell * globalEditor.gridSize + (Vector2i.RIGHT*globalEditor.gridSize/2)
	var objectToPlace = object.objectReference.instantiate()
	objectToPlace.global_position = placedObjectPosition
	objects.add_child(objectToPlace)
	globalEditor.objectPosHash[cell] = {"object":objectToPlace,"rosterID":object.rosterID,"properties":{}}

func clearLevel():
	for i in objectPosHash:
		objectPosHash[i].object.queue_free()
	tileMap.clear()
	objectPosHash.clear()

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
	#if event.is_action_pressed("moveTool"):
		#signalBus.setCurrentTool.emit(Tools.move)
	if event.is_action_pressed("placeTool"):
		signalBus.setCurrentTool.emit(Tools.place)

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
