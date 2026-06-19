extends Panel

func _ready() -> void:
	signalBus.showPropertiesSidebar.connect(showNamebar)
	signalBus.hidePropertiesSidebar.connect(hideNamebar)
	
func showNamebar():
	pass
func hideNamebar():
	pass
