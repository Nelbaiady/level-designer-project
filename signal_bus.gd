class_name SignalBus extends Node

#signals to add a node to the globalEditor when it's ready
@warning_ignore("unused_signal")
signal onLevelReady(level)##called when a level is ready in the scene tree
@warning_ignore("unused_signal")
signal loadedLevel()##called when a level has been loaded from a JSON
@warning_ignore("unused_signal")
signal startSavingLevel()##sends a signal to open the file dialog for level saving
@warning_ignore("unused_signal")
signal startLoadingLevel()##sends a signal to open the file dialog for level loading
@warning_ignore("unused_signal")
signal downloadLevelFile()##sends a signal to download the level file

#signals that play during gameplay
@warning_ignore("unused_signal")
signal updatePlayerHealth()##lets the ui know that player health has changed

@warning_ignore("unused_signal")
signal uploadCurrentLevel()##called when a level has been loaded from a JSON
@warning_ignore("unused_signal")
signal loadLevel(data)##called when a level has been loaded from a JSON

#editing tools
@warning_ignore("unused_signal")
signal setCurrentTool(tool)
@warning_ignore("unused_signal")
signal eraseObject()
@warning_ignore("unused_signal")
signal eraseSpecificObject(id:int)
@warning_ignore("unused_signal")
signal placeObjectSignal(instanceID, object, properties)

#game mode states
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
signal populatePropertiesUI(object) ##signal to fill the propertiesUI with an object's properties
@warning_ignore("unused_signal")
signal updateProperty(property,value) ##this signal is connected to the object that is being edited and tells the object to set the given property (code name) to the given value
@warning_ignore("unused_signal")
signal editingObject(objectName, instanceID)

#signals for layer property editing
@warning_ignore("unused_signal")
signal populateLayersUI(layerPropertiesHandler)
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

#specific stuff
@warning_ignore("unused_signal")
signal spinboxSpun()##when a spinbox with a specific script is spin, it emits this
@warning_ignore("unused_signal")
signal shimmyCamera()##when a layer's scroll_scale property changes, make sure the camera moves a slight bit to refresh the visual

#popup prompts
@warning_ignore("unused_signal")
signal startTextEditPopup(prompt)##tells the text edit popup to appear and prepare to send something back. parameters: prompt
@warning_ignore("unused_signal")
signal startBinaryChoicePopup(prompt,option1,option2)##tells the binary choice popup to appear and prepare to send something back. parameters: prompt, option1, option2
@warning_ignore("unused_signal")
signal startTextPopup(text)##regular text popup without input
@warning_ignore("unused_signal")
signal startSignInPopup()##popup for signing in
@warning_ignore("unused_signal")
signal startSignUpPopup()##popup for signing up
@warning_ignore("unused_signal")
signal endTextPopup(text,isCancelled:bool)##notifies that the popup was closed. parameters: text, isCancelled

#pause menu
@warning_ignore("unused_signal")
signal pauseToggled()##emits to indicate that the game paused or unpaused
@warning_ignore("unused_signal")
signal togglePause()##emits to order a pause or unpause

#other menus
@warning_ignore("unused_signal")
signal startBrowsingLevels()##opens and populates the level browsing menu
@warning_ignore("unused_signal")
signal stopBrowsingLevels()##closes and empties the level browsing menu
@warning_ignore("unused_signal")
signal updateControlIcons()##when swapping between keyboard and controller
@warning_ignore("unused_signal")
signal inputMethodChanged()##when swapping between keyboard and controller
@warning_ignore("unused_signal")
signal controlIconsUpdated()##sent after icons were changed


#authentication
@warning_ignore("unused_signal")
signal signedIn()##emits whenever the player is signed in
@warning_ignore("unused_signal")
signal signedOut()##emits whenever the player is signed out
@warning_ignore("unused_signal")
signal signInStatusUpdated()##emits after user data is collected after sign in or out
