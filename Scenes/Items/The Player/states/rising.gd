#RISING STATE
extends PlayerState

var bounced := false
var jumped := false
var fell := false
func enter(_previous_state_path: String, _data := {}) -> void:
	#bounced = false
	#jumped = false
	#fell = false
	player.resetPlay("rising")
	player.gravityMult = 1
	
	
	if _data.has("bounced"):
		bounced = _data["bounced"]
	if bounced and _data.has("bounceVelocity"): 
		player.velocity = _data.bounceVelocity
	else:
		player.velocity.y = -player.jumpPower
	if _data.has("jumped"):
		jumped = _data["jumped"]
	if _data.has("fell"):
		fell=_data["fell"]
		
	if _data.has("wallJumped"):
		if _data["wallJumped"]:
			player.faceDirection(!player.wallDirection)
			player.wallJumping = true
			player.velocity.x = float(-player.jumpPower)/2 if player.wallDirection else float(player.jumpPower)/2
func physics_update(delta: float) -> void:
	#player.velocity.y += player.gravity * player.gravityMult * delta
	player.applyGravity(delta)
	
	#player.velocity = Vector2(move_toward(player.velocity.x,player.directionInput.x * player.topRunSpeed,player.acceleration*delta),player.velocity.y)
	var targetXacceleration = player.airDeceleration if player.directionInput.x==0 else player.airAcceleration 
	var targetXvelocity = player.directionInput.x * player.topRunSpeed
	if player.wallJumping and player.opposingInput: 
		targetXacceleration = player.airDeceleration
		targetXvelocity = 0
	player.velocity.x = move_toward(player.velocity.x,targetXvelocity,targetXacceleration*delta)
	if (Input.is_action_just_released("jump") and !bounced) or player.velocity.y > -200:
		player.gravityMult = player.fallingGravityMult
		
	player.move_and_slide()
	
	if player.is_on_floor():
		player.velocity.y=0 #if the velocity isnt zeroed, the player wouldve left the idle state immediately
		finished.emit(IDLE)
	if player.velocity.y > 0:
		finished.emit(FALLING,{"jumped":jumped,"bounced":bounced,"fell":fell})
	player.tryToJump(fell, bounced)

func exit() -> void:
	player.wallJumping = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "rising":
		player.resetPlay("rise")
