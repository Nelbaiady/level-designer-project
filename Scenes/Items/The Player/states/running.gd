#RUNNING STATE
extends PlayerState

func enter(_previous_state_path: String, _data := {}) -> void:
	player.jumpsLeft=player.maxJumps
	player.resetPlay("run")

func physics_update(delta: float) -> void:
	player.velocity.y += player.gravity * player.gravityMult * delta
	player.velocity = Vector2(move_toward(player.velocity.x,player.directionInput.x * player.topRunSpeed,player.acceleration*delta),player.velocity.y)
	player.move_and_slide()

	if !player.is_on_floor():
		finished.emit(FALLING,{"fell":true})
	elif Input.is_action_just_pressed("jump") and player.jumpsLeft>0:
		player.jumpsLeft-=1
		finished.emit(RISING)
	elif player.directionInput.x == 0:
		finished.emit(IDLE)
	elif player.directionInput.y < player.crouchInputThreshold and player.canCrouch:
		finished.emit(CROUCHED)
	elif player.directionInput.y > -player.crouchInputThreshold and player.canChourc and player.chourcCheck():
		finished.emit(CHOURCED)
