class_name GameplayCamera extends Camera2D

#@onready var player: CharacterBody2D = $"../Level/Player"
#@onready var player: Player = $"../Level/Layer0/Player"
@onready var player#: Player = $"../Level/Layer0/Objects/Player"

var tileSize=100

#holding to move camera
var heldDir: Vector2 = Vector2(0,0)
var heldDirName: String = ""
var holdTimer: float = 0
const holdThreshold = 0.3
const holdStepThreshold = 0.08
var nextHoldStepTarget = holdThreshold
@onready var phantom_camera_host: PhantomCameraHost = $PhantomCameraHost
@onready var phantomCamera: PhantomCamera2D = $"../PhantomCamera2D"

func _ready() -> void:
	signalBus.onLevelReady.connect(setPlayer)
	signalBus.startEditMode.connect(resetCamera)
	#signalBus.connect("playLevel",resetCamera)
	signalBus.startPlayMode.connect(playMode)
	signalBus.loadedLevel.connect(refindPlayer)

func setPlayer(_lvl):
	player = globalEditor.player

func _physics_process(_delta: float) -> void:
	if !globalEditor.isEditing:
		#position = position.lerp(player.position,0.3) 
		#if player:
		position = player.position
		phantomCamera.set_follow_offset(player.velocity/8)
	else:
		if !globalEditor.popupIsOpen:
			transLateCamera(Input.get_vector("camLeft","camRight","camUp","camDown")*25)

func transLateCamera(direction: Vector2):
	#phantomCamera.position += direction
	phantomCamera.set_follow_offset(phantomCamera.get_follow_offset()+direction)
	
#func tweenToPlayer():
	#var resetCamTween = create_tween()
	#resetCamTween.set_trans(Tween.TRANS_CUBIC)
	#resetCamTween.set_ease(Tween.EASE_OUT)
	#resetCamTween.tween_property(self,"position",globalEditor.playerProperties.position ,0.3)

func resetCamera():
	phantomCamera.set_follow_offset(Vector2.ZERO)
	#phantomCamera.follow_mode = phantomCamera.FollowMode.NONE
	#phantomCamera.follow_target = null
	player = globalEditor.player
	#tweenToPlayer()
	#position = player.position
	#position = globalEditor.playerProperties.position
	#phantomCamera.position = globalEditor.playerProperties.position
func playMode():
	phantomCamera.set_follow_offset(Vector2.ZERO)
	phantomCamera.follow_target = player
	#phantomCamera.follow_mode = phantomCamera.FollowMode.SIMPLE

func refindPlayer():
	player = globalEditor.player
	phantomCamera.set_follow_target(player)
