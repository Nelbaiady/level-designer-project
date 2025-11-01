extends Node2D

@onready var animationPlayer: AnimationPlayer = $Sprite2D/AnimationPlayer
var strength:float = 1300

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.velocity.y >= 0:
			body.velocity = Vector2(body.velocity.x,-strength)
		animationPlayer.play("RESET")
		animationPlayer.play("Spring_springing")
		


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="Spring_springing":
		animationPlayer.current_animation="Spring_idle"
