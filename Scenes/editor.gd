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
			if Input.is_action_just_pressed("mouseClickLeft"):
				var placedTilePosition: Vector2i = tileMap.local_to_map(get_global_mouse_position()*4)
				tileMap.set_cell(placedTilePosition,0,Vector2i(1,1))
				var neighbors = [placedTilePosition,
				placedTilePosition+Vector2i.LEFT,placedTilePosition-Vector2i.LEFT,
				placedTilePosition+Vector2i.UP,placedTilePosition-Vector2i.UP,
				placedTilePosition+Vector2i.UP+Vector2i.LEFT,placedTilePosition+Vector2i.UP-Vector2i.LEFT,
				placedTilePosition-Vector2i.UP+Vector2i.LEFT,placedTilePosition-Vector2i.UP-Vector2i.LEFT]
				var nonEmptyNeighbors = []
				for i in neighbors:
					if tileMap.get_cell_source_id(i) != -1:
						nonEmptyNeighbors.append(i)
				print(neighbors)
				print(nonEmptyNeighbors)
				tileMap.set_cells_terrain_connect(nonEmptyNeighbors,0,0)
			#clear all of the editor's children
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
		var levelToSave : PackedScene = PackedScene.new()
		levelToSave.pack(level)
		ResourceSaver.save(levelToSave, file_dialog.current_path +".tscn")
	else:
		print('loading level')
		var levelToLoad : PackedScene = PackedScene.new()
		levelToLoad = ResourceLoader.load(file_dialog.current_path)
		var loadedLevel = levelToLoad.instantiate()
		get_parent().remove_child(level)
		level.queue_free()
		get_parent().add_child(loadedLevel)
		level = loadedLevel
		level.position = Vector2(20,40)


func _on_file_dialog_canceled() -> void:
	popupIsOpen = false
