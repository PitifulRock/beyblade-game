extends Control
class_name OptionsMenu

var save_file_path = "user://save/"
var save_file_name = "settings.tres"
var aa_value : int
var shadow_value : int

func _ready() -> void:
	%Shadow.get_popup().id_pressed.connect(update_shadow)
	%AA.get_popup().id_pressed.connect(update_aa)
	
	await get_tree().process_frame
	load_settings()

func load_settings():
	for i in Settings.get_audio_settings().keys():
		var value = Settings.get_audio_settings()[i]
		match i:
			"sfx_volume": 
				%SFXVol.value = value
				update_sfx_volume(value, true)
			"music_volume": 
				%MusicVol.value = value
				update_music_volume(value, true)
			"master_volume": 
				%MasterVol.value = value
				update_master_volume(value, true)
	
	for i in Settings.get_player_settings():
		var value = Settings.get_player_settings()[i]
		match i:
			"sensitivity": 
				%Sensitivity.value = value
				update_mouse_sens(value, true)
			"FOV": 
				%FovSlider.value = value
				update_fov(value, true)
	
	for i in Settings.get_video_settings():
		var value = Settings.get_video_settings()[i]
		match i:
			"anti_aliasing": 
				update_aa(value, true)
			"shadow_quality": 
				update_shadow(value, true)
			"fullscreen": 
				match value:
					0: %FullScreenToggle.button_pressed = false
					1: %FullScreenToggle.button_pressed = true
				update_fullscreen(value, true)
			"outlines":
				%OutlineToggle.button_pressed = value as bool
				update_outlines(value as bool)

func update_shadow(id : int, init := false):
	if !init: Effects.play_ui(&"ButtonPress")
	shadow_value = id
	match id:
		0:
			%Shadow.text = "Low"
			get_viewport().positional_shadow_atlas_size = 2048
		1:
			%Shadow.text = "Medium"
			get_viewport().positional_shadow_atlas_size = 4096
		2:
			%Shadow.text = "High"
			get_viewport().positional_shadow_atlas_size = 8192
func update_fullscreen(on : bool, init := false):
	if on: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if !init: Effects.play_ui(&"ButtonPress")
func update_fov(fov : float, init := false):
	%fovLabel.text = str("FOV: ", fov)
	if Master.local_player:
		Master.local_player.fov = fov
	if !init: Effects.play_ui(&"ButtonHover")
func update_aa(id : int, init := false):
	if !init: Effects.play_ui(&"ButtonPress")
	aa_value = id
	match id:
		0:
			%AA.text = "Disabled"
			get_viewport().msaa_3d = Viewport.MSAA_DISABLED
		1:
			%AA.text = "2x"
			get_viewport().msaa_3d = Viewport.MSAA_2X
		2:
			%AA.text = "4x"
			get_viewport().msaa_3d = Viewport.MSAA_4X
		3:
			%AA.text = "8x"
			get_viewport().msaa_3d = Viewport.MSAA_8X
func update_master_volume(value, init := false):
	AudioServer.set_bus_volume_db(0, linear_to_db(value/100.0))
	%MasterLabel.text = str("Master Volume: ", int(value),"%")
	if !init: Effects.play_ui(&"ButtonHover")
func update_music_volume(value, init := false):
	AudioServer.set_bus_volume_db(2, linear_to_db(value/100.0))
	%MusicLabel.text = str("Music Volume: ", int(value),"%")
	if !init: Effects.play_ui(&"ButtonHover")
func update_sfx_volume(value, init := false):
	AudioServer.set_bus_volume_db(1, linear_to_db(value/100.0))
	%SFXLabel.text = str("SFX Volume: ", int(value),"%")
	if !init: Effects.play_ui(&"ButtonHover")
func update_mouse_sens(value, init := false):
	%SensLabel.text = str("Camera Sensitivity: ", value)
	if Master.local_player:
		Master.local_player.sensitivity = value
	if !init: Effects.play_ui(&"ButtonHover")
func update_outlines(toggled_on: bool, init := false) -> void:
	if !init: Effects.play_ui(&"ButtonPress")
	if Master.local_player: Master.local_player.set_outlines(toggled_on)

func save_settings():
	Settings.save_audio_setting("sfx_volume", %SFXVol.value)
	Settings.save_audio_setting("music_volume", %MusicVol.value)
	Settings.save_audio_setting("master_volume", %MasterVol.value)
	
	Settings.save_video_setting("anti_aliasing", aa_value)
	Settings.save_video_setting("shadow_quality", shadow_value)
	Settings.save_video_setting("fullscreen", DisplayServer.window_get_mode())
	Settings.save_video_setting("outlines", %OutlineToggle.button_pressed as int)
	
	Settings.save_player_setting("sensitivity", %Sensitivity.value)
	Settings.save_player_setting("FOV", %FovSlider.value)
