extends GenericEnemy

enum chordoStates {IDLE, FOLDING, FOLDED, UNFOLDING}
var chordoState = states.IDLE

var idleTime = 1

var foldedTime = 1

var stateTimer = idleTime

func _ready() -> void:
	super()

func reset():
	stateTimer = idleTime
	chordoState = chordoStates.IDLE
	super()

func _physics_process(_delta: float) -> void:
	velocity.y += gravity if velocity.y<terminalVelocity else 0.0
	stateTimer -= _delta
	if stateTimer < 0:
		if chordoState == chordoStates.IDLE:
			animationPlayer.play("folding")
			chordoState = chordoStates.FOLDING
		if chordoState == chordoStates.FOLDED:
			animationPlayer.play("unfolding")
			chordoState = chordoStates.UNFOLDING
	move_and_slide()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	super(anim_name)
	if anim_name == "folding":
		animationPlayer.play("folded")
		chordoState = chordoStates.FOLDED
		stateTimer = foldedTime
		await get_tree().process_frame
		teleportChordo()
		#call_deferred("teleportChordo")
	if anim_name == "unfolding":
		animationPlayer.play("idle")
		chordoState = chordoStates.IDLE
		stateTimer = idleTime

#shifts chordo by one phase to immitate movement
func teleportChordo():
	if facingRight: position.x += 192*scale.x
	else: position.x -= 192*scale.x
