class_name textEditPopup extends Control

@export var lineEdit: LineEdit
@export var emailLineEdit: LineEdit 
@export var passwordLineEdit: LineEdit 

@export var label: Label

#need these containers to change their visibility
@export var cancelButtonContainer: MarginContainer
@export var cancelButton: Button
@export var confirmButton: Button
@export var lineEditContainer: MarginContainer
@export var authFieldsContainer: VBoxContainer
@export var errorLabel: Label

##indicates if the user is signing in so that the popup doesnt always close on confirm
var isSigningIn:=false
##indicates if the user is signing up so that the popup doesnt always close on confirm
var isSigningUp:=false

##usage example
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("9"):
		#signalBus.startTextEditPopup.emit('what a doozy eh?')
		#var inputText = await signalBus.endTextPopup
		#print(inputText[0])

func _ready() -> void:
	signalBus.startTextEditPopup.connect(startInputPopup)
	signalBus.startTextPopup.connect(startInfoPopup)
	signalBus.startBinaryChoicePopup.connect(startBinaryChoicePopup)
	signalBus.startSignInPopup.connect(startSignInPopup)
	signalBus.startSignUpPopup.connect(startSignUpPopup)
	authentication.authError.connect(setErrorText)

func setErrorText(error):
	if emailLineEdit.text=="":
		error = ""
		error+="Missing email\n"
	if passwordLineEdit.text=="":
		if error != "Missing email\n": error = "" 
		error+="Missing password"
	errorLabel.text=error
	
##displays the popup and sets everything to its default
func showFreshPopup():
	isSigningIn=false
	isSigningUp=false
	cancelButtonContainer.visible = false
	lineEditContainer.visible = false
	authFieldsContainer.visible = false
	cancelButton.text="Cancel"
	confirmButton.text="Confirm"
	label.text=""
	errorLabel.text=""
	lineEdit.clear()
	emailLineEdit.clear()
	passwordLineEdit.clear()
	visible = true
	globalEditor.textPopupIsOpen = true

##Just text and a confirm button as a notification.
func startInfoPopup(prompt:String):
	showFreshPopup()
	#withInput = false
	label.text = prompt

##popup with two options. Parameters: prompt, option1, option2
func startBinaryChoicePopup(prompt:String="Do you want to go ahead",option1:String="Cancel",option2:String="Confirm"):
	showFreshPopup()
	cancelButtonContainer.visible = true
	cancelButton.text=option1
	confirmButton.text=option2
	label.text = prompt
	#withInput = false

##A popup with text input, and cancel button, and a confirm button. Parameters: Prompt.
func startInputPopup(prompt:String):
	showFreshPopup()
	#withInput = true
	lineEditContainer.visible = true
	cancelButtonContainer.visible = true
	label.text = prompt

func startSignInPopup():
	showFreshPopup()
	isSigningIn = true
	authFieldsContainer.visible = true
	cancelButtonContainer.visible = true
	label.text="Sign In"
func startSignUpPopup():
	showFreshPopup()
	isSigningUp = true
	authFieldsContainer.visible = true
	cancelButtonContainer.visible = true
	label.text="Sign Up"

func endInputPopup(isConfirmed:bool):
	visible = false
	globalEditor.textPopupIsOpen = false
	signalBus.endTextPopup.emit(lineEdit.text,isConfirmed)
	lineEdit.clear()

func _on_confirm_button_pressed() -> void:
	if isSigningIn:
		var response = await authentication.signIn(emailLineEdit.text,passwordLineEdit.text)
		if response==200:
			signalBus.startTextPopup.emit("Signed in successfully")
			#endInputPopup(true)
			#passwordLineEdit.clear()
	elif isSigningUp:
		var _response = await authentication.signUp(emailLineEdit.text,passwordLineEdit.text)
		#if response==200:
			#endInputPopup(true)
			#passwordLineEdit.clear()
	else:
		endInputPopup(true)

func _on_cancel_button_pressed() -> void:
	endInputPopup(false)
