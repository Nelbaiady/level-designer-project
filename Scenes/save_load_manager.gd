extends Node2D
@onready var file_dialog: FileDialog = $"../FileDialog"

var isSaving = false
@onready var tileMap: TileMapLayer = $"../Level/TileMapLayer"

func _input(event: InputEvent) -> void:
	if globalEditor.isEditing:
		if event.is_action_pressed("save"):
			globalEditor.popupIsOpen = true
			isSaving = true
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE 
			file_dialog.show()
			
		if event.is_action_pressed("load"):
			globalEditor.popupIsOpen = true
			isSaving = false
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			file_dialog.show()
			
func _on_file_dialog_confirmed() -> void:
	globalEditor.popupIsOpen = false
	if isSaving:
		saveLevel(file_dialog.current_path)
	else:
		loadLevel(file_dialog.current_path)


func _on_file_dialog_canceled() -> void:
	globalEditor.popupIsOpen = false

func saveLevel(path):
	#REFERENCE: https://godotforums.org/d/35977-how-do-i-save-a-tileset-in-a-building-game/2
	#var tileData : Dictionary = { "tiles": [] }
	#for vectorPos in tileMap.get_used_cells():
		##var vectorPos = Vector2i(x, y)
		#var pos = [vectorPos.x,vectorPos.y]
		#var coords = [tileMap.get_cell_atlas_coords(vectorPos).x,tileMap.get_cell_atlas_coords(vectorPos).y]
		#var source : int = tileMap.get_cell_source_id(vectorPos)
		#var altTile : int = tileMap.get_cell_alternative_tile(vectorPos)
		#if source!=-1:
			#tileData.tiles.append( { "pos": pos, "coords": coords, "source": source, "alt_tile": altTile } )
	var saveFile = FileAccess.open(path+".json", FileAccess.WRITE)
	if(FileAccess.get_open_error() != OK):
		return false
	#saveFile.store_string(JSON.stringify(tileData))
	#print("now saving "+str(globalEditor.levelStruct))
	saveFile.store_string(JSON.stringify(globalEditor.levelStruct))

func loadLevel(path):
	var levelFile = FileAccess.open(path, FileAccess.READ)
	if(FileAccess.get_open_error() != OK):
		return false
	var jsonData = levelFile.get_as_text()
	var parsedData = JSON.new()
	parsedData.parse(jsonData)
	var loadedData : Dictionary = parsedData.get_data()
	print("now loading "+str(loadedData))
	tileMap.clear()
	for i in len( loadedData.tiles):
		tileMap.set_cell(Vector2i(loadedData.tiles[i].pos[0],loadedData.tiles[i].pos[1]) , loadedData.tiles[i].sourceID,Vector2i(loadedData.tiles[i].atlasCoords[0],loadedData.tiles[i].atlasCoords[1]) , loadedData.tiles[i].altTile)
