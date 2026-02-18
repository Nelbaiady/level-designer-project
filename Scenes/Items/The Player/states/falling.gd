#FALLING STATE
extends PlayerState

func enter(_previous_state_path: String, _data := {}) -> void:
	#player.animationPlayer.play(&"RESET")
	#player.animationPlayer.advance(0)
	#player.animationPlayer.play("jumped")
	player.resetPlay("jumped")
	player.gravityMult = player.fallingGravityMult

func physics_update(delta: float) -> void:
	if player.velocity.y < player.terminalVelocity:
		player.velocity.y += player.gravity * player.gravityMult * delta  
	else: 
		player.velocity.y = player.terminalVelocity
	player.velocity = Vector2(move_toward(player.velocity.x,player.directionInput.x * player.topRunSpeed,player.acceleration*delta),player.velocity.y)
	player.move_and_slide()
		
	if player.is_on_floor():
		finished.emit(IDLE)
	if player.velocity.y < 0:
		finished.emit(RISING)
