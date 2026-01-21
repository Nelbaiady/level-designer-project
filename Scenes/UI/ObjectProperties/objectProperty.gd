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
