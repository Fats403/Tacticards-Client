extends Node

signal start_drag_card(card)
signal stop_drag_card()
signal request_place_card(card)
signal request_place_effect(card)

@onready var card_placement = $PlayerCardPlacement

var dragged_child = null
var drag_offset = Vector2.ZERO
var original_parent = null
var original_idx = 0
var last_dragged_card_id = null
var selector_activated = false

var nearest_slot_index = -1
var placed_cards = []  # Array to keep track of placed cards

const SLOT_THRESHOLD = 50  # Distance threshold to consider a slot placement
const NUM_SLOTS = 4
var slot_size = Vector2(100, 130)

func _ready():
	for i in range(NUM_SLOTS):
		placed_cards.append(null)  # Initialize for 4 slots, assuming 4 slots

func set_player_data(data):
	for child in $Hand.get_children():
		child.queue_free()
		
	for card in data.hand:
		var card_node = load("res://cards/card.tscn").instantiate()
		card_node.init(card)
		card_node.connect("card_selected", Callable(self, "_on_card_selected"))
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
				# Start drag if a card is clicked
				_attempt_start_drag(event)
			elif not event.pressed and dragged_child:
				# Stop drag when mouse is released
				_check_slot_placement(event)
				_stop_drag(event)
	elif event is InputEventMouseMotion and dragged_child:
		# Handle dragging
		_handle_drag(event)
		
	if dragged_child:
		if dragged_child.global_position.x <= ((GameData.grid_offset_x * 2) + GameData.grid_width):
			dragged_child.hide()
		else:
			dragged_child.show()

func _check_slot_placement(event):
	nearest_slot_index = -1  # Reset global index each time
	var cursor_position = event.global_position  # Get the current mouse position globally

	for i in range(card_placement.get_child_count()):
		var slot = card_placement.get_child(i)
		var slot_rect = Rect2(slot.global_position - slot_size * 0.5, slot_size)  # Create a Rect2 centered on the slot

		if slot_rect.has_point(cursor_position) and placed_cards[i] == null:
			nearest_slot_index = i
			break  # Exit the loop as we've found the nearest slot under cursor

	if nearest_slot_index != -1:
		placed_cards[nearest_slot_index] = dragged_child

		# Align the center of the card with the center of the slot
		dragged_child.global_position = card_placement.get_child(nearest_slot_index).global_position - dragged_child.size * 0.5
		selector_activated = true  # Ensure card does not revert


func _attempt_start_drag(event):
	# Check all children of the Hand container
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
		if not selector_activated and nearest_slot_index == -1:  # Only add back if selector was not activated
			dragged_child.show()  # Show again in case it was hidden
			emit_signal('stop_drag_card')
			
			get_tree().root.remove_child(dragged_child)
			original_parent.add_child(dragged_child)
			original_parent.move_child(dragged_child, original_idx)
			dragged_child.position = event.global_position - drag_offset
		
		dragged_child = null
		selector_activated = false  # Reset the flag for the next operation

func _handle_drag(event):
	if dragged_child:
		dragged_child.global_position = event.global_position - drag_offset
