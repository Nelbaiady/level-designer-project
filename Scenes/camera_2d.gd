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
	signalBus.connect("resetStage",resetCamera)

func resetCamera():
	position = Vector2(576,324)

func _physics_process(_delta: float) -> void:
	if !globalEditor.popupIsOpen:
		transLateCamera(Input.get_vector("rLeft","rRight","rUp","rDown")*25)

	if !globalEditor.isEditing:
		position = player.position

func transLateCamera(direction: Vector2):
	position += direction
