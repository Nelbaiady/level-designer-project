extends PlayerState

const winSound = preload("uid://pdtxvwe1ga7q")

func enter(_previous_state_path: String, _data := {}) -> void:
	player.resetPlay("win")
	player.playSound(winSound,0)
	signalBus.wonLevel.emit()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="win":
		signalBus.startEditMode.emit()
