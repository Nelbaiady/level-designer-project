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

#Exported stats
@export var maxHealth : int = 3
@export var invulnerabilityTime : float = 2 ##amount of time the player cannot take damage again for after taking damage
@export var invulnerabilityTimer : float = invulnerabilityTime ##is 0 and increases over time when the player is invulnerable and when it is >= invulnerabilityTime, the player is no longer invulnerable 
@export var invulnerabilityFlickerSpeed : float = 0.2 ##how quickly the flicker is toggled
@export var gravity : int = 2400
@export var terminalVelocity : int = 2000
@export var topRunSpeed : int = 700
@export var acceleration : int = 4000
@export var deceleration : int = 4000
@export var airAcceleration : int = 4000
@export var airDeceleration : int = 4000
@export var jumpPower : int = 1000
@export var canJump := true
@export var canCrouch := true
@export var canChourc := false
@export var canCrawl := true
@export var fallingGravityMult : float = 3
@export var crouchInputThreshold : float = -0.8

#Variables that change during gameplay
var gravityMult : float = 1
var currentHealth: int = maxHealth

var jumping:bool = false
var bounced:bool = false
##make sure the player cannot bounce on multiple things in the same frame
var bouncedThisFrame:bool = false

var directionInput = Vector2.ZERO

#Signals
##signal for when the player is bounced
signal getBounced(velocity)

func _ready() -> void:
	globalEditor.player = self
	getBounced.connect(bounce)
	signalBus.startEditMode.connect(enterEditState)
	signalBus.startPlayMode.connect(enterPlayState)

func bounce(bounceVelocity):
	if !bouncedThisFrame:
		bouncedThisFrame = true
		stateMachine._transitionToNextState("Rising",{"bounced":true,"bounceVelocity":bounceVelocity})
	
	velocity = bounceVelocity

func enterEditState():
	reset()
	stateMachine._transitionToNextState("Editing")
	sprite.flip_h = false
func enterPlayState():
	reset()
	stateMachine._transitionToNextState("Idle")

##resets stats when transitioning between edit/play modes
func reset():
	sprite.rotation = 0
	currentHealth = maxHealth
	invulnerabilityTimer = invulnerabilityTime
	gravityMult = 1
	
func _physics_process(_delta: float) -> void:
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

##plays an animation and also plays the reset track (reset no longer happens for now due to bugs)
func resetPlay(animation:String):
	#animationPlayer.play(&"RESET")
	#animationPlayer.advance(0)
	restoreSpriteScale()
	animationPlayer.play(animation)
	#animationPlayer.advance(0)
func playAnim(animation:String):
	animationPlayer.play(animation)
func restoreSpriteScale():
	sprite.scale = Vector2.ONE

func chourcCheck():
	for i in chourcChecker.get_overlapping_bodies():
		if i.is_in_group("solids") and i != self:
			return false
	return true

###Dealing damage
#func _on_hitbox_area_2d_area_entered(area: Area2D) -> void:
	#pass
	#if area.is_in_group("hurtbox") and !area.is_in_group("player"):
		#if area.position.y > $hitboxArea2D/hitbox.position.y:
			#pass

##Taking damage
func _on_hurtbox_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("hitbox") and !area.is_in_group("player"):
		if invulnerabilityTimer >= invulnerabilityTime:
			knockBack(area.global_position)
			takeDamage()
func takeDamage(damage:=1):
	if stateMachine.state.name!="Dying":
		##make sure the player isnt invulnerable
		currentHealth -= damage
		if currentHealth<0: currentHealth = 0
		signalBus.updatePlayerHealth.emit()
		if currentHealth <= 0:
			die()
		else:
			invulnerabilityTimer = 0
func knockBack(sourceLocation:Vector2, power=800):
	##knock the player away from the source (plus a corrective y value to make sure the player isnt knocked into the air for no reason)
	velocity = ((position-sourceLocation).normalized() + Vector2(0,0.5)) * power 
func die():
	stateMachine._transitionToNextState("Dying")
