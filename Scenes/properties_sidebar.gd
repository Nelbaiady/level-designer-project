class_name PropertiesSidebar extends Control

var hotbarTween:Tween
const LAYER_EDITOR = preload("uid://0c854hhnl8dy")
const HOVER_HINT = preload("uid://bdjv0hwp335af")
@export var propertiesList: VBoxContainer
@export var titleHint: HoverHint

func _physics_process(delta: float) -> void:
	if propertiesList.get_global_rect().has_point(cursorCanvas.cursor.cursorSprite.position) and globalEditor.isObjectBeingEdited:
		cursorCanvas.cursor.setCursorSprite(true)
	elif !system.popupIsOpen:
		cursorCanvas.cursor.setCursorToolSprite(globalEditor.currentTool)

func _ready() -> void:
	#globalEditor.propertiesSidebar = self
	#globalEditor.propertiesUI = $"../HUD/PropertiesSidebar/PropertiesPanel/ScrollContainer/Properties"
	signalBus.populatePropertiesUI.connect(populatePropertiesUI)
	signalBus.populateLayersUI.connect(populateLayersUI)
	signalBus.showPropertiesSidebar.connect(showSidebar)
	signalBus.hidePropertiesSidebar.connect(hideSidebar)

func showSidebar():
	#signalBus.setThingDescription.emit("") #hide the hint hoverHint
	titleHint.setHintText("")
	hotbarTween = create_tween()
	hotbarTween.set_trans(Tween.TRANS_CUBIC)
	hotbarTween.set_ease(Tween.EASE_OUT)
	#hotbarTween.tween_property(self,"anchor_left",0.7,system.uiTweenTime/2)
	hotbarTween.tween_property(self,"position",Vector2(get_viewport_rect().size.x-size.x,position.y) ,system.uiTweenTime/2)

func hideSidebar():
	hotbarTween = create_tween()
	hotbarTween.set_trans(Tween.TRANS_CUBIC)
	hotbarTween.set_ease(Tween.EASE_IN)
	#hotbarTween.tween_property(self,"anchor_left",1,system.uiTweenTime/2)
	hotbarTween.tween_property(self,"position",Vector2(get_viewport_rect().size.x+8,position.y) ,system.uiTweenTime/2)
	globalEditor.colorPickerPopupIsOpen = false #just in case
	await hotbarTween.finished
	emptyPropertiesUI()

func _on_close_button_pressed() -> void:
	signalBus.hidePropertiesSidebar.emit()

func emptyPropertiesUI():
	propertiesList.add_theme_constant_override("separation",4)
	#for i in globalEditor.propertiesUI.get_children():
	for i in propertiesList.get_children():
		i.queue_free()

func populatePropertiesUI(object:ThingWithProperties):
	signalBus.showPropertiesSidebar.emit()
	emptyPropertiesUI()
	setObjectBeingEdited(object)
#	populate the properties editor
	for property in object.properties:
		if property is ObjectProperty:
			var newNode = property.uiNode.instantiate()
			#var newHoverHint:HoverHint = HOVER_HINT.instantiate()
			#newHoverHint.direction = CursorHint.Directions.L
			#newHoverHint.updateText(property.description)
			#var hBox = HBoxContainer.new()
			##globalEditor.propertiesUI.add_child(newNode)
			#
			##propertiesList.add_child(newNode)
			#hBox.add_child(newHoverHint)
			#hBox.add_child(newNode)
			#if newNode is Control: newNode.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			#propertiesList.add_child(hBox)
			addRowWithHint(newNode,property.description)
			
			if newNode is PropertyEditor:
				newNode.setStartValues(object.getProperty(property.codeName),property)
	if !signalBus.updateProperty.is_connected(object.setProperty):
		signalBus.updateProperty.connect(object.setProperty)
	#signalBus.setThingDescription.emit(object.description)
	titleHint.setHintText(object.description)

func addRowWithHint(newNode,hint):
	var hBox = HBoxContainer.new()
	hBox.add_theme_constant_override("separation",0)
	if hint:
		var newHoverHint:HoverHint = HOVER_HINT.instantiate()
		newHoverHint.direction = CursorHint.Directions.L
		newHoverHint.setHintText(hint)
		hBox.add_child(newHoverHint)
	else:
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_right",64)
		margin.add_theme_constant_override("margin_top",64)
		hBox.add_child(margin)
	hBox.add_child(newNode)
	if newNode is Control: newNode.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	propertiesList.add_child(hBox)
	
##	tell the editor to forget any other objects and focus on this object
func setObjectBeingEdited(object):
	if globalEditor.objectBeingEdited:
		globalEditor.objectBeingEdited.setNotEditing()
	globalEditor.objectBeingEdited = object
	object.isBeingEdited = true

##This populates the sidebar with layer editing nodes. This could replace player and object property editing later.
func populateLayersUI(object): #This is probably redundant
	signalBus.showPropertiesSidebar.emit()
	emptyPropertiesUI()
	propertiesList.add_theme_constant_override("separation",32)
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_top",32)
	propertiesList.add_child(margin)
	#	tell the editor to forget any other objects and focus on this object
	#setLayersBeingEdited(object)
	setObjectBeingEdited(object)
#	populate the properties editor
	for layer in globalEditor.level.layers:
		var newNode:LayerEditor = LAYER_EDITOR.instantiate()
		newNode.layerID = layer
		#globalEditor.propertiesUI.add_child(newNode)
		propertiesList.add_child(newNode)
	signalBus.editingObject.emit("Layers",-2)
	titleHint.setHintText("""Your scene can have multiple parallax layers! 
	Setting the scroll value makes layers move at different speeds as the camera moves, creating depth.
	Layer 0 is the playable layer where the player resides and interacts. All other layers are purely visual.""")
	#signalBus.setThingDescription.emit("""Your scene can have multiple parallax layers! 
	#Setting the scroll value makes layers move at different speeds as the camera moves, creating depth.
	#Layer 0 is the playable layer where the player resides and interacts. All other layers are purely visual.""")
func setLayersBeingEdited(object):
	if globalEditor.objectBeingEdited:
		globalEditor.objectBeingEdited.setNotEditing()
	globalEditor.objectBeingEdited = object
	object.isBeingEdited = true
