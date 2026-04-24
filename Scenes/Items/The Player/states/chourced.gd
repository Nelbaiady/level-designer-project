#CHOURCED STATE
extends PlayerState

func enter(_previous_state_path: String, _data := {}) -> void:
	player.playAnim("chourcing")
	if !player.animationPlayer.animation_finished.is_connected(crouchTransition):
		player.animationPlayer.animation_finished.connect(crouchTransition)
	player.mainCollision.disabled=true
	player.chourcCollision.disabled=false

func physics_update(delta: float) -> void:
	player.velocity.y += player.gravity * player.gravityMult * delta
	player.velocity = Vector2(move_toward(player.velocity.x,0,player.deceleration*delta),player.velocity.y)
	
	#player.velocity = Vector2(move_toward(player.velocity.x,player.directionInput.x * player.topRunSpeed,player.acceleration*delta),player.velocity.y)
	player.move_and_slide()

	if !player.is_on_floor():
		finished.emit(FALLING,{"fell":true})
	elif player.directionInput.y <= -player.crouchInputThreshold:
			finished.emit(IDLE)
			player.animationPlayer.play("unChourcing")
	player.tryToJump()
	
func exit() -> void:
	player.mainCollision.disabled=false
	player.chourcCollision.disabled=true

func crouchTransition(anim:String):
	if anim=="unChourcing":
		player.animationPlayer.play("idle")
