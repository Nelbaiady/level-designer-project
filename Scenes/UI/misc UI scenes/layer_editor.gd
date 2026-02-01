class_name LayerEditor extends Control

@export var layerID = 0
var level:Level
var layer:LevelLayer
@onready var scrollScalePropertyEditorNode: PropertyEditor = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/ScalePropertyEditor
@onready var colorPropertyEditorNode: LayerColorPropertyEditor = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/ColorPropertyEditor
@onready var selectionPropertyEditorNode: LayerCheckBoxPropertyEditor = $PanelContainer/MarginContainer/HBoxContainer/CheckBox
@onready var label: Label = $PanelContainer/MarginContainer/HBoxContainer/Label
@onready var trashButton: Button = $PanelContainer/MarginContainer/HBoxContainer/TrashButton
@onready var upButton: Button = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/upButton
@onready var downButton: Button = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/downButton

func _ready() -> void:
	signalBus.selectLayer.connect(layerChanged)
	level = globalEditor.level
	layer = level.layers[layerID]
	scrollScalePropertyEditorNode.setStartValues(layer.scroll_scale,0,0,0.1,"scroll_scale","Scroll",false,false,[layerID])
	colorPropertyEditorNode.setStartValues(layer.modulate,0,0,0,"modulate","Color",false,false,[layerID])
	#selectionPropertyEditorNode.setStartValues((level.layerID==layerID),0,0,0,"","",false,false,[layerID])
	refreshData()
	signalBus.updateLayerUI.connect(refreshData)

func layerChanged(_newLayer):
	refreshData()

func refreshData():
	layer = level.layers[layerID]
	label.text = str( "Layer ",layerID )
	trashButton.visible=false if layerID==0 else true
	upButton.visible = false if (layerID == level.layers.keys().max() or layerID==0) else true
	downButton.visible = false if (layerID == level.layers.keys().min() or layerID==0) else true
	scrollScalePropertyEditorNode.layerIndex = layerID
	colorPropertyEditorNode.layerIndex = layerID
	selectionPropertyEditorNode.layerIndex = layerID
	selectionPropertyEditorNode.updateValue(globalEditor.currentLayer)
	

func _on_up_button_pressed() -> void:
##	get the layer node's index position relative to its siblings
	#var targetNodeIndex:int
##	If the above layer is layer 0
	#if layerID==-1:
		#targetNodeIndex = (level.layers[layerID+1].get_index()-1) #move two steps above layer 0 (the player is supposed to be in between)
	#else: 
		#targetNodeIndex = level.layers[layerID+1].get_index()
		#level.swapLayers(layerID,layerID+1)
		#
	#level.move_child(level.layers[layerID],targetNodeIndex)
	#
	signalBus.moveLayerUp.emit(layerID)
	#refreshData()
	#level.collectChildren()

func _on_down_button_pressed() -> void:
	signalBus.moveLayerDown.emit(layerID)
	#refreshData()
	#level.collectChildren()
