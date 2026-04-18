class_name JumpPoint extends Area2D

@export var rootNode:Node2D
@export var canBouncePlayer = true
@export var detectFullBody := false ##whether the area should trigger on a body rather than the jumpSource area2D
@export var isPlayerOnly := true ##if the area only interacts with players
@export var bounciness:int = 700
@export var bouncinessMult:float = 1

func _ready() -> void:
	if !rootNode:
		rootNode = get_parent()
	if !rootNode.has_signal("jumpedOn"):
		printerr(rootNode.name ," has a jumpPoint area2D but does not have the jumpedOn signal")
	if "bounciness" in rootNode:
		bounciness = rootNode.bounciness
	if "bouncinessMult" in rootNode:
		bouncinessMult = rootNode.bouncinessMult

#update the property if it changes
func _physics_process(_delta: float) -> void:
	if "bouncinessMult" in rootNode:
		if rootNode.bouncinessMult != bouncinessMult:
			bouncinessMult = rootNode.bouncinessMult

func _on_area_entered(area: Area2D) -> void:
	if !detectFullBody and area.is_in_group("jumpSource"):
		if area.is_in_group("player") and area.is_in_group("jumpSource") and "rootNode" in area and area.rootNode is Player:
			var player:Player = area.rootNode
			if !player.bouncedThisFrame and player.velocity.y >= 0:
				if !player.bouncedThisFrame and canBouncePlayer:
					#TEMPORARILY REMOVE ROTATION ASPECT UNTIL WE FIGURE OUT HOW THE FLIP WE'RE FLIPPING THE ENEMY
					player.getBounced.emit(bounciness*bouncinessMult * Vector2.UP)
					#player.getBounced.emit(player.velocity.slide(Vector2.UP.rotated(global_rotation)) + Vector2.UP.rotated(global_rotation) * (bounciness*bouncinessMult))
					rootNode.jumpedOn.emit(player, self)
		#I could add bouncing for non-player areas but ill do that when its needed

func _on_body_entered(body: Node2D) -> void:
	if detectFullBody:
		if body is Player:
			if !body.bouncedThisFrame:
				body.getBounced.emit(body.velocity.slide(Vector2.UP.rotated(global_rotation)) + Vector2.UP.rotated(global_rotation) * (bounciness*bouncinessMult))
				rootNode.jumpedOn.emit(body, self)
		elif body.is_in_group("movables") and !isPlayerOnly:
			body.velocity = body.velocity.slide(Vector2.UP.rotated(global_rotation)) + Vector2.UP.rotated(global_rotation) * (bounciness*bouncinessMult)
			rootNode.jumpedOn.emit(body, self)
