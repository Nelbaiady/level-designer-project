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

var inputVector = Vector2.ZERO

func _ready() -> void:
	signalBus.onLevelReady.connect(setPlayer)
	signalBus.startEditMode.connect(editMode)
	signalBus.startPlayMode.connect(playMode)
	signalBus.loadedLevel.connect(refindPlayer)
	signalBus.shimmyCamera.connect(shimmyOver)
	
	#phantomCamera.dead_zone_reached.connect(_on_dead_zone_changed)

##moves the camera slightly to forcefully update scrollScale
func shimmyOver():
	phantomCamera.position+=Vector2.RIGHT*0.5
	await get_tree().process_frame
	phantomCamera.position-=Vector2.RIGHT*0.5
	
func setPlayer(_lvl):
	refindPlayer()
	#for some reason the below three lines in that exact order fix the cursor jitter on startup. no idea why.
	phantomCamera.follow_mode = phantomCamera.FollowMode.FRAMED
	phantomCamera.set_follow_target(player)
	phantomCamera.follow_mode = phantomCamera.FollowMode.NONE

func _physics_process(_delta: float) -> void:
	if globalEditor.popupIsOpen:
		inputVector = Vector2.ZERO
		inputPosX = 0
		inputNegX = 0
		inputPosY = 0
		inputNegY = 0
	if !globalEditor.isEditing:
		#phantomCamera.set_follow_offset((player.velocity/5))#.limit_length(400))
		pass
	else:
		if !globalEditor.popupIsOpen:
			transLateCamera(inputVector*25)

#Input vector needs to be handled using unhandled input in case the user is typing into a textbox
var inputPosX = 0
var inputNegX = 0
var inputPosY = 0
var inputNegY = 0
func _unhandled_input(event: InputEvent) -> void:
	if !globalEditor.popupIsOpen and globalEditor.isEditing:
		if event.is_action_pressed("LstickR"):
			inputPosX = Input.get_action_strength("LstickR")
		if event.is_action_released("LstickR"):
			inputPosX = 0
			
		if event.is_action_pressed("LstickL"):
			inputNegX = Input.get_action_strength("LstickL")
		if event.is_action_released("LstickL"):
			inputNegX = 0
		
		if event.is_action_pressed("LstickU"):
			inputPosY = Input.get_action_strength("LstickU")
		if event.is_action_released("LstickU"):
			inputPosY = 0
			
		if event.is_action_pressed("LstickD"):
			inputNegY = Input.get_action_strength("LstickD")
		if event.is_action_released("LstickD"):
			inputNegY = 0
		inputVector = Vector2(inputPosX-inputNegX,inputNegY-inputPosY)

##for movement in edit mode
func transLateCamera(direction: Vector2):
	phantomCamera.position += direction
	
func editMode():
	inputPosX = 0
	inputNegX = 0
	inputPosY = 0
	inputNegY = 0
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
