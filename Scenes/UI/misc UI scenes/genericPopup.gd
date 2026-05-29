class_name GenericPopup extends Panel

@export var closeButton:Button

var isOpen:=false
signal open##tells this popup to appear
signal close##tells this popup to close
signal opened##signals to other nodes that this popup has opened
signal closed##signals to other nodes that this popup has closed
func _ready():
	closeButton.pressed.connect(closePopup)
	open.connect(openPopup)
	close.connect(closePopup)
	if visible: 
		signalBus.genericPopupOpened.emit()
	
	#allow this closeButton to be replaced
	if closeButton != $closeButton: $closeButton.hide()

func closePopup() -> void:
	isOpen = false
	visible = false
	closed.emit()
	signalBus.genericPopupClosed.emit()
	
func openPopup() -> void:
	isOpen = true
	visible = true
	opened.emit()
	signalBus.genericPopupOpened.emit()
