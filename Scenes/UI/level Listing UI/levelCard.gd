class_name LevelCard extends Control

var levelDict:Dictionary
#@onready var nameLabel: RichTextLabel = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/nameLabel
#@onready var idLabel: RichTextLabel = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/idLabel
#@onready var authorLabel: RichTextLabel = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/authorLabel
#@onready var playButton: Button = $PanelContainer/MarginContainer/HBoxContainer/playButton
@export var nameLabel: RichTextLabel
@export var idLabel: RichTextLabel 
@export var authorLabel: RichTextLabel
@export var playButton: Button
@export var moreDetailsButton: Button


func _ready() -> void:
	playButton.pressed.connect(openLevel)
	if moreDetailsButton: moreDetailsButton.pressed.connect(showMoreDetails)
	if levelDict: updateLabels()

##updates labels for level name, artist ID, and level ID
func updateLabels():
	nameLabel.text = str(levelDict.name)
	idLabel.text = str("Level ID: ",levelDict.id)
	authorLabel.text = str("Artist ID: ",levelDict.artist)

func openLevel():
	signalBus.loadingStarted.emit()
	await authentication.downloadLevel(str(int(levelDict.id)))
	signalBus.loadingStopped.emit()
	signalBus.stopBrowsingLevels.emit()

func showMoreDetails():
	signalBus.showMoreLevelDetails.emit(levelDict)
