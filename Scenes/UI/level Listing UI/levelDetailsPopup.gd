class_name LevelDetailsPopup extends LevelCard

const REVIEW_PANEL = preload("uid://cc0g5proch5e2")

@export var parentPopup:GenericPopup
@export var submitReviewButton:Button
@export var foldableContainer:FoldableContainer
@export var reviewTextEdit:TextEdit
@export var reviewsVBox:VBoxContainer
@export var artistNameLabel:RichTextLabel

@export_group("ratings")

@export var ratingDisplays:Dictionary[String, StarBar]
@export var ratingInputs:Dictionary[String, StarBar]

#@export var ratingDisplays:Array[StarBar]
#@export var ratingInputs:Array[StarBar]
@export_group("")

#var levelDetailsDict:Dictionary #use levelDict from the parent class
var levelReviews

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	signalBus.showMoreLevelDetails.connect(showLevelDetails)
	signalBus.stopBrowsingLevels.connect(parentPopup.closePopup)
	submitReviewButton.pressed.connect(submitReview)

##sets all inputs and displays to the empty default values.
func clearDetails():
	reviewTextEdit.clear()
	for child in reviewsVBox.get_children():
		child.queue_free()
	for rating in ratingDisplays:
		ratingDisplays[rating].setStarBarValue(10)
	for rating in ratingInputs:
		ratingInputs[rating].setStarBarValue(10)
	foldableContainer.fold()
	artistNameLabel.text = "Loading Artist Name..."


##clear previous populated items to bring this page to a fresh state, display the popup, fetch level data drom the database, and repopulate the page with details and reviews
func showLevelDetails(newLevelDict):
	clearDetails()
	parentPopup.openPopup()
	levelDict = newLevelDict
	updateDetailedLabels()
	fetchArtistName()

func fetchArtistName():
	var username = await authentication.rpcRequest({"user_id":str(levelDict.artist)},"getUserName",false)
	username = JSON.parse_string(username[3].get_string_from_utf8())
	artistNameLabel.text = "Artist Name: "+username
	
##updates level information in the card but with more details than the base updateLabels function
func updateDetailedLabels():
	updateLabels()
	updateReviews()

##fetches all reviews belonging to this level and populate the list of reviews and ratings displays
func updateReviews():
	levelReviews = await authentication.rpcRequest({"level_id":int(levelDict["id"])},"getLevelReviews",false)
	levelReviews = JSON.parse_string(levelReviews[3].get_string_from_utf8())
	#get the sum of each criteria's ratings for averaging then divide by number of reviews
	var averages = {
		"Controls":0,
		"Visuals":0,
		"Difficulty Curve":0,
		"Learning Curve":0,
		"Creativity":0
		}
	var reviewsNum = len(levelReviews)
	for review in levelReviews:
		for criterion in averages:
			averages[criterion] += review[criterion]
	var sumOverall = 0 #sum of all review averages, which is averaged to get an overall rating
	for criterion in averages:
		averages[criterion] =  (averages[criterion] / reviewsNum)
		sumOverall += averages[criterion]
	averages["Overall"] = sumOverall / len(averages)
	for criterion in ratingDisplays:
		ratingDisplays[criterion].setStarBarValue(averages[criterion])

	#Example review: { "level_id": 27.0, "user_id": "806f6074-9841-4cf6-b80d-4465812480b4", "created_at": "2026-06-04T23:20:32.526573+00:00", "Controls": 9.0, "Visuals": 10.0, "Difficulty Curve": 9.0, "Learning Curve": 10.0, "Creativity": 9.0, "review": "I love my silly level!\n\n-Cheese Chair" }
	for review in levelReviews:
		var reviewPanel = REVIEW_PANEL.instantiate()
		if reviewPanel is ReviewPanel:
			reviewsVBox.add_child(reviewPanel)
			reviewPanel.authorLabel.text = "Author ID: "+review["user_id"]
			reviewPanel.reviewTextLabel.text = review["review"]
			var reviewSum=0 ##for averaging
			for criterion in reviewPanel.ratingDisplays:
				if criterion=="Overall":
					pass
				else:
					reviewPanel.ratingDisplays[criterion].setStarBarValue(review[criterion])
					reviewSum+=review[criterion]
			reviewPanel.ratingDisplays["Overall"].setStarBarValue( reviewSum / (len(reviewPanel.ratingDisplays)-1) )
			
func submitReview():
	if !authentication.isSignedIn or authentication.user=={}:
		signalBus.startTextPopup.emit("Sign in to submit a review")
		return
	var params = {"level_id":int(levelDict["id"]),"user_id":authentication.user["id"]
	,"controls":int(ratingInputs["controls"].slider.value)
	,"visuals":int(ratingInputs["visuals"].slider.value)
	,"difficulty_curve":int(ratingInputs["difficulty_curve"].slider.value)
	,"learning_curve":int(ratingInputs["learning_curve"].slider.value)
	,"creativity":int(ratingInputs["creativity"].slider.value)
	,"review":reviewTextEdit.text}

	var msg = await authentication.rpcRequest(params,"addReview")
	if msg[1] == 204:
		reviewTextEdit.clear()
		for criterion in ratingInputs:
			ratingInputs[criterion].setStarBarValue(10)
		foldableContainer.fold()
		signalBus.startTextPopup.emit("Review published successfully!")
	else:
		signalBus.startTextPopup.emit(str("Something went wrong:\n",msg[3].get_string_from_utf8()))
	updateReviews()
	
