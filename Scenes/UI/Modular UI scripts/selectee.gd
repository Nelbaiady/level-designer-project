##UI node to be selected
class_name Selectee extends Control

@export var selector:Selector

##when instructed to, this selector will go to the given location
func callSelector():
	#selector.goToPosition(global_position)
	selector.goToPosition(get_parent().get_global_transform().affine_inverse() * global_position)
