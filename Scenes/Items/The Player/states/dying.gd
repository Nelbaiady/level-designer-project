extends PlayerState

const deathSound = preload("uid://8xb1en7en8gg")

func enter(_previous_state_path: String, _data := {}) -> void:
	player.resetPlay("die")
	player.audioStreamPlayer.stream = deathSound
	player.audioStreamPlayer.play()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="die":
		signalBus.startEditMode.emit()
