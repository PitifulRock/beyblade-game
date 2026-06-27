extends Control

var player : Player
var player_id : int

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		%PauseMenu.visible = !%PauseMenu.visible

func _ready() -> void:
	%PauseMenu.hide()
	#await get_tree().process_frame
	#player.game_unpaused.connect(save_settings)
	#
	#load_settings()

func _on_leave_lobby_pressed() -> void:
	Master.game_manager.remove_from_lobby(player_id)
func _on_quit_button_pressed() -> void:
	get_tree().quit()
func _on_resume_pressed() -> void:
	%PauseMenu.hide()
func _on_invite_friend_pressed() -> void:
	Steam.activateGameOverlayInviteDialog(Master.game_manager.lobby_id)

#func save_settings():
	##SettingsManager.save_audio_setting("sfx_volume")
	##SettingsManager.save_audio_setting("music_volume")
	#SettingsManager.save_video_setting("pixelization", $PixelizationSlider.value)
	#SettingsManager.save_player_setting("color", %PlayerColorPicker.color)
	##SettingsManager.save_player_setting("color", %PlayerColorPicker.color)
#
#func load_settings():
	#var video_settings = SettingsManager.get_video_settings()
	#var player_settings = SettingsManager.get_player_settings()
	#$PixelizationSlider.value = video_settings["pixelization"]
	#%PlayerColorPicker.color = player_settings["color"]
	#player.model.player_color = player_settings["color"]
