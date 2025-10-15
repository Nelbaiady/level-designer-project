extends Node2D

@onready var level: Node2D = $"../Level"
@onready var tileMap: TileMapLayer = $"../Level/TileMapLayer"



func _ready() -> void:
	tileMap.owner = level

func _physics_process(delta: float) -> void:
	if delta: #just to get rid of the annoying warning for now
		pass
	if !globalEditor.popupIsOpen:
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
