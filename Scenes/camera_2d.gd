class_name GameplayCamera extends Camera2D

@onready var player:Player

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
	signalBus.startEditMode.connect(editMode)
	signalBus.startPlayMode.connect(playMode)
	signalBus.loadedLevel.connect(refindPlayer)
	
	phantomCamera.dead_zone_reached.connect(_on_dead_zone_changed)

func setPlayer(_lvl):
	refindPlayer()
	#for some reason the below three lines in that exact order fix the cursor jitter on startup. no idea why.
	phantomCamera.follow_mode = phantomCamera.FollowMode.FRAMED
	phantomCamera.set_follow_target(player)
	phantomCamera.follow_mode = phantomCamera.FollowMode.NONE

func _on_dead_zone_changed(zoneVector):
	if !globalEditor.isEditing:
		phantomCamera.set_follow_offset(((player.velocity/5) * abs(zoneVector)).limit_length(500))
func _physics_process(_delta: float) -> void:
	if !globalEditor.isEditing:
		#phantomCamera.set_follow_offset((player.velocity/5))#.limit_length(400))
		pass
	else:
		if !globalEditor.popupIsOpen:
			transLateCamera(Input.get_vector("LstickL","LstickR","LstickU","LstickD")*25)

func transLateCamera(direction: Vector2):
	phantomCamera.position += direction
	
func editMode():
	phantomCamera.follow_mode = phantomCamera.FollowMode.NONE
	phantomCamera.set_follow_offset(Vector2.ZERO)
	player = globalEditor.player
	var camTween = create_tween()
	camTween.set_trans(Tween.TRANS_CUBIC)
	camTween.set_ease(Tween.EASE_OUT)
	camTween.tween_property(phantomCamera,"position",globalEditor.playerProperties.position,0.1)

func playMode():
	phantomCamera.follow_mode = phantomCamera.FollowMode.FRAMED
	phantomCamera.set_follow_target(player)
	phantomCamera.set_follow_offset(Vector2.ZERO)

func refindPlayer():
	player = globalEditor.player
	phantomCamera.set_follow_target(player)
