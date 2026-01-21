#RISING STATE
extends PlayerState

func enter(_previous_state_path: String, _data := {}) -> void:
	player.animationPlayer.play("jumpUp")
	player.velocity= Vector2(player.velocity.x, -player.jumpPower)
	player.gravityMult = 1

func physics_update(delta: float) -> void:
	player.velocity.y += player.gravity * player.gravityMult * delta
	player.velocity = Vector2(move_toward(player.velocity.x,player.directionInput.x * player.maxMoveSpeed,player.accelaration*delta),player.velocity.y)
	if Input.is_action_just_released("jump") or player.velocity.y > 0:
		player.gravityMult = player.fallingGravityMult
		
	player.move_and_slide()
	
	if player.is_on_floor():
		finished.emit(IDLE)
	if player.velocity.y > 0:
		finished.emit(FALLING)
