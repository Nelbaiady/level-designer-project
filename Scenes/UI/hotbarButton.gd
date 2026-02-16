extends Button

@export var index:int
const emptyIcon = preload("uid://de1p8l0t4qll7")

func _ready() -> void:
	globalEditor.updateHotbar.connect(updateButton)
	globalEditor.updateHotbarSelection.connect(updateSelected)
	globalEditor.updateHotbarUI()
	updateSelected(globalEditor.hotbarIndex)
	
func updateButton(hotbarIndex:int, item:Item):
	if hotbarIndex == index:
		if item:
			icon = item.icon
			disabled = false
			#focus_mode = Control.FOCUS_ALL
			#button_pressed = true
		else:
			icon = emptyIcon
			disabled = true
			#focus_mode = Control.FOCUS_NONE
			button_pressed = false

func updateSelected(hotbarIndex:int):
	if hotbarIndex == index:
		#grab_focus()
		button_pressed = true
	else:
		button_pressed = false
func _pressed() -> void:
	globalEditor.setHotbarIndex(index)
