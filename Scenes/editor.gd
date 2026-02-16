extends Node2D

#@onready var level: Node2D = $"../Level"
#@onready var tileMap: TileMapLayer = $"../Level/Layer0/TileMapLayer"
#@onready var tileMaps: Dictionary[int, TileMapLayer] = {0:$"../Level/Layer0/TileMapLayer"}
@onready var cursor: Node2D = $"../CursorCanvas/Cursor"
#@onready var cursor: Node2D =$"../Cursor"
@onready var cursorItemIcon: TextureRect = $"../cursorItemIcon"

@onready var camera: GameplayCamera = $"../Camera2D"

#default hotbar: grass, spring
var selectedItem:Item
var selectedItemType = "terrain"
var cursorCellCoords: Vector2i = Vector2i.ZERO
var cursorParallaxPosition: Vector2 = Vector2.ZERO
var cameraParallaxDifference: Vector2 = Vector2.ZERO
var previousCursorCellCoords: Vector2i = cursorCellCoords
var previousCursorPos:Vector2 = Vector2.ZERO
var previousPlacePos:Vector2 = Vector2.INF
var placeButtonIsHeld:bool = false
var clickFrame:bool = false

var cursorItemIconTween: Tween

func _ready() -> void:
	selectedItem = globalEditor.hotbar[globalEditor.hotbarIndex]
	setSelectedItem(selectedItem)
	globalEditor.setItem.connect(setSelectedItem)
	signalBus.startEditMode.connect(resetStage)
	globalEditor.propertiesUI = $"../CanvasLayer/PropertiesSidebar/PropertiesPanel/ScrollContainer/Properties"
	#globalEditor.tileMaps = tileMaps
	#globalEditor.level = $"../Level"
	signalBus.onLevelReady.connect(levelReady)

func levelReady(_level):
	updateCameraParallaxDifference()
	
## this gets the offset (difference) between the camera starting position (from the top left) and the parallax layer, which is usually the origin point
func updateCameraParallaxDifference():
	cameraParallaxDifference = get_viewport_rect().size/2 #- getCurrentLayerNode().screen_offset #this ended up being redundant
func _process(_delta: float) -> void:
	if !globalEditor.popupIsOpen:
		if globalEditor.isEditing:
			previousCursorCellCoords = cursorCellCoords
#			Cursor's position shifted with the current parallax layer
			cursorParallaxPosition = cursor.global_position + getCurrentLayerNode().screen_offset * (getCurrentLayerNode().scroll_scale-Vector2.ONE)
			cursorCellCoords = getCurrentLayerTilemap().local_to_map( cursorParallaxPosition )
			#cursorCellCoords = getCurrentLayerTilemap().local_to_map(getCurrentLayerTilemap().to_local(cursor.global_position)) #evil stupid version
			#if the cursor moved to a different tile or the camera's target position is not the same as the current one (it is easing in), adjust the tile preview
			if (cursorCellCoords!=previousCursorCellCoords or (round(camera.phantomCamera.position*100) != round(camera.position*100)) ) and selectedItem is terrainItem:
				tweenCursorItemIcon()
			elif selectedItem is objectItem:
				#cursorItemIcon.position = (cursor.global_position - (Vector2.ONE * globalEditor.gridSize/2) + selectedItem.textureOffset)
				cursorItemIcon.position = (cursor.global_position - (Vector2.ONE * (cursorItemIcon.texture.get_size()/2) if selectedItem.centerPreview else Vector2.ZERO) + selectedItem.textureOffset)
			
			#place an object
			if Input.is_action_just_released("mouseClickLeft"):
				placeButtonIsHeld = false
				previousPlacePos = Vector2.INF
			if placeButtonIsHeld and cursor.cursorOnScreen: #TIGHT COUPLING HERE MIGHT NOT BE IDEAL
				match globalEditor.currentTool:
					globalEditor.Tools.place:
						placeItem()
					globalEditor.Tools.move:
						pass #UNTIL MOVE TOOL IS IMPLEMENTED
					globalEditor.Tools.erase:
						eraseItem()

			if Input.is_action_just_released("clear"):
				globalEditor.clearLevel()
				#tileMap.clear()
#		If Not editing
		else:
			pass
			
		#toggle between edit mode and play mode
		if Input.is_action_just_pressed("toggleEditing"):
			if globalEditor.isEditing:
				globalEditor.isEditing = false
				signalBus.startPlayMode.emit()
			else:
				signalBus.startEditMode.emit()

	if clickFrame:
		clickFrame = false
	#COMMON CODE FOR EDIT AND PLAY MODE
	cursorItemIcon.visible = cursor.visible and globalEditor.isEditing
	previousCursorPos = cursorParallaxPosition
	#END OF PHYSICS PROCESS

func tweenCursorItemIcon():
	updateCameraParallaxDifference()
	cursorItemIconTween = create_tween()
	cursorItemIconTween.set_trans(Tween.TRANS_CUBIC)
	cursorItemIconTween.set_ease(Tween.EASE_OUT)
	cursorItemIconTween.tween_property(cursorItemIcon,"position",Vector2(cursorCellCoords * globalEditor.gridSize) - (camera.position-cameraParallaxDifference) * (getCurrentLayerNode().scroll_scale-Vector2.ONE) + selectedItem.textureOffset,0.1)
	
	
func setSelectedItem(newItem: Item):
	selectedItem = newItem
	#adjust the type of item for easier retrieval later
	if selectedItem is terrainItem:
		selectedItemType = "terrain"
	if selectedItem is objectItem:
		selectedItemType = "object"
	cursorItemIcon.texture = selectedItem.icon if selectedItem.previewTexture==null else selectedItem.previewTexture
	cursorItemIcon.size = cursorItemIcon.texture.get_size()
	if cursorItemIconTween!=null and cursorItemIconTween.is_running():
		cursorItemIconTween.stop()
		cursorItemIconTween.kill()
		tweenCursorItemIcon()
	else:
		if globalEditor.level:
			cursorItemIcon.position = Vector2(cursorCellCoords * (globalEditor.gridSize) ) - getCurrentLayerNode().screen_offset * (getCurrentLayerNode().scroll_scale-Vector2.ONE) + selectedItem.textureOffset
		else:
			cursorItemIcon.position = (Vector2(cursorCellCoords * globalEditor.gridSize) + selectedItem.textureOffset)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("mouseClickLeft") and cursor.cursorOnScreen and globalEditor.isEditing:
		placeButtonIsHeld = true
		clickFrame = true

func placeItem():
	if selectedItem is terrainItem:
		globalEditor.placeTile(selectedItem,cursorCellCoords)
	if selectedItem is objectItem:
		if clickFrame or (previousPlacePos.is_finite() and (cursorParallaxPosition.x > previousPlacePos.x+globalEditor.gridSize or cursorParallaxPosition.x < previousPlacePos.x-globalEditor.gridSize or cursorParallaxPosition.y > previousPlacePos.y+globalEditor.gridSize or cursorParallaxPosition.y < previousPlacePos.y-globalEditor.gridSize )):
			previousPlacePos = cursorParallaxPosition
			globalEditor.placeObject(selectedItem,cursorParallaxPosition)
			#print(getCurrentLayerNode().screen_offset * getCurrentLayerNode().scroll_scale)

func eraseItem():
	if selectedItem is terrainItem:
		#var erasedTilePosition: Vector2i = tileMap.local_to_map(get_global_mouse_position())
		#tileMap.erase_cell(erasedTilePosition) #if we wanted to erase a non-terrain tile
		getCurrentLayerTilemap().set_cells_terrain_connect([cursorCellCoords],0,-1,false)
	if selectedItem is objectItem:
		signalBus.eraseObject.emit()
		

##sets the mode to edit mode
func resetStage():
	globalEditor.isEditing = true
	cursorItemIcon.visible = true
	placeButtonIsHeld = false

func getCurrentLayerNode():
	return globalEditor.level.layers[globalEditor.currentLayer]
func getCurrentLayerTilemap():
	return globalEditor.level.layers[globalEditor.currentLayer].tileMap
