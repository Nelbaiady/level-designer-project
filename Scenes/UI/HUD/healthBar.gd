class_name HealthBar extends Label

func _ready() -> void:
	signalBus.updatePlayerHealth.connect(updateHealthDisplay)
	signalBus.startPlayMode.connect(updateHealthDisplay)
	
func updateHealthDisplay():
	text = str("Health: ",globalEditor.player.currentHealth, " / " ,globalEditor.player.maxHealth)
