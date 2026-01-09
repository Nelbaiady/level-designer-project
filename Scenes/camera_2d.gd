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
	#signalBus.connect("playLevel",resetCamera)

func resetCamera():
	player = globalEditor.player
	tweenToPlayer()

func _physics_process(_delta: float) -> void:
	if !globalEditor.popupIsOpen:
		transLateCamera(Input.get_vector("camLeft","camRight","camUp","camDown")*25)

	if !globalEditor.isEditing:
		position = position.lerp(player.position,0.3) 

func transLateCamera(direction: Vector2):
	position += direction
	
func tweenToPlayer():
	
	var resetCamTween = create_tween()
	resetCamTween.set_trans(Tween.TRANS_CUBIC)
	resetCamTween.set_ease(Tween.EASE_OUT)
	resetCamTween.tween_property(self,"position",globalEditor.playerProperties.position ,0.3)
