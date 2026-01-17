extends Node2D
@onready var file_dialog: FileDialog = $"../FileDialog"
@onready var tileMap: TileMapLayer = $"../Level/Layer0/TileMapLayer"
@onready var tileMaps: Array[TileMapLayer] = [$"../Level/Layer0/TileMapLayer"]

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
	var levelSaveStruct : Dictionary = { "tiles": [], "objects": [], "playerProperties":{}}
	#levelSaveStruct.objects.clear()
	#levelSaveStruct.tiles.clear()
	#levelSaveStruct.playerProperties.clear()
	#ADD EVERYTHING TO THE LEVEL STRUCT
	for vectorPos in tileMap.get_used_cells():
		##var vectorPos = Vector2i(x, y)
		var pos = [vectorPos.x,vectorPos.y]
		var coords = [tileMap.get_cell_atlas_coords(vectorPos).x,tileMap.get_cell_atlas_coords(vectorPos).y]
		var source : int = tileMap.get_cell_source_id(vectorPos)
		var altTile : int = tileMap.get_cell_alternative_tile(vectorPos)
		if source!=-1:
			levelSaveStruct.tiles.append( { "pos": pos, "atlasCoords": coords, "sourceID": source, "altTile": altTile } )
	for i in globalEditor.objectsHash:
		var currentSavingObject = globalEditor.objectsHash[i]
		levelSaveStruct.objects.append({"instanceID":i,"rosterID":currentSavingObject.rosterID,"properties":var_to_str(currentSavingObject.properties) })
	levelSaveStruct.playerProperties = var_to_str(globalEditor.playerProperties)

	saveFile.store_string(JSON.stringify(levelSaveStruct))
	
func loadLevel(path):
	var levelFile = FileAccess.open(path, FileAccess.READ)
	signalBus.reloadPlayer.emit()
	if(FileAccess.get_open_error() != OK):
		return false
	var jsonData = levelFile.get_as_text()
	var parsedData = JSON.new()
	parsedData.parse(jsonData)
	var loadedData : Dictionary = parsedData.get_data()
	globalEditor.clearLevel()
	for i in len( loadedData.tiles ):
		tileMap.set_cell(Vector2i(loadedData.tiles[i].pos[0],loadedData.tiles[i].pos[1]) , loadedData.tiles[i].sourceID,Vector2i(loadedData.tiles[i].atlasCoords[0],loadedData.tiles[i].atlasCoords[1]) , loadedData.tiles[i].altTile)
	for i in len( loadedData.objects ):
		var currentLoadingObject = loadedData.objects[i]
		#globalEditor.loadPlaceObject(currentLoadingObject)
		globalEditor.placeObject(globalEditor.itemRoster[currentLoadingObject.rosterID],Vector2.ZERO,str_to_var(currentLoadingObject.properties),int(currentLoadingObject.instanceID))
	globalEditor.playerProperties = str_to_var( loadedData.playerProperties )
	signalBus.resetStage.emit()

	
