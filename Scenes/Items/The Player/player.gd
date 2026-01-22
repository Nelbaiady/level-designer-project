class_name Player extends CharacterBody2D
@export var gravity : int = 2400
@export var topRunSpeed : int = 700
@export var acceleration : int = 4000
@export var deceleration : int = 4000
@export var airAcceleration : int = 4000
@export var airDeceleration : int = 4000
@export var jumpPower : int = 1000
@export var canJump := true
@export var canCrouch := true
@export var canCrawl := true
@export var gravityMult : float = 1
@export var fallingGravityMult : float = 2
@export var crouchInputThreshold : float = -0.8

var jumping:bool = false
var bounced:bool = false

var directionInput = Vector2.ZERO

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var mainCollision: CollisionPolygon2D = $PlayerCollision
@onready var crouchCollision: CollisionPolygon2D = $PlayerCrouchCollision
@onready var uncrouchChecker: Area2D = $uncrouchChecker

@onready var stateMachine: StateMachine = $StateMachine


func _ready() -> void:
	globalEditor.player = self
	signalBus.startEditMode.connect(enterEditState)
	signalBus.startPlayMode.connect(exitEditState)

func enterEditState():
	stateMachine._transitionToNextState("Editing")
func exitEditState():
	stateMachine._transitionToNextState("Idle")

func _physics_process(_delta: float) -> void:
	##Either mode
	directionInput = Vector2(Input.get_axis("left","right"),Input.get_axis("down","up"))
	if !globalEditor.isEditing:
		if directionInput.x < 0: sprite.flip_h = true 
		if directionInput.x > 0: sprite.flip_h = false

##plays an animation and also plays the reset track
func resetPlay(animation:String):
	animationPlayer.play(&"RESET")
	animationPlayer.advance(0)
	animationPlayer.play(animation)
	animationPlayer.advance(0)
