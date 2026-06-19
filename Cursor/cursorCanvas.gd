class_name CursorCanvas extends CanvasLayer

@export var cursor: Cursor

@export var hintContainer: CursorHint

#func _ready() -> void:
	#if isTitle: signalBus.setThingDescription.connect(setHintText)
	
