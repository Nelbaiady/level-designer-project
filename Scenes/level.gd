class_name Level extends Node2D

var rooms = [{"backgroundColor":Color.FLORAL_WHITE,"layers":{0:{"tiles":{},"objects":{}} ,1:{"tiles":{},"objects":{}}}  }]
var layers:Dictionary[int,LevelLayer]
func _ready() -> void:
#	find all layers and store them in the layers dictionary
	for i in get_children():
		if i is LevelLayer:
			layers[i.index] = i 
	signalBus.onLevelReady.emit(self)

func getCurrentRoomDict():
	return rooms[globalEditor.currentRoom]
func getCurrentLayerDict():
	return rooms[globalEditor.currentRoom]["layers"][globalEditor.currentLayer]
