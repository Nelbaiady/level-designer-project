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
		else:
			icon = emptyIcon

func updateSelected(hotbarIndex:int):
	if hotbarIndex == index:
		grab_focus()
