extends CanvasLayer

signal card_choices_selected(cards)

var selected_cards = []
var max_choices = 3

# TODO: Clear card choices, when new ones are set or when the layer is closed (hidden)

func set_card_choices(choices, num_choices = 3):
	max_choices = num_choices
	selected_cards = []
	
	$ChooseCardsButton.disabled = true
	
	# Clear previous choices
	for child in $HBoxContainer.get_children():
		child.queue_free()
	
	for choice in choices:
		var card = load("res://cards/card.tscn").instantiate()
		
		card.init(choice, true)
		card.connect("card_selected", Callable(self, "_on_card_choice_selected"))
		
		$HBoxContainer.add_child(card)

func _on_card_choice_selected(selected_card):
	var found_card = find_card_in_selected_cards(selected_card.id)
	var card_node = get_node("HBoxContainer/Card_%s" % selected_card.id)
	
	if found_card != null:
		selected_cards.erase(selected_card)
		card_node.modulate = Color(1, 1, 1)
	elif len(selected_cards) < max_choices:
		card_node.modulate = Color(0, 1, 0)
		selected_cards.append(selected_card)
	
	if selected_cards.size() >= max_choices:
		$ChooseCardsButton.disabled = false
	else:
		$ChooseCardsButton.disabled = true
	
func find_card_in_selected_cards(id):
	for card in selected_cards:
		if card.id == id:
			return card
	return null

func _on_select_cards_pressed():
	emit_signal("card_choices_selected", selected_cards)
	hide()
