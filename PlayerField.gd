extends Node

signal start_drag_card(card)
signal stop_drag_card()
signal request_place_card(card)
signal request_place_board(card, index)

@onready var card_placement = $Board

var dragged_child = null
var drag_offset = Vector2.ZERO
var original_parent = null
var original_idx = 0
var last_dragged_card_id = null
var selector_activated = false

var NUM_SLOTS = 4

func set_player_data(data):
	
	NUM_SLOTS = data.board.size()
	
	# Clear only card nodes before adding new data
	for child in $Board.get_children():
		if not child.name.begins_with("Slot"):
			child.queue_free()

	# Place new cards based on data from the server
	for i in range(NUM_SLOTS):
		var card_data = data.board[i]
		if card_data:
			var card_node = load("res://cards/card.tscn").instantiate()
			card_node.init(card_data)
			card_node.scale = Vector2(1, 1)
			card_node.position = get_slot_position(i) - (card_node.size * 0.5)  # Compute position based on slot index
			$Board.add_child(card_node)

	# Update hand, deck size, discard pile size, and energy
	for child in $Hand.get_children():
		child.queue_free()

	for card in data.hand:
		var card_node = load("res://cards/card.tscn").instantiate()
		card_node.init(card)
		$Hand.add_child(card_node)

	$DeckSize.text = str(data.deck.size())
	$DiscardSize.text = str(data.discard.size())
	$EnergyLabel.text = str(data.energy)
	
func _on_card_selected(card) -> void:
	pass

func _on_selector_released(card_id, corners) -> void:
	selector_activated = true 
	emit_signal('request_place_card', card_id, corners)
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not dragged_child:
				_attempt_start_drag(event)
			elif not event.pressed and dragged_child:
				_check_slot_placement(event)
				_stop_drag(event)
	elif event is InputEventMouseMotion and dragged_child:
		_handle_drag(event)
	
	if dragged_child:
		var is_in_game_board = dragged_child.global_position.x <= ((GameData.grid_offset_x * 2) + GameData.grid_width)
		if dragged_child.card_data.action_type == GameData.ActionTypes.SELECTOR:
			if is_in_game_board:
				dragged_child.hide()
			else:
				dragged_child.show()
		else:
			if is_in_game_board:
				_stop_drag(event)
			
			
func get_slot_position(index):
	# Compute and return the global position for a slot by index
	var slot = card_placement.get_node("Slot" + str(index))
	return slot.global_position

func _check_slot_placement(event):
	var nearest_slot_index = -1
	var cursor_position = event.global_position

	for i in range(NUM_SLOTS):
		var slot = card_placement.get_node("Slot" + str(i))
		var slot_rect = Rect2(slot.global_position - slot.size * 0.5, slot.size)
		if slot_rect.has_point(cursor_position):
			nearest_slot_index = i
			break

	if nearest_slot_index != -1 and dragged_child.card_data.action_type == GameData.ActionTypes.EFFECT:
		emit_signal("request_place_board", dragged_child.card_data.id, nearest_slot_index)
		dragged_child.queue_free()
		selector_activated = true
	
func _attempt_start_drag(event):
	for child in $Hand.get_children():
		if child is Control:
			var child_rect = Rect2(child.global_position, child.size)
			if child_rect.has_point(event.global_position):
				dragged_child = child
				last_dragged_card_id = child.card_data.id
				original_parent = child.get_parent()
				original_idx = original_parent.get_index()
				drag_offset = event.global_position - child.global_position
				original_parent.remove_child(child)
				get_tree().root.add_child(child)
				child.global_position = event.global_position - drag_offset
				emit_signal('start_drag_card', last_dragged_card_id)
				break

func _stop_drag(event):
	if dragged_child:
		if not selector_activated:
			dragged_child.show()
			emit_signal('stop_drag_card')
			get_tree().root.remove_child(dragged_child)
			original_parent.add_child(dragged_child)
			original_parent.move_child(dragged_child, original_idx)
			dragged_child.position = event.global_position - drag_offset
		
		dragged_child = null
		selector_activated = false

func _handle_drag(event):
	if dragged_child:
		dragged_child.global_position = event.global_position - drag_offset
