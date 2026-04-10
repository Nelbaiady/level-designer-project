extends RigidBody2D

@onready var animationPlayer: AnimationPlayer = $Sprite2D/AnimationPlayer

var bounciness:int = 1100
var bouncinessMult:float = 1

signal jumpedOn()

func _ready() -> void:
	jumpedOn.connect(getJumpedOn)

func getJumpedOn(_body, _source):
	#animationPlayer.play("RESET")
	animationPlayer.play("Spring_springing")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="Spring_springing":
		animationPlayer.current_animation="Spring_idle"
