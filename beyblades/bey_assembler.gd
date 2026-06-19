extends Node3D
class_name BeyAssembler

const BEY_SCENE = preload("uid://xkw4aloeefna")

@export var disc : BeyDisc
@export var core : BeyCore
@export var tip : BeyTip

var prev_pos : Vector3

func _ready() -> void:
	pass

func launch(bey_owner_id : int):
	var bey : BeyBlade = BEY_SCENE.instantiate()
	var world : World = Master.game_manager.current_scene
	bey.name = str(bey_owner_id)
	world.beyblade_path.add_child(bey)
	bey.global_position = global_position
	bey.process_mode = Node.PROCESS_MODE_DISABLED
	
	spawn_part(tip, bey)
	spawn_part(core, bey)
	spawn_part(disc, bey)
	
	await get_tree().process_frame
	bey.process_mode = Node.PROCESS_MODE_INHERIT
	
	bey._spawned()

func spawn_part(part_node : BeyPart, location : BeyBlade):
	var part_dup = part_node.duplicate()
	location.add_child(part_dup)
	
	part_dup.name = part_node.name
	part_dup.position = Vector3.ZERO
	part_dup.rotation = Vector3.ZERO
	
	var gib = RigidBody3D.new()
	gib.set_collision_layer_value(1, false)
	gib.set_collision_layer_value(2, true)
	location.burst_holder.add_child(gib)
	
	if part_dup is BeyDisc: 
		location.disc = part_dup
		part_dup.global_position = location.core.placement_point.global_position
	if part_dup is BeyCore: 
		location.core = part_dup
		part_dup.global_position = location.tip.placement_point.global_position
	if part_dup is BeyTip: 
		location.tip = part_dup
		part_dup.position = Vector3.ZERO
	
	for i in part_dup.get_children():
		if i is not Marker3D:
			var dup = i.duplicate()
			location.add_child(dup)
			dup.global_position = i.global_position
			
			var gib_dup = i.duplicate()
			gib.add_child(gib_dup)
			gib_dup.global_position = i.global_position
			
			i.queue_free()
