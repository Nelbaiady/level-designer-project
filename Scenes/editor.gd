extends Node2D

@onready var level: Node2D = $"../Level"
@onready var tileMap: TileMapLayer = $"../Level/TileMapLayer"
@onready var cursor: Node2D =$"../CursorCanvas/Cursor"
#@onready var cursor: Node2D =$"../Cursor"
@onready var cursorItemIcon: TextureRect = $"../cursorItemIcon"


#default hotbar: grass, spring
var selectedItem:Item
var selectedItemType = "terrain"
var cursorCellCoords: Vector2i = Vector2i.ZERO
var previousCursorCellCoords: Vector2i = cursorCellCoords
var previousCursorPos:Vector2 = Vector2.ZERO
var previousPlacePos:Vector2 = Vector2.ZERO
var placeButtonIsHeld:bool = false
var clickFrame:bool = false

var cursorItemIconTween: Tween

func _ready() -> void:
	selectedItem = globalEditor.hotbar[globalEditor.hotbarIndex]
	setSelectedItem(selectedItem)
	globalEditor.setItem.connect(setSelectedItem)
	globalEditor.resetStage.connect(resetStage)
	globalEditor.propertiesUI = $"../CanvasLayer/PropertiesSidebar/PropertiesPanel/Properties"
	
func _process(_delta: float) -> void:
	if clickFrame:
		clickFrame = false
	if !globalEditor.popupIsOpen:
		if globalEditor.isEditing:
			previousCursorCellCoords = cursorCellCoords
			cursorCellCoords = tileMap.local_to_map(Vector2i(cursor.global_position))

			if cursorCellCoords!=previousCursorCellCoords and selectedItem is terrainItem:
				tweenCursorItemIcon()
			elif selectedItem is objectItem:
				cursorItemIcon.position = cursor.global_position + selectedItem.textureOffset
			
			#place an object
			if Input.is_action_just_released("mouseClickLeft"):
				placeButtonIsHeld = false
			if placeButtonIsHeld and cursor.cursorOnScreen: #TIGHT COUPLING HERE MIGHT NOT BE IDEAL
				match globalEditor.currentTool:
					globalEditor.Tools.place:
						placeItem()
					globalEditor.Tools.move:
						pass #UNTIL MOVE TOOL IS IMPLEMENTED
					globalEditor.Tools.erase:
						eraseItem()

			#if Input.is_action_just_pressed("mouseClickLeft") or (Input.is_action_pressed("mouseClickLeft") and cursorCellCoords!=previousCursorCellCoords):
				#placeItem()
			##erase object at mouse
			#if Input.is_action_just_pressed("erase") or (Input.is_action_pressed("erase") and cursorCellCoords!=previousCursorCellCoords):
				#if selectedItem is terrainItem:
					##var erasedTilePosition: Vector2i = tileMap.local_to_map(get_global_mouse_position())
					##tileMap.erase_cell(erasedTilePosition) #if we wanted to erase a non-terrain tile
					#tileMap.set_cells_terrain_connect([cursorCellCoords],0,-1,false)
				#if selectedItem is objectItem:
					#if globalEditor.objectPosHash.has(cursorCellCoords):
						##selectedItem.objectReference.queue_free()
						#var objectToDelete = globalEditor.objectPosHash[cursorCellCoords].object
						#globalEditor.objectPosHash.erase(cursorCellCoords)
						#if is_instance_valid(objectToDelete):
							#objectToDelete.queue_free()
					#
			if Input.is_action_just_released("clear"):
				globalEditor.clearLevel()
				#tileMap.clear()
#				#I need to add code for clearing objects too
		else:
			pass
			
		#toggle between edit mode and play mode
		if Input.is_action_just_pressed("toggleEditing"):
			if globalEditor.isEditing:
				globalEditor.isEditing = false
			else:
				globalEditor.resetStage.emit()

			
	#COMMON CODE FOR EDIT AND PLAY MODE
	cursorItemIcon.visible = cursor.visible
	previousCursorPos = cursor.global_position
	#END OF PHYSICS PROCESS

func tweenCursorItemIcon():
	cursorItemIconTween = create_tween()
	cursorItemIconTween.set_trans(Tween.TRANS_CUBIC)
	cursorItemIconTween.set_ease(Tween.EASE_OUT)
	cursorItemIconTween.tween_property(cursorItemIcon,"position",Vector2(cursorCellCoords * globalEditor.gridSize) + selectedItem.textureOffset,0.1)

func setSelectedItem(newItem: Item):
	selectedItem = newItem
	#adjust the type of item for easier retrieval later
	if selectedItem is terrainItem:
		selectedItemType = "terrain"
	if selectedItem is objectItem:
		selectedItemType = "object"
	cursorItemIcon.texture = selectedItem.texture
	cursorItemIcon.size = selectedItem.texture.get_size()
	if cursorItemIconTween!=null and cursorItemIconTween.is_running():
		cursorItemIconTween.kill()
		tweenCursorItemIcon()
	else:
		cursorItemIcon.position = Vector2(cursorCellCoords * globalEditor.gridSize) + selectedItem.textureOffset
		

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("mouseClickLeft") and cursor.cursorOnScreen and globalEditor.isEditing:
		placeButtonIsHeld = true
		clickFrame = true

func placeItem():
	if selectedItem is terrainItem:
		#var placedTilePosition: Vector2i = tileMap.local_to_map(get_global_mouse_position())
		#tileMap.set_cell(cursorCellCoords,0,Vector2i(1,1)) #IF WE WANTED TO PLACE A REGULAR TILE
		globalEditor.placeTile(selectedItem,cursorCellCoords)
	if selectedItem is objectItem:
		#if !globalEditor.objectPosHash.has(cursor.global_position): #if these coordinates dont already have an object
		#if globalEditor.numObjectsHoveredOver.is_empty():
		if clickFrame or (cursor.global_position.x > previousPlacePos.x+globalEditor.gridSize or cursor.global_position.x < previousPlacePos.x-globalEditor.gridSize or cursor.global_position.y > previousPlacePos.y+globalEditor.gridSize or cursor.global_position.y < previousPlacePos.y-globalEditor.gridSize ):
			previousPlacePos = cursor.global_position
			globalEditor.placeObject(selectedItem,cursor.global_position)

func eraseItem():
	if selectedItem is terrainItem:
		#var erasedTilePosition: Vector2i = tileMap.local_to_map(get_global_mouse_position())
		#tileMap.erase_cell(erasedTilePosition) #if we wanted to erase a non-terrain tile
		tileMap.set_cells_terrain_connect([cursorCellCoords],0,-1,false)
	if selectedItem is objectItem:
		signalBus.eraseObject.emit()
		#if globalEditor.objectPosHash.has(cursorCellCoords):
			##selectedItem.objectReference.queue_free()
			#var objectToDelete = globalEditor.objectPosHash[cursorCellCoords].object
			#globalEditor.objectPosHash.erase(cursorCellCoords)
			#if is_instance_valid(objectToDelete):
				#objectToDelete.queue_free()
		

func resetStage():
	globalEditor.isEditing = true
	cursorItemIcon.visible = true
	placeButtonIsHeld = false
