class_name LevelBrowser extends GenericPopup

const LEVEL_CARD = preload("uid://cjicoi1w8hc3s")

@export var levelCards: VBoxContainer
#@export var popupParent:GenericPopup

func _ready():
	super()
	#if !popupParent and get_parent() is GenericPopup: popupParent = get_parent()
	signalBus.startBrowsingLevels.connect(populateLevels)
	#signalBus.stopBrowsingLevels.connect(_on_close_button_pressed)
	#popupParent.closed.connect(clearLevelList)
	signalBus.stopBrowsingLevels.connect(closePopup)
	closed.connect(clearLevelList)
	
	
func populateLevels():
	openPopup()
	signalBus.loadingStarted.emit()
	var levels = await authentication.rpcRequest({},"getalllevels")
	signalBus.loadingStopped.emit()
	for i in JSON.parse_string(levels[3].get_string_from_utf8()):
		var levelCard:LevelCard = LEVEL_CARD.instantiate()
		levelCard.levelDict = i
		levelCards.add_child(levelCard)

func clearLevelList() -> void:
	#popupParent.close.emit()
	#globalEditor.levelBrowsingPopupIsOpen = false
	for i in levelCards.get_children():
		i.queue_free()
