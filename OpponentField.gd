extends Node

# TODO: Allow user to purchase new card backs?
var card_texture = preload("res://cards/backs/card_back_opponent.png")

func set_opponent_data(data):
	
	clear_board_state()
	
	print(data)
	
	for i in range(data.board.size()):
		var card_data = data.board[i]
		if card_data:
			var card_node = load("res://cards/backs/card_back.tscn").instantiate()
			card_node.position = get_slot_position(data.board.size() - i - 1) - (card_node.size * 0.5)
			$Board.add_child(card_node)
	
	for child in $Hand.get_children():
		child.queue_free()

	for i in data.hand_size:
		var card_node = load("res://cards/backs/card_back.tscn").instantiate()
		print(card_node.size)
		$Hand.add_child(card_node)

	$DeckSize.text = str(data.deck_size)
	$DiscardSize.text = str(data.discard_size)
	$EnergyLabel.text = str(data.energy)

func clear_board_state():
	# Clear only card nodes before adding new data
	for child in $Board.get_children():
		if not child.name.begins_with("Slot"):
			child.queue_free()

func reveal_board_state(private_board_state):
	
	clear_board_state()
	
	var board_size = private_board_state.size()
	
	# Place new cards based on data from the server
	for i in range(board_size):
		var card_data = private_board_state[i]
		if card_data:
			var card_node = load("res://cards/card.tscn").instantiate()
			card_node.init(card_data)
			card_node.scale = Vector2(1, 1)
			card_node.position = get_slot_position(board_size - i - 1) - (card_node.size * 0.5)  # Compute position based on slot index
			$Board.add_child(card_node)
	
			
func get_slot_position(index):
	# Compute and return the global position for a slot by index
	var slot = $Board.get_node("Slot" + str(index))
	return slot.global_position

func _on_card_selected(card) -> void:
	pass
