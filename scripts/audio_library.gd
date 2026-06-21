class_name AudioLibrary
extends Resource

@export var library: Dictionary[StringName,AudioStream] = {}

func get_sound(tag: StringName) -> AudioStream:
	if library.has(tag):
		return library[tag]
	return null
