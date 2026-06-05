extends Panel

@export var loadingLabel:Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	signalBus.loadingStarted.connect(showLoading)
	signalBus.altLoadingStarted.connect(showLoading)
	signalBus.loadingStopped.connect(hideLoading)
	
func showLoading(text="loading"):
	loadingLabel.text=text
	visible = true
func hideLoading():
	visible = false
