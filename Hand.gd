extends HBoxContainer

var dragged_child = null
var drag_offset = Vector2.ZERO
var original_idx = -1

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP  # This line ensures that the HBoxContainer itself does not ignore mouse events
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_PASS  # Allow events to pass through to this script

func _gui_input(event):
	
	print(event)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_attempt_start_drag(event)
			else:
				_stop_drag(event)
	elif event is InputEventMouseMotion and dragged_child:
		_handle_drag(event)

func _attempt_start_drag(event):
	for child in get_children():
		if child is Control:
			var child_rect = Rect2(child.global_position, child.size)
			if child_rect.has_point(event.global_position):
				start_dragging(child, event)

func start_dragging(child, event):
	dragged_child = child
	original_idx = child.get_index()
	drag_offset = event.global_position - child.global_position
	remove_child(child)
	if get_tree():
		get_tree().root.add_child(child)
		child.global_position = event.global_position - drag_offset

func _stop_drag(event):
	if dragged_child:
		if get_tree() and get_tree().root.has_node(dragged_child.name):
			get_tree().root.remove_child(dragged_child)
			add_child(dragged_child)
			move_child(dragged_child, original_idx)
		dragged_child = null

func _handle_drag(event):
	if dragged_child:
		dragged_child.global_position = event.global_position - drag_offset
