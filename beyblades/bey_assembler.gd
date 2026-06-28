extends Node3D
class_name BeyAssembler

const BEY_SCENE = preload("uid://xkw4aloeefna")
const DUMMY_SCENE = preload("uid://byrwt3fjm0tec")
const LAUNCH_HEIGHT := 1.0

@export var random_dummy := false
@export var spawn_area_override : CollisionShape3D
@export var stadium_override : Node3D


@export var disc : BeyDisc
@export var core : BeyCore
@export var tip : BeyTip

var bey_ready := false
var placing_launch := false
var prev_pos : Vector3
var is_npc := false
var npc_name := ""

func _ready() -> void:
	if random_dummy:
		#var disc_id := randi_range(0, Registry.part_registry[BeyPart.PART_TYPE.DISC].size()-1)
		#var core_id := randi_range(0, Registry.part_registry[BeyPart.PART_TYPE.CORE].size()-1)
		#var tip_id := randi_range(0, Registry.part_registry[BeyPart.PART_TYPE.TIP].size()-1)
		#
		#prepare_npc(str(randi_range(-10,-9999)), disc_id, core_id, tip_id)
		set_random_position(spawn_area_override)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		if placing_launch and bey_ready: 
			lock_in_launch()

func prepare_launch(npc_bey := false, passed_npc_name : String = ""):
	show()
	if !npc_bey:
		if !is_multiplayer_authority(): return
		%LaunchSprite.modulate = Color.LIGHT_GREEN
		bey_ready = true
		placing_launch = true
	else:
		is_npc = true
		
		if Master.is_host:
			var disc_id := randi_range(0, Registry.part_registry[BeyPart.PART_TYPE.DISC].size()-1)
			var core_id := randi_range(0, Registry.part_registry[BeyPart.PART_TYPE.CORE].size()-1)
			var tip_id := randi_range(0, Registry.part_registry[BeyPart.PART_TYPE.TIP].size()-1)
			
			prepare_npc.rpc(passed_npc_name, disc_id, core_id, tip_id)
			set_random_position()

@rpc("any_peer", "call_local", "reliable")
func prepare_npc(new_name:String, disc_id:int, core_id:int, tip_id:int):
	npc_name = new_name
	disc = Registry.part_registry[BeyPart.PART_TYPE.DISC][disc_id].instantiate()
	core = Registry.part_registry[BeyPart.PART_TYPE.CORE][core_id].instantiate()
	tip = Registry.part_registry[BeyPart.PART_TYPE.TIP][tip_id].instantiate()

func _process(_delta: float) -> void:
	if !is_multiplayer_authority() or is_npc: return
	if placing_launch: shoot_ray()

func shoot_ray():
	var cam = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 100
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = cam.project_ray_origin(mouse_pos)
	ray_query.to = ray_query.from + cam.project_ray_normal(mouse_pos) * ray_length
	var ray_result = space.intersect_ray(ray_query)
	
	if !ray_result.is_empty(): 
		if ray_result["collider"].is_in_group("stadium"):
			global_position = ray_result["position"] + Vector3(0,LAUNCH_HEIGHT,0)

func lock_in_launch():
	bey_ready = false
	placing_launch = false
	Effects.play_ui(&"ButtonPress")

func launch():
	launch_visuals()
	
	var bey : BeyBlade = BEY_SCENE.instantiate()
	var world : GameWorld = Master.game_manager.current_scene
	
	if !is_npc: 
		bey.name = str(get_multiplayer_authority())
	else:
		bey.name = npc_name
	
	world.beyblade_path.add_child(bey)
	bey.global_position = global_position
	bey.process_mode = Node.PROCESS_MODE_DISABLED
	
	spawn_part(tip, bey)
	spawn_part(core, bey)
	spawn_part(disc, bey)
	
	await get_tree().process_frame
	bey.process_mode = Node.PROCESS_MODE_INHERIT
	
	bey._spawned(is_npc)
	
	if is_npc: queue_free()

func launch_dummy():
	var bey : BeyBladeDummy = DUMMY_SCENE.instantiate()
	
	add_sibling(bey)
	bey.global_position = global_position
	bey.process_mode = Node.PROCESS_MODE_DISABLED
	
	spawn_part(tip, bey)
	spawn_part(core, bey)
	spawn_part(disc, bey)
	
	await get_tree().process_frame
	bey.stadium = stadium_override
	bey.process_mode = Node.PROCESS_MODE_INHERIT
	
	bey._spawned()
	queue_free()

func launch_visuals():
	%LaunchSound.play()
	%LaunchParticles.emitting = true
	await get_tree().create_timer(0.8).timeout
	hide()

func spawn_part(part_node : BeyPart, location):
	var part_dup = part_node.duplicate()
	location.add_child(part_dup)
	
	part_dup.name = part_node.name
	part_dup.position = Vector3.ZERO
	part_dup.rotation = Vector3.ZERO
	
	var gib : RigidBody3D
	if !random_dummy:
		gib = RigidBody3D.new()
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
			var dup : Node = i.duplicate()
			location.add_child(dup)
			if i is Node3D:
				dup.global_position = i.global_position
			
			if !random_dummy:
				var gib_dup = i.duplicate()
				gib.add_child(gib_dup)
				if i is Node3D:
					gib_dup.global_position = i.global_position
			
			i.queue_free()

func set_random_position(spawn_area : CollisionShape3D = null):
	if spawn_area == null:
		var world : GameWorld = Master.game_manager.current_scene
		var stadium : Stadium = world.stadium_path.get_child(0)
		spawn_area = stadium.npc_spawn_area
	
	var radius : float = spawn_area.shape.radius
	var angle := randf_range(10, TAU)
	
	var random_radius : float = radius * sqrt(randf())

	var offset := Vector3(cos(angle), 0, sin(angle)) * random_radius
	global_position = spawn_area.global_position + offset
