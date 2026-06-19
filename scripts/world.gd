extends Node3D
class_name World

enum STATE{SELECTION, PLACEMENT, BATTLE, RESULTS}

@export var base_time_scale := 1.0
@export var assembly_menu : Control
@export var player_path : Node3D
@export var beyblade_path : Node3D

func _on_bey_burst():
	var tween = get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(Engine,"time_scale", 0.4, 0.2)
	tween.tween_interval(0.5)
	tween.tween_property(Engine,"time_scale", base_time_scale, 0.8)
