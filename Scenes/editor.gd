extends Node2D

@onready var level: Node2D = $"../Level"
@onready var tileMap: TileMapLayer = $"../Level/TileMapLayer"
@onready var objects: Node = $"../Level/Objects"
@onready var cursor: Node2D = $Cursor
@onready var cursorItemIcon: TextureRect = $"../cursorItemIcon"


#default hotbar: grass, spring
var hotbar: Array[Item] = [preload("uid://bs8fbynxqm6wr"), preload("uid://c2d008ix6upm5"),null,null,null,null,null,null,null,null]
var hotbarIndex: int = 0
var selectedItem = hotbar[hotbarIndex]
var selectedItemType = "terrain"
var cursorCellCoords: Vector2i = Vector2i.ZERO
var previousCursorCellCoords: Vector2i = cursorCellCoords
var previousCursorPos = Vector2.ZERO

func _ready() -> void:
	tileMap.owner = level
	setSelectedItem(hotbar[hotbarIndex])

func _physics_process(delta: float) -> void:
	if delta: #just to get rid of the annoying warning for now
		pass
	if !globalEditor.popupIsOpen:
		if globalEditor.isEditing:
			previousCursorCellCoords = cursorCellCoords
			cursorCellCoords = tileMap.local_to_map(Vector2i(cursor.position))
			cursorItemIcon.position = Vector2(cursorCellCoords * globalEditor.gridSize) + selectedItem.textureOffset
			
			#place an object
			if Input.is_action_just_pressed("mouseClickLeft") or (Input.is_action_pressed("mouseClickLeft") and cursorCellCoords!=previousCursorCellCoords):
				if selectedItem is terrainItem:
					#var placedTilePosition: Vector2i = tileMap.local_to_map(get_global_mouse_position())
					#tileMap.set_cell(cursorCellCoords,0,Vector2i(1,1)) #IF WE WANTED TO PLACE A REGULAR TILE
					placeTile(selectedItem,cursorCellCoords)
					
				if selectedItem is objectItem:
					var placedObjectPosition: Vector2i = cursorCellCoords * globalEditor.gridSize + (Vector2i.RIGHT*globalEditor.gridSize/2)
					var objectToPlace = selectedItem.objectReference.instantiate()
					objectToPlace.global_position = placedObjectPosition
					objects.add_child(objectToPlace)
			#erase object at mouse
			if Input.is_action_pressed("erase"):
				if selectedItem is terrainItem:
					#var erasedTilePosition: Vector2i = tileMap.local_to_map(get_global_mouse_position())
					#tileMap.erase_cell(erasedTilePosition) #if we wanted to erase a non-terrain tile
					tileMap.set_cells_terrain_connect([cursorCellCoords],0,-1,false)
				if selectedItem is objectItem:
					selectedItem.objectReference #ADD CODE FOR ERASING ITEMS
			if Input.is_action_just_released("clear"):
				tileMap.clear()
#				#I need to add code for clearing objects too
		else:
			pass
		#toggle between edit mode and play mode
		if Input.is_action_just_pressed("toggleEditing"):
			if globalEditor.isEditing:
				globalEditor.isEditing = false
			else:
				globalEditor.resetStage.emit()
				globalEditor.isEditing = true
			
	#FINAL SECTION IN PHYSICS PROCESS
	previousCursorPos = cursor.position
	#END OF PHYSICS PROCESS
func _input(event: InputEvent) -> void:
	#selecting items in the hotbar using the number keys
	for i in range(10):
		if event.is_action_pressed(str(i)):
			hotbarIndex = 10 if i==0 else i-1
			if hotbarIndex < len(hotbar):
				setSelectedItem(hotbar[hotbarIndex])

func setSelectedItem(newItem: Item):
	selectedItem = newItem
	#adjust the type of item for easier retrieval later
	if selectedItem is terrainItem:
		selectedItemType = "terrain"
	if selectedItem is objectItem:
		selectedItemType = "object"
	cursorItemIcon.texture = selectedItem.texture
	cursorItemIcon.size = selectedItem.texture.get_size()
	
	if cursorItemIcon.texture:
		print(cursorItemIcon.texture)
	else:
		print("no tektur :(")
		
func placeTile(item, cell):
		tileMap.set_cells_terrain_connect([cell],item.terrainSet,item.terrain,false)
		#var tileInfo = tileMap.get_cell_tile_data(cell)
		#print(tileInfo)
		print(tileMap.get_cell_source_id(cell))
		print(tileMap.get_cell_atlas_coords(cell))
#		A BUNCHA JIBBERISH. CLEAN UP THIS MESS LATER CUZ IM SLEEPY AND TIRED AND ITS 3AM
		#tileMap.set_cell(cursorCellCoords,0,Vector2i(1,1)) #IF WE WANTED TO PLACE A REGULAR TILE
		#var pos = [vectorPos.x,vectorPos.y]
		#var coords = [tileMap.get_cell_atlas_coords(vectorPos).x,tileMap.get_cell_atlas_coords(vectorPos).y]
		#var source : int = tileMap.get_cell_source_id(vectorPos)
		#var altTile : int = tileMap.get_cell_alternative_tile(vectorPos)
		#if source!=-1:
			#tileData.tiles.append( { "pos": pos, "coords": coords, "source": source, "alt_tile": altTile } )
		globalEditor.levelStruct.tiles.append( { "pos":[cell.x, cell.y], "sourceID":tileMap.get_cell_source_id(cell), "atlasCoords":[tileMap.get_cell_atlas_coords(cell).x,tileMap.get_cell_atlas_coords(cell).y], "altTile":tileMap.get_cell_alternative_tile(cell)} )

func placeObject(item, cell):
	pass #lets do this later
