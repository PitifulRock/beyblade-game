extends RemoteTransform3D

@export var target_name : String
@export var set_top_level := true

func _ready() -> void:
	if not is_inside_tree(): return
	await get_tree().process_frame
	var target_node := get_parent().get_node_or_null(target_name)
	if target_node != null:
		remote_path = get_path_to(target_node)
		if set_top_level and target_node is Node3D:
			target_node.top_level = true
