extends Node

var gameplay_config = GameplayConfig.new()

var config = ConfigFile.new()
const SETTINGS_PATH = "user://settings.ini"

func _ready() -> void:
	if !FileAccess.file_exists(SETTINGS_PATH):
		config.set_value("audio", "sfx_volume", 70.0)
		config.set_value("audio", "music_volume", 25.0)
		config.set_value("audio", "master_volume", 80.0)
		
		config.set_value("video", "fullscreen", 1)
		config.set_value("video", "anti_aliasing", 1)
		config.set_value("video", "shadow_quality", 1)
		config.set_value("video", "outlines", 1)
		
		config.set_value("player", "FOV", 75.0)
		config.set_value("player", "sensitivity", 0.2)
		
		config.save(SETTINGS_PATH)
	else:
		config.load(SETTINGS_PATH)
	

func save_audio_setting(key:String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_PATH)
func save_video_setting(key:String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_PATH)
func save_player_setting(key:String, value):
	config.set_value("player", key, value)
	config.save(SETTINGS_PATH)


func get_audio_settings():
	var audio_settings = {}
	for i in config.get_section_keys("audio"):
		audio_settings[i] = config.get_value("audio", i)
	return audio_settings
func get_video_settings():
	var video_settings = {}
	for i in config.get_section_keys("video"):
		video_settings[i] = config.get_value("video", i)
	return video_settings
func get_player_settings():
	var player_settings = {}
	for i in config.get_section_keys("player"):
		player_settings[i] = config.get_value("player", i)
	return player_settings
