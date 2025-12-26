# State machine code reference: https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/
class_name StateMachine extends Node

@export var initialState: State = null
@onready var state: State = (func get_initial_state() -> State:
	return initialState if initialState != null else get_child(0)
).call()

func _ready() -> void:
#	each state can transition to the next state, which is triggered in the state machine
	for stateNode: State in find_children("*", "State"):
		stateNode.finished.connect(_transitionToNextState)
	await owner.ready
	state.enter("")

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func _process(delta: float) -> void:
	state.update(delta)

func _physics_process(delta: float) -> void:
	state.physics_update(delta)

func _transitionToNextState(targetStatePath: String, data: Dictionary = {}) -> void:
	if not has_node(targetStatePath):
		printerr(owner.name + ": Trying to transition to state " + targetStatePath + " but it does not exist.")
		return

	var previousStatePath := state.name
	state.exit()
	state = get_node(targetStatePath)
	state.enter(previousStatePath, data)
