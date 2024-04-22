extends Control

signal card_selected(card)

var selected = false
var card_data
var is_draggable = true
var is_choice_card = false

func init(data, is_choice: bool = false):
	name = "Card_%s" % data.id
	card_data = data
	is_choice_card = is_choice
	
	# Assuming you have child nodes with these names to display the data
	$Title.text = card_data.title
	$Description.text = "Test Description"
	$GoldCost.text = str(data.gold_cost)
	$EnergyCost.text = str(data.energy_cost)

func _gui_input(event):
	if card_data:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					emit_signal('card_selected', card_data)
