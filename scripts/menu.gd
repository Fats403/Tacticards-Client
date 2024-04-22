extends Control

# Assuming these UI nodes exist in your scene
@onready var host_button = $HostButton
@onready var join_button = $JoinButton
@onready var code_entry = $CodeInput
@onready var status_label = $StatusLabel

func _ready() -> void:
	
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.join_requested.connect(_on_steam_join_requested)
	
	# Check if a player is joining via 'join game'
	check_command_line()

	# Reset UI elements
	status_label.text = ""

func join_lobby(lobby_id: int) -> void:
	print("Attempting to join lobby %s" % lobby_id)
	
	set_ui_state(false)
	set_status("Joining lobby...")
	
	Steam.joinLobby(lobby_id)
	Server.join_lobby(lobby_id)

func on_host_pressed():
	print("Creating Lobby...")
	
	set_ui_state(false)
	set_status("Creating lobby...")
	
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, 2)

func on_join_pressed():
	var entered_code = code_entry.text.strip_edges()
	if entered_code == "":
		set_status("Please enter a valid code.")
		return
	
	set_ui_state(false)
	set_status("Searching for lobby...")
	
	join_lobby(int(entered_code))
	
func _on_steam_join_requested(lobby_id: int, _friend_id: int) -> void:
	# Attempt to join the lobby via a user who clicked 'join game' in steam overlay
	join_lobby(lobby_id)

func _on_lobby_created(status: int, lobby_id: int) -> void:
	if status == 1:
		# Set as joinable, set some lobby data
		Steam.setLobbyJoinable(lobby_id, true)
		Server.create_lobby(lobby_id)
		
	else:
		set_status("Failed to create lobby.")
		set_ui_state(true)

func _on_lobby_joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	# If joining was successful
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		
		# Set the global lobby ID and change to the lobby scene
		Global.set_lobby_id(lobby_id)
		SceneManager.change_to_lobby(lobby_id);
		
	else:
		# Get the failure reason
		var fail_reason: String

		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = "This lobby no longer exists."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = "You don't have permission to join this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = "The lobby is now full."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: fail_reason = "Uh... something unexpected happened!"
			Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: fail_reason = "You are banned from this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = "You cannot join due to having a limited account."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: fail_reason = "This lobby is locked or disabled."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: fail_reason = "This lobby is community locked."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = "A user in the lobby has blocked you from joining."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = "A user you have blocked is in the lobby."

		set_status("Failed to join lobby. %s" % fail_reason)
		set_ui_state(true)

func exit_game() -> void:
	Global.exit_game()
	
func generate_code() -> String:
	return str(randi() % 10000).pad_zeros(4)

func set_status(text: String):
	status_label.text = text

func set_ui_state(enabled: bool):
	host_button.disabled = !enabled
	join_button.disabled = !enabled
	code_entry.editable = enabled
	
func check_command_line() -> void:
	var cmd_arguments: Array = OS.get_cmdline_args()
	if cmd_arguments.size() > 0:
		if cmd_arguments[0] == "+connect_lobby":
			if int(cmd_arguments[1]) > 0:
				print("Command line lobby ID: %s" % cmd_arguments[1])
				join_lobby(int(cmd_arguments[1]))
