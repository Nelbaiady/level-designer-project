class_name PropertiesSidebar extends Control

var hotbarTween:Tween
const LAYER_EDITOR = preload("uid://0c854hhnl8dy")

func _ready() -> void:
	#globalEditor.propertiesSidebar = self
	signalBus.populatePropertiesUI.connect(populatePropertiesUI)
	signalBus.populateLayersUI.connect(populateLayersUI)
	signalBus.showPropertiesSidebar.connect(showSidebar)
	signalBus.hidePropertiesSidebar.connect(hideSidebar)

func showSidebar():
	hotbarTween = create_tween()
	hotbarTween.set_trans(Tween.TRANS_CUBIC)
	hotbarTween.set_ease(Tween.EASE_OUT)
	hotbarTween.tween_property(self,"anchor_left",0.7,0.1)

func hideSidebar():
	hotbarTween = create_tween()
	hotbarTween.set_trans(Tween.TRANS_CUBIC)
	hotbarTween.set_ease(Tween.EASE_IN)
	hotbarTween.tween_property(self,"anchor_left",1,0.1)

func _on_close_button_pressed() -> void:
	signalBus.hidePropertiesSidebar.emit()

func emptyPropertiesUI():
	for i in globalEditor.propertiesUI.get_children():
		i.queue_free()

func populatePropertiesUI(object):
	signalBus.showPropertiesSidebar.emit()
	emptyPropertiesUI()
	setObjectBeingEdited(object)
#	populate the properties editor
	for i in object.properties:
		if i is ObjectProperty:
			var newNode = i.uiNode.instantiate()
			globalEditor.propertiesUI.add_child(newNode)
			if newNode is PropertyEditor:
				newNode.setStartValues(object.getProperty(i.codeName),i.minValue, i.maxValue,i.step , i.codeName, i.displayName,i.hasMin, i.hasMax ,[])
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
	setLayersBeingEdited(object)
#	populate the properties editor
	for i in globalEditor.level.layers:
		var newNode:LayerEditor = LAYER_EDITOR.instantiate()
		newNode.layerID = i
		globalEditor.propertiesUI.add_child(newNode)
		#if newNode is PropertyEditor:
			#newNode.setStartValues(object.getProperty(i.codeName),i.minValue, i.maxValue,i.step , i.codeName, i.displayName)
	#if !signalBus.updateProperty.is_connected(object.setProperty):
		#signalBus.updateProperty.connect(object.setProperty)
func setLayersBeingEdited(object):
	if globalEditor.objectBeingEdited:
		globalEditor.objectBeingEdited.setNotEditing()
	globalEditor.objectBeingEdited = object
	object.isBeingEdited = true
