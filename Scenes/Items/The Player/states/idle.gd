#IDLE STATE
extends PlayerState

func enter(_previous_state_path: String, _data := {}) -> void:
	player.resetPlay("idle")
	player.jumpsLeft=player.maxJumps
	player.refreshJumps()

func physics_update(delta: float) -> void:
	player.velocity.y += player.gravity * player.gravityMult * delta
	player.velocity = Vector2(move_toward(player.velocity.x,0,player.deceleration*delta),player.velocity.y)
	player.move_and_slide()

	if !player.is_on_floor():
		finished.emit(FALLING,{"fell":true})
	elif player.directionInput.y < player.crouchInputThreshold and player.canCrouch:
		finished.emit(CROUCHED)
	elif player.directionInput.y > -player.crouchInputThreshold and player.canChourc and player.chourcCheck():
		finished.emit(CHOURCED)
	elif player.directionInput.x != 0:
		finished.emit(RUNNING)
	player.tryToJump()
