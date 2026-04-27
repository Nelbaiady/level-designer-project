class_name ObjectProperty extends Resource

@export var codeName:String
@export var displayName:String
@export var uiNode:PackedScene

#attributes of the uiNode
@export var defaultValue: float = 0
@export var minValue: float# = -999999999999.0
@export var maxValue: float# = 999999999999.0
@export var step: float
#Whether the min or max values are in effect
@export var hasMin: bool = false
@export var hasMax: bool = false

@export var choices: Dictionary = {} ##[UNIMPLEMENTED] if this property has multiple to choose from or specific data

@export var subNodes: Array[String] ##[UNIMPLEMENTED] if this property acts on a sub-property or a node within the rootNode

@export var triggersFunction: bool = false ##[UNIMPLEMENTED] if changing the value of this property triggers a function instead of just setting a variable
