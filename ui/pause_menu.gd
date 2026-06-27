extends Node

var save_file_path = "user://save/"
var save_file_name = "player_settings.tres"
var aa_value : int
var shadow_value : int

func _ready() -> void:
	verify_save_dir(save_file_path)
	%Shadow.get_popup().id_pressed.connect(update_shadow)
	%AA.get_popup().id_pressed.connect(update_aa)
	for i in get_children():
		i.visible = false
	
	load_settings()

func verify_save_dir(path : String):
	DirAccess.make_dir_absolute(path)

func settings_data():
	var save_library = {
		"mouse_sens" = %Sensitivity.value,
		"cam_smooth" = %CamDelay.value,
		"FOV" = %FovSlider.value,
		"master_vol" = %MasterVol.value,
		"music_vol" = %MusicVol.value,
		"sound_vol" = %SFXVol.value,
		"fullscreen" = DisplayServer.window_get_mode(),
		"shadow_quality" = shadow_value,
		"anti_aliasing" = aa_value,
	}
	
	return save_library

func load_settings():
	if not FileAccess.file_exists("user://player_settings.dat"):
		return
	
	var save_file = FileAccess.open("user://player_settings.dat", FileAccess.READ)
	
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var _parse_result = json.parse(json_string)
		var node_data = json.get_data()
		
		update_settings(node_data)

func save_settings():
	var save_file = FileAccess.open("user://player_settings.dat", FileAccess.WRITE)
	var json_string = JSON.stringify(settings_data())
	
	save_file.store_line(json_string)

func open():
	$MainPanel.visible = true
	hide_menus()
	Manager.can_interact = false
	Manager.paused = true
	Manager._free_mouse()
func close():
	$MainPanel.visible = false
	Manager.can_interact = true
	Manager.paused = false
	Manager._capture_mouse()
	save_settings()
	hide_menus()
func hide_menus():
	%Video.visible = false
	%Audio.visible = false
	%Controls.visible = false

func update_shadow(id : int):
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
func update_fullscreen(on : bool):
	if on: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
func update_fov(fov : float):
	%fovLabel.text = str("FOV: ", fov)
	Manager.player.set_fov(fov)
func update_aa(id : int):
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
func update_master_volume(value):
	var dB = value/100 * 15.0 - 20
	if value == -100.0: AudioServer.set_bus_mute(0, true)
	else: AudioServer.set_bus_mute(0, false)
	AudioServer.set_bus_volume_db(0, dB)
	%MasterLabel.text = str("Master Volume: ", value)
func update_music_volume(value):
	var dB = value/100 * 20.0
	if value == 0.0: AudioServer.set_bus_mute(2, true)
	else: AudioServer.set_bus_mute(2, false)
	AudioServer.set_bus_volume_db(2, dB)
	%MusicLabel.text = str("Music Volume: ", value)
func update_sfx_volume(value):
	var dB = value/100 * 30.0
	if value == 0.0: AudioServer.set_bus_mute(1, true)
	else: AudioServer.set_bus_mute(1, false)
	AudioServer.set_bus_volume_db(1, dB)
	%SFXLabel.text = str("SFX Volume: ", value)
func update_mouse_sens(value):
	var sens = value/1000
	Manager.player.sensitivity = sens
	%SensLabel.text = str("Camera Sensitivity: ", value)
func update_cam_delay(value):
	var smooth_amt = 25.0-value
	Manager.player.cam_delay = smooth_amt
	%CamDelayLabel.text = str("Camera Delay/Smooth: ", value)

func update_settings(node_data : Dictionary):
	update_fov(node_data["FOV"])
	%FovSlider.value = node_data["FOV"]
	
	update_aa(node_data["anti_aliasing"])
	update_shadow(node_data["shadow_quality"])
	
	update_master_volume(node_data["master_vol"])
	%MasterVol.value = node_data["master_vol"]
	update_music_volume(node_data["music_vol"])
	%MusicVol.value = node_data["music_vol"]
	update_sfx_volume(node_data["sound_vol"])
	%SFXVol.value = node_data["sound_vol"]
	
	update_mouse_sens(node_data["mouse_sens"])
	update_cam_delay(node_data["cam_smooth"])
	
	match node_data["fullscreen"]:
			0.0: 
				%CheckBox.button_pressed = false
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			3.0:
				%CheckBox.button_pressed = true
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			4.0:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
