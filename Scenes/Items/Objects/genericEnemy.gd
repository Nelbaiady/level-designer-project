class_name genericEnemy extends CharacterBody2D

@export var animationPlayer: AnimationPlayer
@export var visionArea: Area2D
@export var flippableColliders:Array[Area2D] = []
@export var flippableAnimatedSprites:Array[AnimatedSprite2D] = []
@export var flippableSprites:Array[Sprite2D] = []
#@export var animatedSprite: AnimatedSprite2D

var roamTime : float = 0
var roamTimer:float = 0

#properties
var targetSpeed = 0
var maxSpeed := 250
var acceleration := 600
var deceleration := acceleration
var maxHealth := 1
@export var gravity := 50.0
var terminalVelocity := 1500.0

#states
var currentHealth := maxHealth
var facingRight:=false

enum states {IDLE, ROAMING, CHASING, DYING}
var state = states.IDLE

#enable or disable certain states
@export var canRoam := true
@export var canChase := true
@export var canDie := true

##how quickly this creature switches between random states
var restlessness:float = 1



signal jumpedOn()

func _ready() -> void:
	signalBus.startEditMode.connect(reset)
	signalBus.startPlayMode.connect(reset)
	jumpedOn.connect(getJumpedOn)
	
	#in case i forget to set an animation player
	if !animationPlayer:
		for i in get_children():
			if i is AnimationPlayer:
				animationPlayer = i
	reset()

##whenever edit mode is entered, make sure everything reset
func reset():
	roamTime = randf_range(1,6/restlessness)
	state = states.IDLE
	animationPlayer.play("RESET")
	animationPlayer.play("idle")
	animationPlayer.speed_scale = 1
	currentHealth = maxHealth
	visible = true
	targetSpeed = 0
	facingRight = false
	orientDirection()
	roamTimer = 0
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if globalEditor.isEditing:
		velocity = Vector2.ZERO
	else:
		#gravity
		velocity.y += gravity if velocity.y<terminalVelocity else 0.0

		var usedAcc = deceleration if abs(velocity.x) >= abs(targetSpeed) else acceleration #whether to use acceleration or deceleration at the moment
		velocity.x = move_toward(velocity.x,float(targetSpeed),usedAcc*delta)
		
		match state:
			states.DYING:
				velocity.x = 0
			states.CHASING:
				if chaseTarget:
					facingRight = chaseTarget.position.x > position.x
					orientDirection()
					var direMult = 1 if facingRight else -1
					targetSpeed = maxSpeed * direMult
		#if the creature is not moving (difference in position < 12) make sure the creature plays the idle animation
		if animationPlayer.current_animation != "running" and state in [states.ROAMING,states.CHASING] and abs(get_real_velocity().x) >= 12:
			animationPlayer.current_animation = "run"
		if (animationPlayer.current_animation != "idle" and abs(get_real_velocity().x) < 6 and state in[states.IDLE, states.ROAMING, states.CHASING]):
			animationPlayer.current_animation = "unrun"

		if animationPlayer.current_animation in ["running","run","unrun"]:
			var desiredAnimSpeed = abs(velocity.x/maxSpeed)
			if desiredAnimSpeed < 0.8:
				desiredAnimSpeed = 0.8
			animationPlayer.speed_scale = desiredAnimSpeed
		else:
			animationPlayer.speed_scale = 1
		
		#random timed intervals between idling and moving around
		if roamTimer >= roamTime:
			roamTimer = 0
			if state == states.ROAMING:
				roamTime = snapped( randf_range(1,6/restlessness) , 0.1 )
				setState(states.IDLE)
			elif state == states.IDLE:
				roamTime = snapped( randf_range(1,3/restlessness) , 0.1 )
				setState(states.ROAMING)
		else:
			roamTimer+=delta
		
		move_and_slide()

##transitions to another state
func setState(newState:states):
	#If the newState is disabled, dont do anything
	if newState == states.ROAMING and !canRoam or newState == states.CHASING and !canChase or newState == states.DYING and !canDie:
		return
	state = newState
	match newState:
		states.IDLE:
			targetSpeed = 0
		states.ROAMING:
			facingRight = randi_range(0 , 1)
			orientDirection()
			var direMult = 1 if facingRight else -1
			targetSpeed = maxSpeed * direMult
		states.DYING:
			animationPlayer.play("crush")

##makes the object face the direction its supposed to, including sprite and collision
func orientDirection():
	#if animationPlayer.flip_h != facingRight:
		for i in flippableColliders:
			i.scale.x *= 1 if ((i.scale.x<0) and facingRight) or ((i.scale.x>0) and !facingRight) else -1
		for i in flippableSprites:
			i.flip_h = facingRight
		for i in flippableAnimatedSprites:
			i.flip_h = facingRight


func _on_hit_box_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and state != states.DYING:
		pass

func getJumpedOn(_player:Player, _area:Area2D):
		takeDamage()

func takeDamage(damage=1):
	if canDie:
		currentHealth-=damage
		if currentHealth<=0:
			die()

func die():
	setState(states.DYING)
	velocity.x = 0
	targetSpeed = 0
	(func(): process_mode = Node.PROCESS_MODE_DISABLED).call_deferred()

var chaseTarget = null
func _on_vision_area_body_entered(body: Node2D) -> void:
	if body is Player:
		chaseTarget = body
		setState(states.CHASING)

func _on_vision_exit_area_body_exited(body: Node2D) -> void:
	if body == chaseTarget:
		chaseTarget = null
		setState(states.IDLE)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"run":
			animationPlayer.play("running")
		"unrun":
			animationPlayer.play("idle")
		"crush":
			#dead
			visible = false
