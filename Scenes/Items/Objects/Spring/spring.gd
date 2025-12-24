extends RigidBody2D

@onready var animationPlayer: AnimationPlayer = $Sprite2D/AnimationPlayer

var baseStrength:int = 1100
var power:float = 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !globalEditor.isEditing:
		if body.is_in_group("player") or body.is_in_group("movable"):
			#OLD VERSION #body.velocity = (body.velocity * abs(Vector2(1,0).rotated(rotation))) + Vector2(0,-(baseStrength*power)).rotated(rotation)
			body.velocity = body.velocity.slide(Vector2.UP.rotated(rotation)) + Vector2.UP.rotated(rotation) * (baseStrength * power)
			
			body.gravityMult = 1.0
			body.bounced = true
			animationPlayer.play("RESET")
			animationPlayer.play("Spring_springing")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="Spring_springing":
		animationPlayer.current_animation="Spring_idle"
