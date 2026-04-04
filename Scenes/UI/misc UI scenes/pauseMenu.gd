class_name PauseMenu extends Panel


@export var userInfoText: RichTextLabel #= $PauseVBoxContainer/userInfoText
@export var loginButton: Button #= $PauseVBoxContainer/Login/LoginButton

@export var editModePauseVBoxContainer: VBoxContainer
@export var playModePauseVBoxContainer: VBoxContainer

#button containers
@export var downloadLevel: MarginContainer# = $PauseVBoxContainer/DownloadLevel
@export var login: MarginContainer# = $PauseVBoxContainer/Login
@export var uploadLevel: MarginContainer# = $PauseVBoxContainer/uploadLevel

func _ready():
	downloadLevel.visible = OS.has_feature("web")
	#login.visible = !OS.has_feature("web")
	#uploadLevel.visible = !OS.has_feature("web")
	#DISABLE UNTIL A LOGIN SOLUTION IS FOUND
	login.visible = false
	uploadLevel.visible = false
	
	signalBus.pauseToggled.connect(pauseCheck)
	signalBus.signedIn.connect(setSignInButtonTrue)
	signalBus.signedOut.connect(setSignInButtonFalse)
	signalBus.signInStatusUpdated.connect(updateUserInfo)
	
	signalBus.startEditMode.connect(showEditModeMenu)
	signalBus.startPlayMode.connect(showPlayModeMenu)

func showEditModeMenu():
	editModePauseVBoxContainer.visible = true
	playModePauseVBoxContainer.visible = false
func showPlayModeMenu():
	playModePauseVBoxContainer.visible = true
	editModePauseVBoxContainer.visible = false

func updateUserInfo():
	if authentication.isSignedIn:
		var username = authentication.user.username
		var id = authentication.user.id
		#print(authentication.sessionCache.user)
		userInfoText.text = str("Signed in as ",username,'\n','User ID: ',id)
	else:
		userInfoText.text = ""

	
func pauseCheck():
	if system.isPaused:
		pause()
	else:
		unPause()
func pause():
	visible = true
func unPause():
	visible = false

func setSignInButtonTrue():
	authentication.isSignedIn = true
	loginButton.text = "Sign Out"
func setSignInButtonFalse():
	loginButton.text = "Sign In"
	authentication.isSignedIn = false

func _on_unpause_button_pressed() -> void:
	signalBus.togglePause.emit()


func _on_login_button_pressed() -> void:
	signalBus.togglePause.emit()
	if authentication.isSignedIn:
		authentication.signOut()
	else:
		authentication.signInWithGoogle()

func _on_upload_button_pressed() -> void:
	signalBus.togglePause.emit()
	signalBus.uploadCurrentLevel.emit()

func _on_browse_levels_button_pressed() -> void:
	signalBus.togglePause.emit()
	signalBus.startBrowsingLevels.emit()

func _on_load_level_by_id_button_pressed() -> void:
	signalBus.togglePause.emit()
	signalBus.startTextEditPopup.emit("insert level ID")
	var reply = await signalBus.endTextEditPopup
	var correct:bool = reply[0].is_valid_int()
	var cancelled:bool = reply[1]
	while !cancelled and !correct:
		signalBus.startTextEditPopup.emit("Not a valid number. \nInsert level ID")
		reply = await signalBus.endTextEditPopup
		correct = false
		cancelled = reply[1]
		correct = reply[0].is_valid_int()
	if !cancelled and correct:
		authentication.downloadLevel(reply[0])

func _on_pause_button_pressed() -> void:
	signalBus.togglePause.emit()

func _on_download_level_button_pressed() -> void:
	signalBus.togglePause.emit()
	signalBus.downloadLevelFile.emit()

func _on_save_level_button_pressed() -> void:
	signalBus.togglePause.emit()
	signalBus.startSavingLevel.emit()

func _on_load_level_button_pressed() -> void:
	signalBus.togglePause.emit()
	signalBus.startLoadingLevel.emit()


func _on_exit_play_mode_button_pressed() -> void:
	signalBus.togglePause.emit()
	signalBus.startEditMode.emit()
