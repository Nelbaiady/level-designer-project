class_name System extends Node

var undoRedo:UndoRedo = UndoRedo.new()

var fullscreen := false
var wasMaximized := false ##remembers if the window was maximized when it goes to fullscreen so it can go back if the user turns fullscreen back off

var popupIsOpen := false

var isPaused := false

var isUsingController := false

var isWebVersion := OS.has_feature("web")
var isDesktopVersion := OS.has_feature("windows") or OS.has_feature("macos") or OS.has_feature("linuxbsd")
var isUsingTouchControls := DisplayServer.is_touchscreen_available()

var popupStack:int = 0

##Duration of most tweens
const uiTweenTime = 0.3

func _ready() -> void:
	if isDesktopVersion:
		get_window().size = Vector2i(1280,720)
		get_window().move_to_center()
	signalBus.togglePause.connect(togglePause)
	signalBus.genericPopupClosed.connect(func(): popupStack-=1)
	signalBus.genericPopupOpened.connect(
		func(): popupStack+=1)

func togglePause():
	isPaused = !isPaused
	signalBus.pauseToggled.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED or DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED:
			wasMaximized = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			if wasMaximized:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if event.is_action_pressed("pause") and (!popupIsOpen or isPaused==true):
		togglePause()
	if event.is_action_pressed("redo"):
		undoRedo.redo()
	elif event.is_action_pressed("undo"):
		undoRedo.undo()

	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		#account for slight drift
		if event is InputEventJoypadMotion and abs(event.axis_value)<0.1:
			pass
		else:
			var settingChanged:=false
			if !isUsingController: settingChanged = true #the variable will change from what it was, which we need to know so we dont update all icons constantly
			isUsingController = true
			if settingChanged: signalBus.updateControlIcons.emit()#make sure to update controller icons
			if settingChanged: signalBus.inputMethodChanged.emit()#inform other things that the input method changed
	elif event is InputEventKey or event is InputEventMouseMotion:
		var settingChanged:=false
		if isUsingController: settingChanged = true #the variable will change from what it was, which we need to know so we dont update all icons constantly
		isUsingController = false
		if settingChanged: signalBus.updateControlIcons.emit()#make sure to update controller icons
		if settingChanged: signalBus.inputMethodChanged.emit()#inform other things that the input method changed

##shorter way to create a tween
func basicTween(object:Node, property:String,value, time=system.uiTweenTime,tweenEase:Tween.EaseType=Tween.EASE_IN,tweenTrans:Tween.TransitionType=Tween.TRANS_CUBIC):
	var tween = create_tween()
	tween.set_trans(tweenTrans)
	tween.set_ease(tweenEase)
	tween.tween_property(object,property,value,time)

func _physics_process(_delta: float) -> void:
	if !popupIsOpen and (globalEditor.popupIsOpen or popupStack > 0):
		popupIsOpen = true
		signalBus.popupsOpened.emit()
	elif popupIsOpen and !(globalEditor.popupIsOpen or popupStack > 0):
		popupIsOpen = false
		signalBus.popupsClosed.emit()
		
	#popupIsOpen = globalEditor.popupIsOpen or popupStack > 0
