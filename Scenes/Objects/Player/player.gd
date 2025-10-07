extends CharacterBody2D
const gravity = 2400
const maxMoveSpeed = 700
const accelaration = 4000
const jumpSpeed = 1000
var gravityMult = 1
var jumping = false

var directionInput = Vector2.ZERO

var lastEditPosition = Vector2.ZERO

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	globalEditor.connect("resetStage",resetPlayer)

func _physics_process(delta: float) -> void:
	#Either mode
	directionInput = Vector2(Input.get_axis("left","right"),Input.get_axis("down","up"))
	#Edit mode
	if globalEditor.isEditing:
		lastEditPosition = position
	
	#Play mode
	else:
		velocity = Vector2(move_toward(velocity.x,directionInput.x * maxMoveSpeed,accelaration*delta),velocity.y)
		velocity.y += gravity * gravityMult * delta
		
		if Input.is_action_just_pressed("jump"):
			#Jump if jump button is pressed and the player is on the floor
			if (is_on_floor()):
				velocity= Vector2(velocity.x, -jumpSpeed)
				jumping = true
		else:
			pass
			
		if (is_on_floor()):
			jumping = false
			gravityMult = 1
		else:
			if !Input.is_action_pressed("jump"):
				gravityMult = 1.5
		move_and_slide()
		manageAnimations()

func resetPlayer():
	position = lastEditPosition
	velocity = Vector2.ZERO
	animationPlayer.current_animation="idle"

func manageAnimations():
	if directionInput.x < 0: sprite.flip_h = true 
	if directionInput.x > 0: sprite.flip_h = false
	if !is_on_floor():
		if velocity.y > 0:
			animationPlayer.current_animation="jumped"
		elif velocity.y < 0:
			animationPlayer.current_animation="jumpUp"
	elif abs(velocity.x) > 0:
		animationPlayer.current_animation="run"
	elif abs(velocity.x) < 0.1:
		animationPlayer.current_animation="idle"
