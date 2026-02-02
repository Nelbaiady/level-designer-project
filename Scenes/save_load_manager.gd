extends Node2D
@onready var file_dialog: FileDialog = $"../FileDialog"
#@onready var tileMap: TileMapLayer = $"../Level/Layer0/TileMapLayer"

var isSaving = false

func _input(event: InputEvent) -> void:
	if globalEditor.isEditing:
		if event.is_action_pressed("save"):
			globalEditor.saveLoadPopupIsOpen = true
			isSaving = true
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE 
			file_dialog.show()
			
		if event.is_action_pressed("load"):
			globalEditor.saveLoadPopupIsOpen = true
			isSaving = false
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			file_dialog.show()
			
func _on_file_dialog_confirmed() -> void:
	globalEditor.saveLoadPopupIsOpen = false
	if isSaving:
		saveLevel(file_dialog.current_path)
	else:
		loadLevel(file_dialog.current_path)


func _on_file_dialog_canceled() -> void:
	globalEditor.saveLoadPopupIsOpen = false

func saveLevel(path):
	#REFERENCE: https://godotforums.org/d/35977-how-do-i-save-a-tileset-in-a-building-game/2
	var saveFile = FileAccess.open(path+".json", FileAccess.WRITE)
	if(FileAccess.get_open_error() != OK):
		return false
	#var rooms = [{"backgroundColor":Color.FLORAL_WHITE,"layers":{0:{"tiles":{},"objects":{}} ,1:{"tiles":{},"objects":{}}}  }]
	#var levelSaveStruct : Dictionary = {"rooms": [{"layers":{0:{"tiles": [], "objects": []}}}], "playerProperties":{}}
	var levelSaveStruct : Dictionary = {"rooms": [ ],"playerProperties":{}}
	for roomIndex in range(len(globalEditor.level.rooms)):
		levelSaveStruct["rooms"].append( {"layers":{}} )#{"tiles": [], "objects": []} )
		for layerIndex in globalEditor.level.rooms[roomIndex]["layers"]:
			#print("saving layer ",layerIndex)
			levelSaveStruct["rooms"][roomIndex]["layers"][layerIndex]={"tiles": [], "objects": []}
			var layer = globalEditor.level.rooms[roomIndex]["layers"][layerIndex]
			var tileMap = globalEditor.level.layers[layerIndex].tileMap
			#ADD EVERYTHING TO THE LEVEL STRUCT
			for cellPos in tileMap.get_used_cells():
				##var cellPos = Vector2i(x, y)
				var pos = [cellPos.x,cellPos.y]
				var coords = [tileMap.get_cell_atlas_coords(cellPos).x,tileMap.get_cell_atlas_coords(cellPos).y]
				var source : int = tileMap.get_cell_source_id(cellPos)
				var altTile : int = tileMap.get_cell_alternative_tile(cellPos)
				if source!=-1:
					levelSaveStruct["rooms"][roomIndex]["layers"][layerIndex].tiles.append( { "pos": pos, "atlasCoords": coords, "sourceID": source, "altTile": altTile } )
			for i in layer["objects"]:
				var currentSavingObject = layer["objects"][i]#globalEditor.objectsHash[i]
				levelSaveStruct["rooms"][roomIndex]["layers"][layerIndex]["objects"].append({"instanceID":i,"rosterID":currentSavingObject.rosterID,"properties":var_to_str(currentSavingObject.properties) })
			levelSaveStruct["rooms"][roomIndex]["layers"][layerIndex]["layerProperties"]=var_to_str(globalEditor.level.rooms[roomIndex]["layers"][layerIndex]["layerProperties"])
	levelSaveStruct.playerProperties = var_to_str(globalEditor.playerProperties)

	saveFile.store_string(JSON.stringify(levelSaveStruct))
	
func loadLevel(path):
	var levelFile = FileAccess.open(path, FileAccess.READ)
	#signalBus.reloadPlayer.emit()
	if(FileAccess.get_open_error() != OK):
		printerr("failed to open file: ",path)
		return false
	var jsonData = levelFile.get_as_text()
	var parsedData = JSON.new()
	parsedData.parse(jsonData)
	var loadedData : Dictionary = parsedData.get_data()
	globalEditor.clearLevel()
	#var rooms = [{"backgroundColor":Color.FLORAL_WHITE,"layers":{0:{"tiles":{},"objects":{}} ,1:{"tiles":{},"objects":{}}}  }]
#	Loop through each layer within each room
	for roomIndex in range(len(globalEditor.level.rooms)):
		#globalEditor.level.rooms[globalEditor.currentRoom]["layers"]={}
		#first pass for instantiating layer nodes
		for stringLayerIndex in loadedData["rooms"][roomIndex]["layers"].keys():
			var layerIndex = int(stringLayerIndex)
			if layerIndex<0:
				globalEditor.level.addLayerBelow(0)
			if layerIndex>0:
				globalEditor.level.addLayerAbove(0)
			
		#second pass for setting properties and placing items
		for stringLayerIndex in loadedData["rooms"][roomIndex]["layers"].keys():
			var layerIndex = int(stringLayerIndex)
			#layers[i.index] = i #We need to dynamically spawn the nodes and set their indices
			#globalEditor.level.rooms[roomIndex]["layers"][layerIndex]={"objects":{},"layerProperties":{}}
			globalEditor.currentLayer = layerIndex
			var tileMap = globalEditor.level.layers[layerIndex].tileMap
			#place tiles for current room and layer
			for i in len( loadedData["rooms"][roomIndex]["layers"][str(layerIndex)]["tiles"] ):
				var currentTile = loadedData["rooms"][roomIndex]["layers"][str(layerIndex)]["tiles"][i]
				tileMap.set_cell(Vector2i(currentTile.pos[0],currentTile.pos[1]) , currentTile.sourceID,Vector2i(currentTile.atlasCoords[0],currentTile.atlasCoords[1]) , currentTile.altTile)
			#place objects for current room and layer
			for i in len( loadedData["rooms"][roomIndex]["layers"][str(layerIndex)]["objects"] ):
				var currentLoadingObject = loadedData["rooms"][roomIndex]["layers"][str(layerIndex)]["objects"][i]
				#globalEditor.loadPlaceObject(currentLoadingObject)
				globalEditor.placeObject(globalEditor.itemRoster[currentLoadingObject.rosterID],Vector2.ZERO,str_to_var(currentLoadingObject.properties),int(currentLoadingObject.instanceID))
			#set the layer's properties
			var currentLoadingLayerProperties = str_to_var(loadedData["rooms"][roomIndex]["layers"][str(layerIndex)]["layerProperties"])
			for prop in currentLoadingLayerProperties:
				globalEditor.level.setProperty(prop,currentLoadingLayerProperties[prop],layerIndex)
			
	globalEditor.currentLayer = 0
	globalEditor.playerProperties = str_to_var( loadedData.playerProperties )
	signalBus.loadedLevel.emit()
	signalBus.reloadPlayer.emit()
