extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	signalBus.loadingStarted.connect(showLoading)
	signalBus.loadingStopped.connect(hideLoading)
	
func showLoading():
	visible = true
func hideLoading():
	visible = false
