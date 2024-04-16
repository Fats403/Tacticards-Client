extends Node

var lobby_id = Global.get_lobby_id()

@onready var lobby_id_label = $LobbyPanel/LobbyIdLabel
@onready var player_slots = [
	{ 'node': $LobbyPanel/PlayerSlot1, 'steam_id': null, 'steam_name': null },
	{ 'node': $LobbyPanel/PlayerSlot2, 'steam_id': null, 'steam_name': null },
	{ 'node': $LobbyPanel/PlayerSlot3, 'steam_id': null, 'steam_name': null },
	{ 'node': $LobbyPanel/PlayerSlot4, 'steam_id': null, 'steam_name': null }
]

func _ready() -> void:
	# Connect Steam callbacks
	Steam.avatar_loaded.connect(_on_loaded_avatar)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	
	lobby_id_label.text = "Lobby ID: %s" % lobby_id
	get_lobby_members()

func get_lobby_members() -> void:
	
	# Clear lobby state
	for slot in player_slots:
		slot['steam_id'] = null
		slot['steam_name'] = null
		slot['node'].get_node("PlayerName").text = ""
		slot['node'].get_node("PlayerAvatar").texture = null
		
	var num_of_members: int = Steam.getNumLobbyMembers(lobby_id)

	# Re make lobby state
	for i in range(num_of_members):
		var steam_id: int = Steam.getLobbyMemberByIndex(lobby_id, i)
		var steam_name: String = Steam.getFriendPersonaName(steam_id)

		player_slots[i]['steam_id'] = steam_id
		player_slots[i]['steam_name'] = steam_name
		player_slots[i]['node'].get_node("PlayerName").text = steam_name
		
		Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM, steam_id)
	
func _on_lobby_chat_update(lobby_id: int, changed_id: int, making_change_id: int, chat_state: int) -> void:
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		print("User %d joined the lobby" % changed_id)
	else:
		print("User %d left the lobby" % changed_id)

	get_lobby_members()
		
func _on_loaded_avatar(user_id: int, avatar_size: int, avatar_buffer: PackedByteArray) -> void:
	var avatar_image: Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)
	if avatar_size > 64:
		avatar_image.resize(64, 64, Image.INTERPOLATE_LANCZOS)
		
	var avatar_texture: ImageTexture = ImageTexture.create_from_image(avatar_image)

	for slot in player_slots:
		if slot['steam_id'] == user_id:
			slot['node'].get_node("PlayerAvatar").texture = avatar_texture
			break
			
func on_pressed_copy_lobby_code() -> void:
	DisplayServer.clipboard_set(str(lobby_id))
	
func on_start_game_pressed() -> void:
	rpc_id(1, "request_start_game", multiplayer.get_unique_id(), lobby_id)

@rpc("reliable", "authority")
func client_start_game(leader_id):
	SceneManager.change_to_game(lobby_id, leader_id)

@rpc("reliable", "authority")
func client_lobby_leader_disconnect():
	Global.set_lobby_id(0)
	SceneManager.change_to_menu();
	pass
	
@rpc("reliable", "authority")
func client_update_lobby():
	pass

func set_status(_text: String):
	pass

func set_ui_state(_enabled: bool):
	pass

# Server methods for checksum
@rpc
func request_start_game():
	pass
