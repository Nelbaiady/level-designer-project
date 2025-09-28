extends Node2D

const PLACEHOLDER = preload("uid://fowyuhehhfg2")
@onready var level: Node2D = $"../Level"
@onready var file_dialog: FileDialog = $"../FileDialog"
var popupIsOpen = false
var isSaving = false

func _physics_process(delta: float) -> void:
	if !popupIsOpen:
		#place an object
		if Input.is_action_just_pressed("mouseClickLeft"):
			print("hey, you just clicked at ", get_local_mouse_position())
			var placeholderObject = PLACEHOLDER.instantiate()
			level.add_child(placeholderObject)
			placeholderObject.owner = level
			placeholderObject.global_position = get_local_mouse_position()
			
		#clear all of the editor's children
		if Input.is_action_just_pressed("clear"):
			for i in level.get_children():
				i.queue_free()
			print('cleared and also delta is ',delta)
		
	if Input.is_action_just_pressed("save"):
		popupIsOpen = true
		isSaving = true
		file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE 
		file_dialog.show()
		
	if Input.is_action_just_pressed("load"):
		popupIsOpen = true
		isSaving = false
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_dialog.show()
		

func _on_file_dialog_confirmed() -> void:
	print('confirmed')
	popupIsOpen = false
	if isSaving:
		var levelToSave : PackedScene = PackedScene.new()
		levelToSave.pack(level)
		ResourceSaver.save(levelToSave, file_dialog.current_path +".tscn")
	else:
		print('loading level')
		var levelToLoad : PackedScene = PackedScene.new()
		levelToLoad = ResourceLoader.load(file_dialog.current_path)
		var loadedLevel = levelToLoad.instantiate()
		get_parent().remove_child(level)
		level.queue_free()
		get_parent().add_child(loadedLevel)
		level = loadedLevel
		level.position = Vector2(20,40)


func _on_file_dialog_canceled() -> void:
	popupIsOpen = false
