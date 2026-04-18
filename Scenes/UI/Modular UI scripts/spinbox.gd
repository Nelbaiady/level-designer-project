extends SpinBox

func _input(event: InputEvent):
	#when the player clicks away, the texbox is unfocuses
	if event is InputEventMouseButton and event.is_action_pressed("mouseClickLeft"):
		if !Rect2(Vector2(0,0), size).has_point(make_input_local(event).position):
			get_line_edit().release_focus()
