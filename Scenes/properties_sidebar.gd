class_name PropertiesSidebar extends Control

var hotbarTween:Tween
const LAYER_EDITOR = preload("uid://0c854hhnl8dy")
@export var propertiesList: VBoxContainer

func _ready() -> void:
	#globalEditor.propertiesSidebar = self
	#globalEditor.propertiesUI = $"../HUD/PropertiesSidebar/PropertiesPanel/ScrollContainer/Properties"
	signalBus.populatePropertiesUI.connect(populatePropertiesUI)
	signalBus.populateLayersUI.connect(populateLayersUI)
	signalBus.showPropertiesSidebar.connect(showSidebar)
	signalBus.hidePropertiesSidebar.connect(hideSidebar)

func showSidebar():
	signalBus.setThingDescription.emit("") #hide the hint hoverHint
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
	#for i in globalEditor.propertiesUI.get_children():
	for i in propertiesList.get_children():
		i.queue_free()

func populatePropertiesUI(object):
	signalBus.showPropertiesSidebar.emit()
	emptyPropertiesUI()
	setObjectBeingEdited(object)
#	populate the properties editor
	for i in object.properties:
		if i is ObjectProperty:
			var newNode = i.uiNode.instantiate()
			#globalEditor.propertiesUI.add_child(newNode)
			propertiesList.add_child(newNode)
			if newNode is PropertyEditor:
				newNode.setStartValues(object.getProperty(i.codeName),i)
	if !signalBus.updateProperty.is_connected(object.setProperty):
		signalBus.updateProperty.connect(object.setProperty)
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
	#	tell the editor to forget any other objects and focus on this object
	#setLayersBeingEdited(object)
	setObjectBeingEdited(object)
#	populate the properties editor
	for i in globalEditor.level.layers:
		var newNode:LayerEditor = LAYER_EDITOR.instantiate()
		newNode.layerID = i
		#globalEditor.propertiesUI.add_child(newNode)
		propertiesList.add_child(newNode)
	signalBus.editingObject.emit("Layers",-2)
	signalBus.setThingDescription.emit("""Your scene can have multiple parallax layers! 
	Setting the scroll value makes layers move at different speeds as the camera moves, creating depth.
	Layer 0 is the playable layer where the player resides and interacts. All other layers are purely visual.
	""")
func setLayersBeingEdited(object):
	if globalEditor.objectBeingEdited:
		globalEditor.objectBeingEdited.setNotEditing()
	globalEditor.objectBeingEdited = object
	object.isBeingEdited = true
