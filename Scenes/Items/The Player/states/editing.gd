#EDITING STATE
extends PlayerState

func enter(_previous_state_path: String, _data := {}) -> void:
	player.animationPlayer.play("idle")
