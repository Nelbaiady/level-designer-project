class_name SignalBus extends Node

#signals to add a node to the globalEditor when it's ready
@warning_ignore("unused_signal")
signal onLevelReady(level)##called when a level is ready in the scene tree
@warning_ignore("unused_signal")
signal loadedLevel()##called when a level has been loaded from a JSON

@warning_ignore("unused_signal")
signal uploadCurrentLevel()##called when a level has been loaded from a JSON
@warning_ignore("unused_signal")
signal loadLevel(data)##called when a level has been loaded from a JSON


@warning_ignore("unused_signal")
signal setCurrentTool(tool)
@warning_ignore("unused_signal")
signal eraseObject()
@warning_ignore("unused_signal")
signal placeObjectSignal(instanceID, object, properties)

@warning_ignore("unused_signal")
signal startEditMode()##when switching to edit mode
@warning_ignore("unused_signal")
signal startPlayMode()##when switching to play mode
@warning_ignore("unused_signal")
signal reloadPlayer()##destroy the player and recreate them to reset properties. This emits after a level has loaded.


#signals for editing properties
@warning_ignore("unused_signal")
signal showPropertiesSidebar()
@warning_ignore("unused_signal")
signal hidePropertiesSidebar()
@warning_ignore("unused_signal")
signal populatePropertiesUI(object)
@warning_ignore("unused_signal")
signal updateProperty(property,value)
@warning_ignore("unused_signal")
signal editingObject(objectName, instanceID)

#signals for layer property editing
@warning_ignore("unused_signal")
signal populateLayersUI(propertiesHandler)
@warning_ignore("unused_signal")
signal updateLayerProperty(property, value, layerID)##signal for editing layer properties
@warning_ignore("unused_signal")
signal selectLayer(layerID)##signal for selecting layer
@warning_ignore("unused_signal")
signal moveLayerUp(layerID)##signal for moving a layer up
@warning_ignore("unused_signal")
signal moveLayerDown(layerID)##signal for moving a layer down
@warning_ignore("unused_signal")
signal addLayerAbove(layerID)##signal for adding a new layer above
@warning_ignore("unused_signal")
signal addLayerBelow(layerID)##signal for adding a new layer below
@warning_ignore("unused_signal")
signal deleteLayer(layerID)##signal for deleting a layer
@warning_ignore("unused_signal")
signal updateLayerUI()##signal for changing layer

@warning_ignore("unused_signal")
signal spinboxSpun()##when a spinbox with a specific script is spin, it emits this

@warning_ignore("unused_signal")
signal startTextEditPopup(prompt)##tells the text edit popup to appear and prepare to send something back
@warning_ignore("unused_signal")
signal endTextEditPopup(text,isCancelled:bool)##tells the text edit popup to appear and prepare to send something back
@warning_ignore("unused_signal")
signal startTextPopup(text)##regular text popup without input

@warning_ignore("unused_signal")
signal pauseToggled()##emits to indicate that the game paused or unpaused
@warning_ignore("unused_signal")
signal togglePause()##emits to order a pause or unpause
