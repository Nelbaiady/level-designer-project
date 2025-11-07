extends Camera2D

@onready var player: CharacterBody2D = $"../Player"

var tileSize=100

#holding to move camera
var heldDir: Vector2 = Vector2(0,0)
var heldDirName: String = ""
var holdTimer: float = 0
const holdThreshold = 0.3
const holdStepThreshold = 0.08
var nextHoldStepTarget = holdThreshold

func _ready() -> void:
	globalEditor.connect("resetStage",resetCamera)

#func _input(event: InputEvent) -> void:
	#if globalEditor.isEditing:
		#if event.is_action_pressed("up"):
			#heldDirName = "up"
			#holdTimer=0
			#heldDir = Vector2(0,-tileSize)
			#transLateCamera(heldDir)
		#if event.is_action_pressed("down"):
			#heldDirName = "down"
			#holdTimer=0
			#heldDir = Vector2(0,tileSize)
			#transLateCamera(heldDir)
		#if event.is_action_pressed("left"):
			#heldDirName = "left"
			#holdTimer=0
			#heldDir = Vector2(-tileSize,0)
			#transLateCamera(heldDir)
		#if event.is_action_pressed("right"):
			#heldDirName = "right"
			#holdTimer=0
			#heldDir = Vector2(tileSize,0)
			#transLateCamera(heldDir)

func resetCamera():
	position = Vector2(576,324)

func _physics_process(delta: float) -> void:
	transLateCamera(Input.get_vector("rLeft","rRight","rUp","rDown")*25)
	#if heldDirName != "":
		#holdTimer+=delta
		#if holdTimer>=holdThreshold:
			#if holdTimer >= nextHoldStepTarget:
				#nextHoldStepTarget += holdStepThreshold
				#transLateCamera(heldDir)
		#if Input.is_action_just_released(heldDirName):
			#holdTimer = 0
			#heldDirName = ""
			#heldDir = Vector2.ZERO
			#nextHoldStepTarget = holdThreshold

	if !globalEditor.isEditing:
		position = player.position

func transLateCamera(direction: Vector2):
	position += direction
