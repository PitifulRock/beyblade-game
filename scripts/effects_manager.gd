@icon("res://art/icons/vector/plenticon/cd-white.svg")
extends Node

var sfx_stream: AudioStreamPolyphonic
var ui_stream: AudioStreamPolyphonic

@export var sfx_lib: AudioLibrary
@export var ui_lib: AudioLibrary
@export var music_lib: Array[AudioStreamSynchronized]

@onready var _music_stage: AudioStreamPlayer = %MusicPlayer
@onready var _music_override: AudioStreamPlayer = %MusicOverride
@onready var _sfx_player: AudioStreamPlayer = %SFXPlayer
@onready var _ui_player: AudioStreamPlayer = %UIPlayer

const max_poly:= 32

enum Type {
	SFX,
	UI,
}

var fade: Tween

var music_override_volume_cache = -80.0
var music_stage_volume_cache = -80.0
var sound_pool : Array[AudioStreamPlayer]
var SOUNDS = []

func transition():
	if %TransitionAnim.is_playing(): %TransitionAnim.stop()
	%TransitionAnim.play("transition")
	play_ui(&"TransitionIn")
	await %TransitionAnim.animation_finished
	%TransitionAnim.play_backwards("transition")

func _ready() -> void:
	sfx_stream = AudioStreamPolyphonic.new()
	sfx_stream.polyphony = max_poly
	_sfx_player.stream = sfx_stream
	ui_stream = AudioStreamPolyphonic.new()
	ui_stream.polyphony = max_poly
	_ui_player.stream = ui_stream
	_music_stage.finished.connect(_music_stage.play)
	_music_override.finished.connect(_music_override.play)

func set_music(stream: AudioStream, is_override:= true, fade_lentgh:= 0.5) -> void:
	fade = make_tween(self,fade,true).set_ignore_time_scale(true)

	fade.tween_property(_music_override,^"volume_db",-80.0,fade_lentgh)
	fade.tween_property(_music_stage,^"volume_db",-80.0,fade_lentgh)

	if fade:
		await fade.finished
		fade.stop()

	fade = make_tween(self,fade,true)

	if is_override:
		_music_override.stream = stream
		_music_override.play()
		fade.tween_property(_music_override,^"volume_db",0.0,fade_lentgh)
		await fade.finished
		_music_stage.stream_paused = true
	else:
		_music_stage.stream = stream

		_music_stage.play()
		fade.tween_property(_music_stage,^"volume_db",0.0,fade_lentgh)

func return_music() -> void:
	if fade: fade.kill()
	fade = create_tween().set_parallel()
	fade.tween_property(_music_override,^"volume_db",-80.0,1.5)
	fade.tween_property(_music_stage,^"volume_db",-80.0,1.5)
	fade.chain()
	_music_override.stop()
	fade.tween_property(_music_stage,^"volume_db",0.0,4.5)
	_music_stage.stream_paused = false



func play_ui(tag: String) -> void:
	_set_sound_lib(ui_lib,_ui_player,tag)

func play_sfx(tag: String) -> void:
	_set_sound_lib(sfx_lib,_sfx_player,tag)

func _set_sound_lib(library: AudioLibrary, audio: AudioStreamPlayer,tag: StringName) -> void:
	if not tag:
		return
	var sound = library.get_sound(tag)
	if not sound:
		return
	if not audio.playing:
		audio.play()
	var stream_playback := audio.get_stream_playback()
	stream_playback.play_stream(sound)

func fade_sound(audio_player: AudioStreamPlayer, target:= 0.0) -> void:
	var t:= create_tween()
	audio_player.volume_db = -80.0
	audio_player.play()
	t.tween_property(audio_player,^"volume_db",target,5.0)

func _fade_load(loaded:= false) -> void:
	if fade: fade.kill()
	fade = create_tween().set_parallel()
	if loaded:
		music_override_volume_cache = _music_override.volume_db
		music_stage_volume_cache = _music_stage.volume_db
		if _music_override.playing:
			fade.tween_property(_music_override,^"volume_db",-20.0,0.5)
		fade.tween_property(_music_stage,^"volume_db",-20.0,0.5)
	#else:
	#	fade.tween_property(music_override,^"volume_db",0.0,0.5)
	#	fade.tween_property(music_stage,^"volume_db",0.0,0.5)

func initialize_sounds():
	for i in 20:
		var cur_sound = AudioStreamPlayer3D.new()
		Master.local_player.get_parent().add_child(cur_sound)
		sound_pool.push_back(cur_sound)

func play_sound(tag : String, position: Vector3) -> void:
	if sound_pool.is_empty():
		initialize_sounds()
	
	var sound_file = null
	
	for s in SOUNDS:
		if s.tag.to_lower() == tag.to_lower():
			sound_file = s.stream
	
	if sound_file == null: return

	var cur_sound
	for s in sound_pool:
		if !s.playing:
			cur_sound = s
			
	if cur_sound == null:
		cur_sound = AudioStreamPlayer3D.new()
		Master.local_player.get_parent().add_child(cur_sound)
		sound_pool.push_back(cur_sound)

	cur_sound.global_position = position
	cur_sound.stream = sound_file
	cur_sound.play()

func make_tween(parent: Node, tween: Tween,parallel:= false) -> Tween:
	if tween:
		tween.kill()
	tween = parent.create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	if parallel:
		tween.set_parallel(true)
	return tween

func set_sync_music(random := true):
	%MusicPlayer.stop()
	if random:
		var picked_stream = music_lib.pick_random()
		
		%MusicPlayer.stream = picked_stream
		%MusicPlayer.play()

func fade_drum_track(drums_on : bool):
	var tween := get_tree().create_tween()
	var music_stream : AudioStreamSynchronized = %MusicPlayer.stream
	
	if drums_on:
		tween.tween_property(music_stream.get_sync_stream(1), "volume", 1.0, 0.8)
	else:
		tween.tween_property(music_stream.get_sync_stream(1), "volume", 0.0, 0.8)
