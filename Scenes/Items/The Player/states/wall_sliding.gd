#WALL SLIDING STATE
extends PlayerState
var fell = false
var bounced = false

var gravityMultTween:Tween

func enter(_previous_state_path: String, _data := {}) -> void:
	player.faceDirection(player.wallDirection)
	player.resetPlay("wallSlide")
	player.gravityMult = 1
	#player.velocity.y = 0
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
	player.gravityMult = move_toward(player.gravityMult, 0.5,delta*12)
	
	player.velocity.y = move_toward(player.velocity.y,float(player.terminalVelocity)/3,delta*2000)
	
	#if player.velocity.y < player.terminalVelocity/2:
		#player.velocity.y += player.gravity * player.gravityMult * delta  
	#else: 
		#player.velocity.y = player.terminalVelocity/2

	player.velocity = Vector2(move_toward(player.velocity.x,player.directionInput.x * player.topRunSpeed,player.acceleration*delta),player.velocity.y)
	player.move_and_slide()
	
	if player.is_on_floor():
		finished.emit(IDLE)
	if player.velocity.y < 0:
		finished.emit(RISING)
	if !player.checkWall():
		finished.emit(FALLING)
	player.tryToJump(fell, bounced, true, true)
	
#func exit() -> void:
	#player.gravityMult = 1
