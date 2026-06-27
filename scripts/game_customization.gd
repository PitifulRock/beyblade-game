extends Resource
class_name GameplayConfig

@export_range(0.0, 20.0, 1.0) var points_to_win := 5
@export_range(0.5, 1.5, 0.1) var game_speed := 1.0
@export var cheating_enabled := false
@export var disasters_enabled := true
@export var npc_count := 0
@export var wait_for_npcs := false
