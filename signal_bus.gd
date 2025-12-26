extends Node
@warning_ignore("unused_signal")
signal setCurrentTool(tool)
@warning_ignore("unused_signal")
signal eraseObject()
@warning_ignore("unused_signal")
signal placeObjectSignal(instanceID, object, properties)

#switch from play mode to edit mode
@warning_ignore("unused_signal")
signal resetStage()
#switch from edit mode to play mode
@warning_ignore("unused_signal")
signal playLevel()
#destroy the player and recreate them to reset properties
@warning_ignore("unused_signal")
signal reloadPlayer()

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
