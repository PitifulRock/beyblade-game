extends Control

@export var menu_music : AudioStreamSynchronized

func _ready() -> void:
	Effects.set_sync_music(false, false, menu_music)
	Settings.gameplay_config = GameplayConfig.new()
	%TabContainer.current_tab = 0
	%EnterLobbyID.visible = false
	if not Steam.isSteamRunning():
		%HostButton.disabled = true
		%JoinButton.disabled = true

func _on_host_button_pressed() -> void:
	Effects.play_ui(&"ButtonPress")
	await Effects.transition()
	%TabContainer.current_tab = 1
func _on_join_button_pressed() -> void:
	%EnterLobbyID.visible = true
	Effects.play_ui(&"ButtonPress")
func _on_enter_lobby_id_text_changed(new_text: String) -> void:
	%EnterID.disabled = (new_text.length() == 0)
	Effects.play_ui(&"ButtonPress")
func _on_enter_id_pressed() -> void:
	Master.game_manager.join_lobby(%EnterLobbyID.text.to_int())
	Effects.play_ui(&"ButtonPress")
	await Steam.lobby_joined
	#queue_free()

func _on_singleplayer_button_pressed() -> void:
	Master.game_manager.host_server()
	Effects.play_ui(&"ButtonPress")
func _on_quit_button_pressed() -> void:
	get_tree().quit()


func hide_menu():
	$PauseMenu.visible = false
	$PauseMenu.process_mode = Node.PROCESS_MODE_DISABLED
func show_menu():
	$PauseMenu.visible = true
	$PauseMenu.process_mode = Node.PROCESS_MODE_INHERIT


func _on_start_pressed() -> void:
	Master.game_manager.host_server()
	Effects.play_ui(&"ButtonPress")

func _on_points_to_win_value_changed(value: float) -> void:
	Settings.gameplay_config.points_to_win = value
	%PointsLabel.text = str("Points to win:  ", int(value))
	Effects.play_ui(&"ButtonHover")
func _on_cheats_toggle_toggled(toggled_on: bool) -> void:
	Settings.gameplay_config.cheating_enabled = toggled_on
	%CheatsLabel.text = str("Cheats:  ", "Enabled" if toggled_on else "Disabled")
	Effects.play_ui(&"ButtonPress")
func _on_game_speed_value_changed(value: float) -> void:
	Settings.gameplay_config.game_speed = value
	%SpeedLabel.text = str("Game Speed:  ", value, "x")
	Effects.play_ui(&"ButtonHover")
func _on_disasters_toggle_toggled(toggled_on: bool) -> void:
	Settings.gameplay_config.disasters_enabled = toggled_on
	%DisastersLabel.text = str("Natural Disasters:  ", "Enabled" if toggled_on else "Disabled")
	Effects.play_ui(&"ButtonPress")
func _on_npc_number_value_changed(value: float) -> void:
	Settings.gameplay_config.npc_count = value
	Effects.play_ui(&"ButtonPress")
func _on_npc_win_toggle_toggled(toggled_on: bool) -> void:
	Settings.gameplay_config.wait_for_npcs = toggled_on
	Effects.play_ui(&"ButtonPress")

func _on_return_pressed() -> void:
	Effects.play_ui(&"ButtonPress")
	await Effects.transition()
	%TabContainer.current_tab = 0


func _on_settings_button_pressed() -> void:
	Effects.play_ui(&"ButtonPress")
	%TabContainer.current_tab = 2
