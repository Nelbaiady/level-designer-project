class_name SignalBus extends Node

#signals to add a node to the globalEditor when it's ready
@warning_ignore("unused_signal")
signal onLevelReady(level)

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
signal loadedLevel()

#signals for editing properties
@warning_ignore("unused_signal")
signal showPropertiesSidebar()
@warning_ignore("unused_signal")
signal hidePropertiesSidebar()
@warning_ignore("unused_signal")
signal updateProperty(property,value)
@warning_ignore("unused_signal")
signal editingObject(objectName, instanceID)

@warning_ignore("unused_signal")
signal spinboxSpun()
