class_name SaveLoadManager extends Node
@onready var file_dialog: FileDialog = $"../FileDialog"
#@onready var tileMap: TileMapLayer = $"../Level/Layer0/TileMapLayer"

var isSaving = false
func _ready() -> void:
	authentication.saveLoadManager = self
	signalBus.loadLevel.connect(loadLevel)
	signalBus.startSavingLevel.connect(startSavingLevel)
	signalBus.startLoadingLevel.connect(startLoadingLevel)
	signalBus.downloadLevelFile.connect(downloadLevelFile)

#remove this
#func _input(event: InputEvent) -> void:
	#if globalEditor.isEditing:
		#if event.is_action_pressed("save"):
			#if OS.has_feature("web"):
				#downloadLevelFile()
			#else:
				#startSavingLevel()
		#if event.is_action_pressed("load"):
			#startLoadingLevel()

##opens the file dialog and starts the process of saving a level
func startSavingLevel():
	globalEditor.saveLoadPopupIsOpen = true
	isSaving = true
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE 
	file_dialog.show()
	##opens the file dialog and starts the process of loading a level
func startLoadingLevel():
	globalEditor.saveLoadPopupIsOpen = true
	isSaving = false
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.show()
func downloadLevelFile():
	if OS.has_feature("web"):
		var levelSaveStruct : Dictionary = parseLevelToJson()
		print(JSON.stringify(levelSaveStruct))
		JavaScriptBridge.eval("""
			(function() {
				const content = JSON.stringify(%s);
				const blob = new Blob([content], { type: 'application/json' });
				const url = URL.createObjectURL(blob);
				const a = document.createElement('a');
				a.href = url;
				a.download = 'level.json';
				a.click();
				URL.revokeObjectURL(url);
			})();
		""" % levelSaveStruct)
	else:
		signalBus.startTextPopup.emit("You cannot download level files unless you are on a browser.")

func _on_file_dialog_file_selected(path: String) -> void:
	globalEditor.saveLoadPopupIsOpen = false
	if isSaving:
		#saveLevel(file_dialog.current_path)
		saveLevel(path)
	else:
		#loadLevel(file_dialog.current_path)
		loadLevel(path)

func _on_file_dialog_canceled() -> void:
	globalEditor.saveLoadPopupIsOpen = false

func saveLevel(path):
	#REFERENCE: https://godotforums.org/d/35977-how-do-i-save-a-tileset-in-a-building-game/2
	var saveFile = FileAccess.open(path+".json", FileAccess.WRITE)
	if(FileAccess.get_open_error() != OK):
		return false
	var levelSaveStruct : Dictionary = parseLevelToJson()
	saveFile.store_string(JSON.stringify(levelSaveStruct))

func parseLevelToJson():
	#Exemples for reference
	#var rooms = [{"backgroundColor":Color.FLORAL_WHITE,"layers":{0:{"tiles":{},"objects":{}} ,1:{"tiles":{},"objects":{}}}  }]
	#var levelSaveStruct : Dictionary = {"rooms": [{"layers":{0:{"tiles": [], "objects": []}}}], "playerProperties":{}}
	var levelSaveStruct = {"rooms": [ ],"playerProperties":{}}
	for roomIndex in range(len(globalEditor.level.rooms)):
		levelSaveStruct["rooms"].append( {"layers":{}} )#{"tiles": [], "objects": []} )
		for layerIndex in globalEditor.level.rooms[roomIndex]["layers"]:
			levelSaveStruct["rooms"][roomIndex]["layers"][layerIndex]={"tiles": [], "objects": []}
			var layer = globalEditor.level.rooms[roomIndex]["layers"][layerIndex]
			var tileMap = globalEditor.level.layers[layerIndex].tileMap
			#ADD EVERYTHING TO THE LEVEL STRUCT
			for cellPos in tileMap.get_used_cells():
				##var cellPos = Vector2i(x, y)
				var pos = [cellPos.x,cellPos.y]
				var coords = [tileMap.get_cell_atlas_coords(cellPos).x,tileMap.get_cell_atlas_coords(cellPos).y]
				var source : int = tileMap.get_cell_source_id(cellPos)
				var altTile : int = tileMap.get_cell_alternative_tile(cellPos)
				if source!=-1:
					levelSaveStruct["rooms"][roomIndex]["layers"][layerIndex].tiles.append( { "pos": pos, "atlasCoords": coords, "sourceID": source, "altTile": altTile } )
			for i in layer["objects"]:
				var currentSavingObject = layer["objects"][i]#globalEditor.objectsHash[i]
				levelSaveStruct["rooms"][roomIndex]["layers"][layerIndex]["objects"].append({"instanceID":i,"rosterID":currentSavingObject.rosterID,"properties":var_to_str(currentSavingObject.properties) })
			levelSaveStruct["rooms"][roomIndex]["layers"][layerIndex]["layerProperties"]=var_to_str(globalEditor.level.rooms[roomIndex]["layers"][layerIndex]["layerProperties"])
			levelSaveStruct["objectInstancesCount"] = globalEditor.objectInstancesCount
	levelSaveStruct.playerProperties = var_to_str(globalEditor.playerProperties)
	return levelSaveStruct

func loadLevel(data):
	var loadedData : Dictionary
	if typeof(data)==TYPE_DICTIONARY:
		loadedData=data
	elif typeof(data)==TYPE_STRING:
		var levelFile = FileAccess.open(data, FileAccess.READ)
		#signalBus.reloadPlayer.emit()
		if(FileAccess.get_open_error() != OK):
			printerr("failed to open file: ",data)
			return false
		var jsonData = levelFile.get_as_text()
		var parsedData = JSON.new()
		parsedData.parse(jsonData)
		loadedData = parsedData.get_data()
	else:
		printerr("no valid level data")
	globalEditor.clearLevel()
#	Loop through each layer within each room
	for roomIndex in range(len(globalEditor.level.rooms)):
		#globalEditor.level.rooms[globalEditor.currentRoom]["layers"]={}
		#first pass for instantiating layer nodes
		for stringLayerIndex in loadedData["rooms"][roomIndex]["layers"].keys():
			var layerIndex = int(stringLayerIndex)
			if layerIndex<0:
				globalEditor.level.addLayerBelow(0)
			if layerIndex>0:
				globalEditor.level.addLayerAbove(0)
			
		#second pass for setting properties and placing items
		for stringLayerIndex in loadedData["rooms"][roomIndex]["layers"].keys():
			var layerIndex = int(stringLayerIndex)
			globalEditor.currentLayer = layerIndex
			var tileMap = globalEditor.level.layers[layerIndex].tileMap
			#place tiles for current room and layer
			for i in len( loadedData["rooms"][roomIndex]["layers"][str(layerIndex)]["tiles"] ):
				var currentTile = loadedData["rooms"][roomIndex]["layers"][str(layerIndex)]["tiles"][i]
				tileMap.set_cell(Vector2i(currentTile.pos[0],currentTile.pos[1]) , currentTile.sourceID,Vector2i(currentTile.atlasCoords[0],currentTile.atlasCoords[1]) , currentTile.altTile)
			#place objects for current room and layer
			for i in len( loadedData["rooms"][roomIndex]["layers"][str(layerIndex)]["objects"] ):
				var currentLoadingObject = loadedData["rooms"][roomIndex]["layers"][str(layerIndex)]["objects"][i]
				#globalEditor.placeObject(globalEditor.itemRoster[currentLoadingObject.rosterID],Vector2.ZERO,str_to_var(currentLoadingObject.properties),int(currentLoadingObject.instanceID))
				globalEditor.placeObject(globalEditor.itemRoster[currentLoadingObject.rosterID],Vector2.ZERO,str_to_var(currentLoadingObject.properties))
			#set the layer's properties
			var currentLoadingLayerProperties = str_to_var(loadedData["rooms"][roomIndex]["layers"][str(layerIndex)]["layerProperties"])
			for prop in currentLoadingLayerProperties:
				globalEditor.level.setProperty(prop,currentLoadingLayerProperties[prop],layerIndex)
	#if loadedData.has("objectInstancesCount"):
		#globalEditor.objectInstancesCount = loadedData["objectInstancesCount"]
	globalEditor.currentLayer = 0
	globalEditor.playerProperties = str_to_var( loadedData["playerProperties"] )
	signalBus.loadedLevel.emit()
	signalBus.reloadPlayer.emit()
