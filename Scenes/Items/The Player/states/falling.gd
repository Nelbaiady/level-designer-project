#FALLING STATE
extends PlayerState
var fell = false
var bounced = false

var gravityMultTween:Tween

func enter(_previous_state_path: String, _data := {}) -> void:
	#fell = false
	#bounced = false
	player.resetPlay("jumped")
	
	player.gravityMult = 1
	#player.gravityMult = player.fallingGravityMult
	
	
	#if the player fell off and didnt jump or bounce
	if _data.has("bounced"):
		bounced=_data["bounced"]
	if _data.has("fell"):
		fell=_data["fell"]
	
	if !(_data.has("justStarted") and _data["justStarted"]):
		if !(  (_data.has("bounced") and _data["bounced"]==true)  or  (_data.has("jumped") and _data["jumped"]==true)  ) and !_data.has('justStarted'):
			if !player.is_on_floor():
				player.refreshCoyoteTime()
func physics_update(delta: float) -> void:
	#increase gravity over time so the player falls faster, but doesnt feel like the fall is sudden (due to high initial acceleration)
	player.gravityMult = move_toward(player.gravityMult, player.fallingGravityMult,delta*16)
	#if player.velocity.y < player.terminalVelocity:
		#player.velocity.y += player.gravity * player.gravityMult * delta  
	#else: 
		#player.velocity.y = player.terminalVelocity
	player.applyGravity(delta)

	#player.velocity = Vector2(move_toward(player.velocity.x,player.directionInput.x * player.topRunSpeed,player.acceleration*delta),player.velocity.y)
	#var xAcceleration = player.airDeceleration if player.directionInput.x
	var targetXacceleration = player.airDeceleration if player.directionInput.x==0 else player.airAcceleration 
	var targetXvelocity = player.directionInput.x * player.topRunSpeed
	player.velocity.x = move_toward(player.velocity.x,targetXvelocity,targetXacceleration*delta)
	
	
	player.move_and_slide()
	if player.is_on_floor():
		finished.emit(IDLE)
	elif player.velocity.y < 0 and !player.is_on_floor():
		finished.emit(RISING)
	elif player.canWallJump and player.checkWall():
		#if player.wallJumping: 
		finished.emit(WALLSLIDING)
	player.tryToJump(fell, bounced)
	
#func exit() -> void:
	#player.gravityMult = 1
