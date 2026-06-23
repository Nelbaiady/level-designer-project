class_name Player extends CharacterBody2D
#Node variables
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var mainCollision: CollisionPolygon2D = $PlayerCollision
@onready var crouchCollision: CollisionPolygon2D = $PlayerCrouchCollision
@onready var chourcCollision: CollisionPolygon2D = $PlayerChourcCollision
@onready var uncrouchChecker: Area2D = $uncrouchChecker
@onready var chourcChecker: Area2D = $chourcChecker
@onready var stateMachine: StateMachine = $StateMachine
@onready var playerProperties: PlayerProperties = $playerProperties
#@onready var audioStreamPlayer: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audioStreamPlayer: AudioStreamPlayer2D = $Sprite2D/AudioStreamPlayer2D

const jumpSFX = preload("uid://5nvaopds8ngk")
const ouchSFX = preload("uid://bfdulbl1auotk")


#Exported stats
@export var maxHealth : int = 3
@export var invulnerabilityTime : float = 2 ##amount of time the player cannot take damage again for after taking damage
@export var invulnerabilityTimer : float = invulnerabilityTime ##is 0 and increases over time when the player is invulnerable and when it is >= invulnerabilityTime, the player is no longer invulnerable 
@export var invulnerabilityFlickerSpeed : float = 0.2 ##how quickly the flicker is toggled
@export var gravity : int = 2400
@export var terminalVelocity : int = 2000
@export var topRunSpeed : int = 700
@export var acceleration : int = 6000
@export var deceleration : int = 4000
@export var airAcceleration : int = 4000
@export var airDeceleration : int = 4000

@export var jumpPower : int = 1000
@export var maxJumps : int = 1 ##how many times the player can jump before landing
@export var jumpsLeft : int = maxJumps ##how many jumps the player has left
@export var coyoteTime : float = 0.05
var coyoteTimer : Timer = Timer.new()
@export var jumpBuffer : float = 0.1
var jumpBufferTimer : Timer = Timer.new()

@export var canCrouch := true
@export var canChourc := false
@export var canCrawl := true
@export var fallingGravityMult : float = 3
@export var crouchInputThreshold : float = -0.8

#Variables that change during gameplay
var gravityMult : float = 1
var currentHealth: int = maxHealth

var jumping:bool = false
#var bounced:bool = false
##make sure the player cannot bounce on multiple things in the same frame
var bouncedThisFrame:bool = false

var directionInput = Vector2.ZERO

##true if the player is inside a hitbox that should damage them
var isInHitbox := false
var hitBoxPosition := Vector2(0,0) ##when inside a hitbox keep track of its position for the next damage cycle

#Signals
##signal for when the player is bounced
signal getBounced(velocity)


func _ready() -> void:
	add_child( coyoteTimer )
	add_child( jumpBufferTimer )
	globalEditor.player = self
	getBounced.connect(bounce)
	signalBus.startEditMode.connect(enterEditState)
	signalBus.startPlayMode.connect(enterPlayState)

func bounce(bounceVelocity):
	if !bouncedThisFrame:
		bouncedThisFrame = true
		refreshJumps()
		stateMachine._transitionToNextState("Rising",{"bounced":true,"bounceVelocity":bounceVelocity})
		velocity = bounceVelocity

func enterEditState():
	reset()
	stateMachine._transitionToNextState("Editing")
	sprite.flip_h = false
func enterPlayState():
	reset()
	stateMachine._transitionToNextState("Idle",{'justStarted':true})
	#if is_on_floor():
		#stateMachine._transitionToNextState("Idle",{'justStarted':true})
	#else:
		#stateMachine._transitionToNextState("Falling",{'justStarted':true})

##resets stats when transitioning between edit/play modes
func reset():
	visible = true
	coyoteTimer.stop()
	jumpBufferTimer.stop()
	jumpsLeft=0
	sprite.rotation = 0
	currentHealth = maxHealth
	signalBus.updatePlayerHealth.emit()
	invulnerabilityTimer = invulnerabilityTime
	gravityMult = 1
	
func _physics_process(_delta: float) -> void:
	if !globalEditor.isEditing:
		if stateMachine.state.name in ["Dying"]:
			bouncedThisFrame = true #make sure the player cannot bounce
		#code that is common between most states
		else:
			bouncedThisFrame = false
			##Either mode
			directionInput = (Input.get_vector("LstickL","LstickR","LstickD","LstickU") + Input.get_vector("dpadL","dpadR","dpadD","dpadU")).limit_length(1) 
			if !globalEditor.isEditing:
				if directionInput.x < 0: sprite.flip_h = true 
				if directionInput.x > 0: sprite.flip_h = false
				
			#invulnerability animation
			if invulnerabilityTimer < invulnerabilityTime:
				invulnerabilityTimer += _delta
				visible = fmod(invulnerabilityTimer,invulnerabilityFlickerSpeed*2)<invulnerabilityFlickerSpeed
			else:
				visible = true
				invulnerabilityTimer = invulnerabilityTime
		if globalEditor.level and position.y > globalEditor.level.roomBottom:
			die()
	if isInHitbox:
		attemptToTakeDamage()
		

##plays an animation and also plays the reset track (reset no longer happens for now due to bugs)
func resetPlay(animation:String):
	restoreSpriteScale()
	#restoreSpritePosition()
	animationPlayer.play(animation)
func playAnim(animation:String):
	animationPlayer.play(animation)
func restoreSpriteScale():
	sprite.scale = Vector2.ONE

func chourcCheck():
	for i in chourcChecker.get_overlapping_bodies():
		if i.is_in_group("solids") and i != self:
			return false
	return true

##checks if the player has invulnerability frames and deals damage if not
func attemptToTakeDamage(knockback=Vector2.ZERO):
	if invulnerabilityTimer >= invulnerabilityTime:
		knockBack(knockback)
		takeDamage()
##Taking damage
func _on_hurtbox_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("hitbox") and !area.is_in_group("player"):
		isInHitbox = true
		hitBoxPosition = area.global_position
		attemptToTakeDamage(area.global_position)
		#if invulnerabilityTimer >= invulnerabilityTime:
			#knockBack(area.global_position)
			#takeDamage()
func _on_hurtbox_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("hitbox") and !area.is_in_group("player"):
		var hitboxInside = false
		for overlappingArea in $hurtboxArea2D.get_overlapping_areas():
			if overlappingArea is Area2D:
				if overlappingArea.is_in_group("hitbox") and !overlappingArea.is_in_group("player"):
					hitBoxPosition = overlappingArea.global_position
					hitboxInside = true
					break
		if !hitboxInside:
			isInHitbox = false
			
func takeDamage(damage:=1):
	if stateMachine.state.name!="Dying":
		##make sure the player isnt invulnerable
		currentHealth -= damage
		if currentHealth<0: currentHealth = 0
		signalBus.updatePlayerHealth.emit()
		if currentHealth <= 0:
			die()
		else:
			playSound(ouchSFX)
			invulnerabilityTimer = 0
func knockBack(sourceLocation:Vector2, power=1000):
	##knock the player away from the source (plus a corrective y value to make sure the player isnt knocked into the air for no reason)
	velocity = ((position-sourceLocation).normalized() + Vector2(0,0.5)) * power 
func die():
	if stateMachine.state.name!="Dying":
		visible = true
		stateMachine._transitionToNextState("Dying")

#func _process(delta: float) -> void:
	#print("coyote and jbuffer and jumpsLeft: ",!coyoteTimer.is_stopped(),"   ",!jumpBufferTimer.is_stopped(),"   ",jumpsLeft)

##repeatable function that checks if the player can jump
func tryToJump(fell=false, bounced=false):
	if Input.is_action_just_pressed("jump") or (!jumpBufferTimer.is_stopped() and Input.is_action_pressed("jump")):
		if (((is_on_floor() or (!fell and !bounced)) and jumpsLeft>0) or ((fell and !coyoteTimer.is_stopped()) or jumpsLeft>1)):
			jumpsLeft-=1
			coyoteTimer.stop()
			jumpBufferTimer.stop()
			playSound(jumpSFX)
			stateMachine.state.finished.emit(stateMachine.state.RISING,{"jumped":true,"fell":fell, "bounced":bounced})
		elif Input.is_action_just_pressed("jump") and !is_on_floor():
			if jumpBuffer > 0:
				jumpBufferTimer.one_shot = true
				jumpBufferTimer.start(jumpBuffer)
##restores jumps left to maxJumps
func refreshJumps():
	jumpsLeft = maxJumps
##starts the coyote timer
func refreshCoyoteTime():
	if coyoteTime > 0:
		coyoteTimer.one_shot = true
		coyoteTimer.start(coyoteTime)
		
func playSound(sound: AudioStream, randomPitch=0.2):
	audioStreamPlayer.stream = sound
	audioStreamPlayer.pitch_scale = randf_range(1-randomPitch,1+randomPitch)
	audioStreamPlayer.play()
