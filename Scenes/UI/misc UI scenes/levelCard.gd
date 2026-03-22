class_name LevelCard extends Control

var levelDict:Dictionary
@onready var nameLabel: RichTextLabel = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/nameLabel
@onready var idLabel: RichTextLabel = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/idLabel
@onready var authorLabel: RichTextLabel = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/authorLabel
@onready var playButton: Button = $PanelContainer/MarginContainer/HBoxContainer/playButton

func _ready() -> void:
	nameLabel.text = str(levelDict.name)
	idLabel.text = str("Level ID: ",levelDict.id)
	authorLabel.text = str("Artist ID: ",levelDict.artist)


func _on_play_button_pressed() -> void:
	authentication.downloadLevel(str(int(levelDict.id)))
	signalBus.stopBrowsingLevels.emit()
