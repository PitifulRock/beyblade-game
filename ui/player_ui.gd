extends Control

@onready var player : Player = $"../.."
var player_id : int
var world : GameWorld

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if %PauseMenu.visible:
			%PauseMenu.save_settings()
			%PauseMenu.hide()
			if world.current_state == GameWorld.GAME_STATE.SELECTION:
				player.set_movement(false)
			else:
				player.set_movement(true)
		else:
			%PauseMenu.show()
			player.set_movement(false)

func _process(_delta: float) -> void:
	if %PauseMenu.visible and Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		player.set_movement(false)

func _ready() -> void:
	world = Master.game_manager.current_scene
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
	if %PauseMenu.visible:
		%PauseMenu.save_settings()
		%PauseMenu.hide()
		if world.current_state == GameWorld.GAME_STATE.SELECTION:
			player.set_movement(false)
		else:
			player.set_movement(true)
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


func _on_options_pressed() -> void:
	pass # Replace with function body.
