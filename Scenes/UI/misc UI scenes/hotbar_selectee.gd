##selectee in the hotbar
extends Selectee

var hotbarButton:HotbarButton
var index:int

func _ready() -> void:
	hotbarButton = get_child(0)
	index=hotbarButton.index
	globalEditor.updateHotbarSelection.connect(updateSelected)
	updateSelected.call_deferred(globalEditor.hotbarIndex)

func updateSelected(hotbarIndex:int):
	if hotbarIndex == index:
		callSelector()

###when instructed to, this selector will go to the given location
#func callSelector():
	#selector.goToPosition(global_position)
