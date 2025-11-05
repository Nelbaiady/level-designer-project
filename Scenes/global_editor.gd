extends Node

var isEditing:bool = true
var popupIsOpen:bool = false
signal resetStage()
var gridSize:int = 64

@onready var objects
@onready var tileMap: TileMapLayer

var objectPosHash : Dictionary = {}

func _ready() -> void:
	tileMap = $"../Level/TileMapLayer"

#list of every possible object type
#var objectRoster = ["res://Scenes/Items/Objects/Spring/Spring.tres"]
var itemRoster = [preload("uid://bs8fbynxqm6wr"), preload("uid://c2d008ix6upm5"),null,null,null,null,null,null,null,null]

func placeTile(item, cell):
	tileMap.set_cells_terrain_connect([cell],item.terrainSet,item.terrain,false) #place the tile
	#globalEditor.levelSaveStruct.tiles.append( { "pos":[cell.x, cell.y], "sourceID":tileMap.get_cell_source_id(cell), "atlasCoords":[tileMap.get_cell_atlas_coords(cell).x,tileMap.get_cell_atlas_coords(cell).y], "altTile":tileMap.get_cell_alternative_tile(cell)} ) #add the tile to the items struct

func placeObject(item:Item, cell:Vector2i):
	var placedObjectPosition: Vector2i = cell * globalEditor.gridSize + (Vector2i.RIGHT*globalEditor.gridSize/2)
	var objectToPlace = item.objectReference.instantiate()
	objectToPlace.global_position = placedObjectPosition
	objects.add_child(objectToPlace)
	
	globalEditor.objectPosHash[cell] = {"object":objectToPlace,"rosterID":item.rosterID}
	#globalEditor.levelSaveStruct.objects.append({"pos":[cell.x, cell.y], "rosterID":item.rosterID})
	#if globalEditor.objectPosHash.has(Vector2i(10,5)):
		#print(globalEditor.objectPosHash[Vector2i(10,5)].position)

func clearLevel():
	for i in objectPosHash:
		objectPosHash[i].object.queue_free()
	tileMap.clear()
	objectPosHash.clear()
