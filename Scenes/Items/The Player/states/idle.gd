#IDLE STATE
extends PlayerState

func enter(_previous_state_path: String, _data := {}) -> void:
	#player.animationPlayer.play(&"RESET")
	#player.animationPlayer.advance(0)
	#player.animationPlayer.play("idle")
	player.resetPlay("idle")

func chourcCheck():
	for i in player.chourcChecker.get_overlapping_bodies():
		if i.is_in_group("solids") and i != player:
			return false
	return true

func physics_update(delta: float) -> void:
	player.velocity.y += player.gravity * player.gravityMult * delta
	player.velocity = Vector2(move_toward(player.velocity.x,0,player.deceleration*delta),player.velocity.y)
	player.move_and_slide()

	if !player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump") and player.canJump:
		finished.emit(RISING)
	elif player.directionInput.y < player.crouchInputThreshold and player.canCrouch:
		finished.emit(CROUCHED)
	elif player.directionInput.y > -player.crouchInputThreshold and player.canChourc and chourcCheck():
		finished.emit(CHOURCED)
	elif player.directionInput.x != 0:
		finished.emit(RUNNING)
