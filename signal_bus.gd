class_name SignalBus extends Node

#signals to add a node to the globalEditor when it's ready
@warning_ignore("unused_signal")
signal onLevelReady(level)##called when a level is ready in the scene tree

@warning_ignore("unused_signal")
signal setCurrentTool(tool)
@warning_ignore("unused_signal")
signal eraseObject()
@warning_ignore("unused_signal")
signal placeObjectSignal(instanceID, object, properties)

#switch from play mode to edit mode
@warning_ignore("unused_signal")
signal startEditMode()
#switch from edit mode to play mode
@warning_ignore("unused_signal")
signal startPlayMode()
#destroy the player and recreate them to reset properties
@warning_ignore("unused_signal")
signal reloadPlayer()
#this emits after a level has loaded
@warning_ignore("unused_signal")
signal loadedLevel()##called when a level has been loaded from a JSON

#signals for editing properties
@warning_ignore("unused_signal")
signal showPropertiesSidebar()
@warning_ignore("unused_signal")
signal hidePropertiesSidebar()
@warning_ignore("unused_signal")
signal updateProperty(property,value)
@warning_ignore("unused_signal")
signal editingObject(objectName, instanceID)

#signals for layer property editing
@warning_ignore("unused_signal")
signal updateLayerProperty(property, value, layerID)##signal for editing layer properties
@warning_ignore("unused_signal")
signal selectLayer(layerID)##signal for changing layer

@warning_ignore("unused_signal")
signal spinboxSpun()
