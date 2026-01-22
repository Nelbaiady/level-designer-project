#EDITING STATE
extends PlayerState

func enter(_previous_state_path: String, _data := {}) -> void:
	#player.animationPlayer.play(&"RESET")
	#player.animationPlayer.advance(0)
	#player.animationPlayer.play("idle")
	player.resetPlay("idle")
