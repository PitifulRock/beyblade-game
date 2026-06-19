extends Control


func _ready() -> void:
	%EnterLobbyID.visible = false

func _on_host_button_pressed() -> void:
	Master.game_manager.host_server()
func _on_join_button_pressed() -> void:
	%EnterLobbyID.visible = true
func _on_enter_lobby_id_text_changed(new_text: String) -> void:
	%EnterID.disabled = (new_text.length() == 0)
func _on_enter_id_pressed() -> void:
	Master.game_manager.join_lobby(%EnterLobbyID.text.to_int())
	await Steam.lobby_joined
	#queue_free()

func _on_singleplayer_button_pressed() -> void:
	Master.game_manager.host_server()
func _on_quit_button_pressed() -> void:
	get_tree().quit()


func hide_menu():
	$PauseMenu.visible = false
	$PauseMenu.process_mode = Node.PROCESS_MODE_DISABLED
func show_menu():
	$PauseMenu.visible = true
	$PauseMenu.process_mode = Node.PROCESS_MODE_INHERIT
