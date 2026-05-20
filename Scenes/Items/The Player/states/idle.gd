#IDLE STATE
extends PlayerState

#should be on for the first frame of play, in order to prevent things such as coyote time when spawning in the air
var justStarted := false

func enter(_previous_state_path: String, _data := {}) -> void:
	player.resetPlay("idle")
	player.refreshJumps()
	
	if _data.has("justStarted") and _data["justStarted"]:
		justStarted = true

func physics_update(delta: float) -> void:
	player.velocity.y += player.gravity * player.gravityMult * delta
	player.velocity = Vector2(move_toward(player.velocity.x,0,player.deceleration*delta),player.velocity.y)
	player.move_and_slide()

	if !player.is_on_floor():
		finished.emit(FALLING,{"fell":true,"justStarted":justStarted})
	elif player.directionInput.y < player.crouchInputThreshold and player.canCrouch:
		finished.emit(CROUCHED)
	elif player.directionInput.y > -player.crouchInputThreshold and player.canChourc and player.chourcCheck():
		finished.emit(CHOURCED)
	elif player.directionInput.x != 0:
		finished.emit(RUNNING)
	player.tryToJump()
	
	justStarted = false
