extends Node

var isEditing:bool = true
var popupIsOpen:bool = false
signal resetStage()
var gridSize:int = 64

var levelStruct : Dictionary = { "tiles": [], "objects": []}
