##pauses animation nodes when the game is paused
extends Node

var animationPlayer:AnimationPlayer
func _ready() -> void:
	if get_parent() is AnimationPlayer: animationPlayer = get_parent()
	signalBus.pauseToggled.connect(togglePause)

var wasPaused = false
func togglePause():
	if system.isPaused:
		wasPaused = !animationPlayer.is_playing()
		animationPlayer.pause()
	else:
		if !wasPaused:
			animationPlayer.play()
	
	
