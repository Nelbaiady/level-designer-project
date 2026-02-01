#CROUCHED STATE
extends PlayerState

func enter(_previous_state_path: String, _data := {}) -> void:
	player.resetPlay("crouching")
	if !player.animationPlayer.animation_finished.is_connected(crouchTransition):
		player.animationPlayer.animation_finished.connect(crouchTransition)
	#if !player.uncrouchChecker. is_connected(crouchTransition):
		#player.animationPlayer.animation_finished.connect(crouchTransition)
	player.mainCollision.disabled=true
	player.crouchCollision.disabled=false

func physics_update(delta: float) -> void:
	player.velocity.y += player.gravity * player.gravityMult * delta
	player.velocity = Vector2(move_toward(player.velocity.x,0,player.deceleration*delta),player.velocity.y)
	#player.velocity = Vector2(move_toward(player.velocity.x,player.directionInput.x * player.topRunSpeed,player.acceleration*delta),player.velocity.y)
	player.move_and_slide()

	if !player.is_on_floor():
		player.mainCollision.disabled=false
		player.crouchCollision.disabled=true
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump") and player.canJump:
		player.mainCollision.disabled=false
		player.crouchCollision.disabled=true
		finished.emit(RISING)
	elif player.directionInput.y >= player.crouchInputThreshold:
		#perform the check inside so as not to check every frame.
		if unCrouchCheck():
			player.mainCollision.disabled=false
			player.crouchCollision.disabled=true
			finished.emit(IDLE)
			player.animationPlayer.play("unCrouching")

##checks if the player can uncrouch by making sure there are no solid objects above the player
func unCrouchCheck():
	for i in player.uncrouchChecker.get_overlapping_bodies():
		if i.is_in_group("solids") and i != player:
			return false
	return true

func crouchTransition(anim:String):
	if anim=="unCrouching":
		player.animationPlayer.play("idle")
