extends GenericEnemy

##areas that check that we aren't about to hit a wall
@export var stepChecks: Array[Area2D]
#@export var audio_stream_player_2d: AudioStreamPlayer2D
#
#const ACCORDION_HIGH = preload("uid://bcp8ofevb7grh")
#const ACCORDION_LOW = preload("uid://cnlgq5qtyhoss")
#
###plays the accordion. This accordion has no keys and only has 2 notes.
#func playAccordion(highness:bool):
	#audio_stream_player_2d.stream = ACCORDION_HIGH if highness else ACCORDION_LOW
	#audio_stream_player_2d.play()
	
enum chordoStates {IDLE, FOLDING, FOLDED, UNFOLDING}
var chordoState = states.IDLE

var idleTime = 0
var foldedTime = 0

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
		setChordoState(chordoStates.FOLDED)
		#animationPlayer.play("folded")
		#stateTimer = foldedTime
		#await get_tree().process_frame
		#teleportChordo()
		#chordoState = chordoStates.FOLDED
	if anim_name == "unfolding":
		if animationPlayer.speed_scale < 0:
			setChordoState(chordoStates.FOLDED)
		else:
			setChordoState(chordoStates.IDLE)
		#animationPlayer.play("idle")
		#stateTimer = idleTime
		#chordoState = chordoStates.IDLE

func setChordoState(newState:chordoStates):
	match newState:
		chordoStates.FOLDED:
			animationPlayer.play("folded")
			chordoState = chordoStates.FOLDED
			stateTimer = foldedTime
			await get_tree().process_frame
			#if we are reversing, return the animation speed to normal and continue
			#otherwise, teleport to adjust position
			if animationPlayer.speed_scale < 0:
				animationPlayer.speed_scale *= -1
				#facingRight = !facingRight
				#orientDirection()
				mirror()
				teleportChordo()
			else:
				teleportChordo()
		chordoStates.IDLE:
			animationPlayer.play("idle")
			stateTimer = idleTime
	chordoState = newState

#shifts chordo by one phase to immitate movement
func teleportChordo():
	if facingRight: position.x += 192*scale.x
	else: position.x -= 192*scale.x

##Make sure the area we are about to occupy when unfolding isn't taken up
func checkNextStep(step:int):
	for body in stepChecks[step].get_overlapping_bodies():
		#if we are about to hit a solid object/surface, reverse the animation
		if body.is_in_group("solids") and !body.is_in_group("player") and body != self: 
			animationPlayer.speed_scale = -1
