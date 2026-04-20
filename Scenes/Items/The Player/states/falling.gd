#FALLING STATE
extends PlayerState
var fell = false
func enter(_previous_state_path: String, _data := {}) -> void:
	fell = false
	player.resetPlay("jumped")
	player.gravityMult = player.fallingGravityMult
	#if the player fell off and didnt jump or bounce
	if _data.has("fell"):
		fell=_data["fell"]
	if !((_data.has("bounced") and _data["bounced"]==true) or (_data.has("jumped") and _data["jumped"]==true)):
		player.refreshCoyoteTime()
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
	player.tryToJump(fell)
