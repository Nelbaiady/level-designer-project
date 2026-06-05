class_name LevelDetailsPopup extends LevelCard

@export var parentPopup:GenericPopup
@export var submitReviewButton:Button
@export var foldableContainer:FoldableContainer
@export var reviewTextEdit:TextEdit

@export var ratingDisplays:Array[StarBar]
@export var ratingInputs:Array[StarBar]

var levelDetailsDict:Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	signalBus.showMoreLevelDetails.connect(showLevelDetails)
	signalBus.stopBrowsingLevels.connect(parentPopup.closePopup)
	submitReviewButton.pressed.connect(submitReview)
	

func submitReview():
	if !authentication.isSignedIn or authentication.user=={}:
		signalBus.startTextPopup.emit("Sign in to submit a review")
		return
	var params = {"level_id":int(levelDict["id"]),"user_id":authentication.user["id"]
	,"controls":int(ratingInputs[0].slider.value)
	,"visuals":int(ratingInputs[1].slider.value)
	,"difficulty_curve":int(ratingInputs[2].slider.value)
	,"learning_curve":int(ratingInputs[3].slider.value)
	,"creativity":int(ratingInputs[4].slider.value)
	,"review":reviewTextEdit.text}

	var msg = await authentication.rpcRequest(params,"addReview")
	if msg[1] == 204:
		reviewTextEdit.clear()
		for reviewSlider in ratingInputs:
			reviewSlider.setStarBarValue(10)
		foldableContainer.fold()
		signalBus.startTextPopup.emit("Review published successfully!")
	else:
		signalBus.startTextPopup.emit(str("Something went wrong:\n",msg[3].get_string_from_utf8()))
		
	#print(msg[1])
	#print(msg[3].get_string_from_utf8())


func showLevelDetails(newLevelDict):
	parentPopup.openPopup()
	levelDict = newLevelDict
	updateDetailedLabels()

#updates level information in the card but with more details than the base updateLabels function
func updateDetailedLabels():
	updateLabels()
