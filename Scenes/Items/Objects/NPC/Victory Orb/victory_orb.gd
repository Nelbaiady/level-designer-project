extends Node2D

@export var area_2d: Area2D
@export var gpu_particles_2d: GPUParticles2D
@export var sprite_2d: Sprite2D

func _ready() -> void:
	area_2d.body_entered.connect(bodyEntered)
	signalBus.startEditMode.connect(finishedEmitting)
func finishedEmitting():
	sprite_2d.show()
	
func bodyEntered(body):
	if body is Player:#.is_in_group("player"):
		sprite_2d.hide()
		body.win()
		gpu_particles_2d.restart()
		gpu_particles_2d.emitting=true
