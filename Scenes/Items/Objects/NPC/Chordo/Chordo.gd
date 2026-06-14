extends GenericEnemy

#func _process(delta: float) -> void:
	#pass
#func _ready() -> void:
	#super()
	#$AnimationPlayer.play("folding")
#func reset():
	#super()
	#$AnimationPlayer.play("folding")
	#$AnimationPlayer.speed_scale = 0.2
	#$Sprite2D.scale=Vector2.ONE
