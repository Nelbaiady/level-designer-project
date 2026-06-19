class_name PasswordLineEdit extends LineEdit
const EYECON = preload("uid://6gm883uevw3b")
const CROSSED_EYECON = preload("uid://cfjob40akxrhm")
@export var password_hide_toggler: TextureButton

signal submit()

func _ready() -> void:
	password_hide_toggler.toggled.connect(toggleHidePassword)
	
func toggleHidePassword(on:bool):
	secret = on

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_submit"):
		submit.emit()
