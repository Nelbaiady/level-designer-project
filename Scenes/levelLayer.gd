class_name LevelLayer extends Parallax2D
@export var index:int = 0
@onready var tileMap: TileMapLayer = $TileMapLayer
@onready var objects: Node = $Objects
var tempProperties:Dictionary = {}

func _ready() -> void:
	tileMap.collision_enabled = true if index==0 else false
