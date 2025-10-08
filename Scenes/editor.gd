extends Node2D

@onready var level: Node2D = $"../Level"
@onready var tileMap: TileMapLayer = $"../Level/TileMapLayer"
@onready var file_dialog: FileDialog = $"../FileDialog"
var popupIsOpen = false
var isSaving = false

func _ready() -> void:
	tileMap.owner = level

func _physics_process(delta: float) -> void:
	if !popupIsOpen:
		if globalEditor.isEditing:
			#place an object
			if Input.is_action_pressed("mouseClickLeft"):
				var placedTilePosition: Vector2i = tileMap.local_to_map(get_global_mouse_position())
				#tileMap.set_cell(placedTilePosition,0,Vector2i(1,1)) #IF WE WANTED TO PLACE A REGULAR TILE
				tileMap.set_cells_terrain_connect([placedTilePosition],0,0,false)
			if Input.is_action_pressed("erase"):
				var erasedTilePosition: Vector2i = tileMap.local_to_map(get_global_mouse_position())
				#tileMap.erase_cell(erasedTilePosition) #IF WE WANTED TO ERASE A REGULAR TILE
				tileMap.set_cells_terrain_connect([erasedTilePosition],0,-1,false)
				
			if Input.is_action_just_pressed("clear"):
				tileMap.clear()
		else:
			pass
		#toggle between edit mode and play mode
		if Input.is_action_just_pressed("toggleEditing"):
			if globalEditor.isEditing:
				globalEditor.isEditing = false
			else:
				globalEditor.resetStage.emit()
				globalEditor.isEditing = true
				
	if globalEditor.isEditing:
		if Input.is_action_just_pressed("save"):
			popupIsOpen = true
			isSaving = true
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE 
			file_dialog.show()
			
		if Input.is_action_just_pressed("load"):
			popupIsOpen = true
			isSaving = false
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			file_dialog.show()
			

func _on_file_dialog_confirmed() -> void:
	print('confirmed')
	popupIsOpen = false
	if isSaving:
		saveLevel(file_dialog.current_path)
		#var levelToSave : PackedScene = PackedScene.new()
		#levelToSave.pack(level)
		#ResourceSaver.save(levelToSave, file_dialog.current_path +".tscn")
	else:
		loadLevel(file_dialog.current_path)
		#print('loading level')
		#var levelToLoad : PackedScene = PackedScene.new()
		#levelToLoad = ResourceLoader.load(file_dialog.current_path)
		#var loadedLevel = levelToLoad.instantiate()
		#get_parent().remove_child(level)
		#level.queue_free()
		#get_parent().add_child(loadedLevel)
		#level = loadedLevel
		#level.position = Vector2(20,40)


func _on_file_dialog_canceled() -> void:
	popupIsOpen = false

func saveLevel(path):
	#REFERENCE: https://godotforums.org/d/35977-how-do-i-save-a-tileset-in-a-building-game/2
	var tileData : Dictionary = { "tiles": [] }
	var width = 300 #TEMPORARY
	var height = 300 #TEMPORARY
	for x in width:
		for y in height:
			#var pos : Vector2i = Vector2i(x, y)
			#var coords : Vector2i = tileMap.get_cell_atlas_coords(pos)
			#var source : int = tileMap.get_cell_source_id(pos)
			#var altTile : int = tileMap.get_cell_alternative_tile(pos)
			var pos = [x,y]
			var vectorPos = Vector2i(x, y)
			var coords = [tileMap.get_cell_atlas_coords(vectorPos).x,tileMap.get_cell_atlas_coords(vectorPos).y]
			var source : int = tileMap.get_cell_source_id(vectorPos)
			var altTile : int = tileMap.get_cell_alternative_tile(vectorPos)
			if source!=-1:
				tileData.tiles.append( { "pos": pos, "coords": coords, "source": source, "alt_tile": altTile } )
	var saveFile = FileAccess.open(path+".json", FileAccess.WRITE)
	if(FileAccess.get_open_error() != OK):
		return false
	saveFile.store_string(JSON.stringify(tileData))

func loadLevel(path):
	var levelFile = FileAccess.open(path, FileAccess.READ)
	if(FileAccess.get_open_error() != OK):
		return false
	var jsonData = levelFile.get_as_text()
	var parsedData = JSON.new()
	parsedData.parse(jsonData)
	var loadedData : Dictionary = parsedData.get_data()
	tileMap.clear()
	for i in len( loadedData.tiles):
		tileMap.set_cell(Vector2i(loadedData.tiles[i].pos[0],loadedData.tiles[i].pos[1]) , loadedData.tiles[i].source,Vector2i(loadedData.tiles[i].coords[0],loadedData.tiles[i].coords[1]) , loadedData.tiles[i].alt_tile)
