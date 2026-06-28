extends Node3D

@export var cameras : Array[Camera3D]
@export var assemblers : Array[BeyAssembler]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	for i in assemblers:
		if !i.is_node_ready(): await i.ready
		i.launch_dummy()


func _on_cam_timer_timeout() -> void:
	var chosen_cam = cameras.pick_random()
	while chosen_cam == get_viewport().get_camera_3d():
		chosen_cam = cameras.pick_random()
	
	
	
	chosen_cam.make_current()
