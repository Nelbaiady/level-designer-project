class_name genericEnemy extends CharacterBody2D
@export var animatedSprite: AnimatedSprite2D
@export var visionArea: Area2D
@export var flippableColliders:Array[Area2D] = []

var roamTime : float = 0
var roamTimer:float = 0

#properties
var targetSpeed = 0
var maxSpeed:=250
var acceleration:=600
var deceleration:=acceleration
var maxHealth:=1
var gravity := 50.0
var terminalVelocity := 1500.0

#states
var currentHealth := maxHealth
var facingRight:=false

enum states {IDLE, ROAMING, CHASING, DYING}
var state = states.IDLE

##how quickly this creature switches between random states
var restlessness:float = 1


signal takeAttack()
#signal dealAttack()

func _ready() -> void:
	reset()
	signalBus.startEditMode.connect(reset)
	
	takeAttack.connect(takeDamage)
	#dealAttack.connect(dealDamage)

##whenever edit mode is entered, make sure everything reset
func reset():
	roamTime = randf_range(1,6/restlessness)
	state = states.IDLE
	animatedSprite.animation = "idle"
	animatedSprite.speed_scale = 1
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
		if animatedSprite.animation != "running" and state in [states.ROAMING,states.CHASING] and abs(get_real_velocity().x) >= 12:
			animatedSprite.animation = "run"
		if (animatedSprite.animation != "idle" and abs(get_real_velocity().x) < 6 and state in[states.IDLE, states.ROAMING, states.CHASING]):
			
			animatedSprite.animation = "unrun"

		if animatedSprite.animation in ["running","run","unrun"]:
			var desiredAnimSpeed = abs(velocity.x/maxSpeed)
			if desiredAnimSpeed < 0.8:
				desiredAnimSpeed = 0.8
			animatedSprite.speed_scale = desiredAnimSpeed
		else:
			animatedSprite.speed_scale = 1
		
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

func setState(newState:states):
	state = newState
	match newState:
		states.IDLE:
			targetSpeed = 0
			#animatedSprite.animation = "unrun"
		states.ROAMING:
			facingRight = randi_range(0 , 1)
			orientDirection()
			var direMult = 1 if facingRight else -1
			targetSpeed = maxSpeed * direMult
			#animatedSprite.animation = "run"
		states.DYING:
			animatedSprite.animation = "crush"

##makes the object face the direction its supposed to, including sprite and collision
func orientDirection():
	if animatedSprite.flip_h != facingRight:
		for i in flippableColliders:
			i.scale.x *= -1
		animatedSprite.flip_h = facingRight

func _on_animated_sprite_2d_animation_finished() -> void:
	match animatedSprite.animation:
		"run":
			animatedSprite.animation = "running"
		"unrun":
			animatedSprite.animation = "idle"
		"crush":
			#dead
			visible = false
			pass
			
	animatedSprite.play()


func _on_hit_box_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and state != states.DYING:
		pass

##taking damage
func _on_hurt_box_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and area.is_in_group("hitbox") and "rootNode" in area and area.rootNode is Player:
		#if area.rootNode.velocity.y > 0 and !area.rootNode.bouncedThisFrame:
		if !area.rootNode.bouncedThisFrame:
				#area.rootNode.bouncedThisFrame = true
				area.rootNode.getBounced.emit(velocity.slide(Vector2.UP.rotated(area.rotation)) + Vector2.UP.rotated(area.rotation) * (700))
				takeDamage()

func takeDamage(damage=1):
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
