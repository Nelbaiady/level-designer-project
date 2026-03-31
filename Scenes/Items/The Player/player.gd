class_name Player extends CharacterBody2D
@export var maxHealth : int = 3
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
@export var gravityMult : float = 1
@export var fallingGravityMult : float = 2
@export var crouchInputThreshold : float = -0.8

var currentHealth: int

var jumping:bool = false
var bounced:bool = false

var directionInput = Vector2.ZERO

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var mainCollision: CollisionPolygon2D = $PlayerCollision
@onready var crouchCollision: CollisionPolygon2D = $PlayerCrouchCollision
@onready var chourcCollision: CollisionPolygon2D = $PlayerChourcCollision
@onready var uncrouchChecker: Area2D = $uncrouchChecker
@onready var chourcChecker: Area2D = $chourcChecker


@onready var stateMachine: StateMachine = $StateMachine
@onready var playerProperties: PlayerProperties = $playerProperties

##signal for when the player is bounced
signal getBounced(velocity)

func _ready() -> void:
	globalEditor.player = self
	getBounced.connect(bounce)
	
	signalBus.startEditMode.connect(enterEditState)
	signalBus.startPlayMode.connect(enterPlayState)

func bounce(bounceVelocity):
	velocity = bounceVelocity

func enterEditState():
	stateMachine._transitionToNextState("Editing")
	sprite.flip_h = false
func enterPlayState():
	currentHealth = maxHealth
	stateMachine._transitionToNextState("Idle")

func _physics_process(_delta: float) -> void:
	##Either mode
	directionInput = (Input.get_vector("LstickL","LstickR","LstickD","LstickU") + Input.get_vector("dpadL","dpadR","dpadD","dpadU")).limit_length(1) 
	if !globalEditor.isEditing:
		if directionInput.x < 0: sprite.flip_h = true 
		if directionInput.x > 0: sprite.flip_h = false

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


func _on_hitbox_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		getBounced.emit(velocity.slide(Vector2.UP.rotated(area.rotation)) + Vector2.UP.rotated(area.rotation) * (500))
		
