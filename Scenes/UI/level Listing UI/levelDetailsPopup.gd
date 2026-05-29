class_name LevelDetailsPopup extends LevelCard

@export var parentPopup:GenericPopup
@export var submitReviewButton:Button
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
	print(reviewTextEdit.text)

func showLevelDetails(newLevelDict):
	parentPopup.openPopup()
	levelDict = newLevelDict
	updateDetailedLabels()

#updates level information in the card but with more details than the base updateLabels function
func updateDetailedLabels():
	updateLabels()
