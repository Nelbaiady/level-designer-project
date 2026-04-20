#RISING STATE
extends PlayerState

var bounced := false
var jumped := false
var fell := false
func enter(_previous_state_path: String, _data := {}) -> void:
	bounced = false
	jumped = false
	fell = false
	player.resetPlay("jumpUp")
	player.gravityMult = 1
	
	if _data.has("bounced") and _data["bounced"]==true:
		bounced = true
		player.velocity = _data.bounceVelocity
	else:
		player.velocity= Vector2(player.velocity.x, -player.jumpPower)
	if _data.has("jumped"):
		jumped = _data["jumped"]
	if _data.has("fell"):
		fell=_data["fell"]
func physics_update(delta: float) -> void:
	player.velocity.y += player.gravity * player.gravityMult * delta
	player.velocity = Vector2(move_toward(player.velocity.x,player.directionInput.x * player.topRunSpeed,player.acceleration*delta),player.velocity.y)
	if (Input.is_action_just_released("jump") and !bounced) or player.velocity.y > 0:
		player.gravityMult = player.fallingGravityMult
		
	player.move_and_slide()
	
	if player.is_on_floor():
		finished.emit(IDLE)
	if player.velocity.y > 0:
		finished.emit(FALLING,{"jumped":jumped,"bounced":bounced,"fell":fell})
