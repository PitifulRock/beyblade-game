extends Node3D
class_name BeyAssembler

const BEY_SCENE = preload("uid://xkw4aloeefna")

@export var disc : PackedScene
@export var core : PackedScene
@export var tip : PackedScene

func _ready() -> void:
	await get_tree().process_frame
	var bey = BEY_SCENE.instantiate()
	add_sibling(bey)
	bey.global_position = global_position
	
	spawn_part(tip, bey)
	spawn_part(core, bey)
	spawn_part(disc, bey)
	
	bey._spawned()

func spawn_part(part_scene : PackedScene, location : BeyBlade):
	var inst = part_scene.instantiate()
	location.add_child(inst)
	
	if inst is BeyDisc: 
		location.disc = inst
		inst.global_position = location.core.placement_point.global_position
	if inst is BeyCore: 
		location.core = inst
		inst.global_position = location.tip.placement_point.global_position
	if inst is BeyTip: 
		location.tip = inst
		inst.position = Vector3.ZERO
	
	for i in inst.get_children():
		if i is not Marker3D:
			var dup = i.duplicate()
			location.add_child(dup)
			dup.global_position = i.global_position
			i.queue_free()
			
