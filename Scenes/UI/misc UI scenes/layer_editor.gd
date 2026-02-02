class_name LayerEditor extends Control

@export var layerID = 0
var level:Level
var layer:LevelLayer
@onready var scrollScalePropertyEditorNode: PropertyEditor = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/ScalePropertyEditor
@onready var colorPropertyEditorNode: LayerColorPropertyEditor = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/ColorPropertyEditor
@onready var selectionPropertyEditorNode: LayerCheckBoxPropertyEditor = $PanelContainer/MarginContainer/HBoxContainer/CheckBox
@onready var label: Label = $PanelContainer/MarginContainer/HBoxContainer/Label
@onready var trashButton: Button = $PanelContainer/MarginContainer/HBoxContainer/TrashButton
@onready var addAboveButton: Button = $addAboveButton
@onready var addBelowButton: Button = $addBelowButton
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

##when a layer is selected
func layerChanged(_newLayer):
	refreshData()

func refreshData():
	layer = level.layers[layerID]
	label.text = str( "Layer ",layerID )
	trashButton.visible=false if layerID==0 else true
	upButton.visible = false if (layerID == level.layers.keys().max() or layerID==0) else true
	downButton.visible = false if (layerID == level.layers.keys().min() or layerID==0) else true
	addAboveButton.visible = true if (layerID == level.layers.keys().max()) else false
	scrollScalePropertyEditorNode.layerIndex = layerID
	colorPropertyEditorNode.layerIndex = layerID
	selectionPropertyEditorNode.layerIndex = layerID
	selectionPropertyEditorNode.updateValue(globalEditor.currentLayer)

func _on_up_button_pressed() -> void:
	signalBus.moveLayerUp.emit(layerID)

func _on_down_button_pressed() -> void:
	signalBus.moveLayerDown.emit(layerID)

func _on_add_above_button_pressed() -> void:
	signalBus.addLayerAbove.emit(layerID)

func _on_add_below_button_pressed() -> void:
	signalBus.addLayerBelow.emit(layerID)
	
func _on_trash_button_pressed() -> void:
	signalBus.deleteLayer.emit(layerID)
