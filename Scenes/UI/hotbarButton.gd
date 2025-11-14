extends Button

@export var index:int
const emptyIcon = preload("uid://de1p8l0t4qll7")

func _ready() -> void:
	globalEditor.updateHotbar.connect(updateButton)
	globalEditor.updateHotbarSelection.connect(updateSelected)
	globalEditor.updateHotbarUI()
	
func updateButton(hotbarIndex:int, item:Item):
	if hotbarIndex == index:
		if item:
			icon = item.texture
			disabled = false
			focus_mode = Control.FOCUS_ALL
		else:
			icon = emptyIcon
			disabled = true
			focus_mode = Control.FOCUS_NONE

func updateSelected(hotbarIndex:int):
	if hotbarIndex == index:
		grab_focus()
func _pressed() -> void:
	globalEditor.setHotbarIndex(index)
