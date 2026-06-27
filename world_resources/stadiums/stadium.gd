@tool
extends Node3D
class_name Stadium

@export var npc_spawn_area : CollisionShape3D

@export_tool_button("Setup Staticbody") var setup = setup_stadium_body

@export var stadium_body : StaticBody3D

func _ready() -> void:
	pass

func setup_stadium_body():
	if !stadium_body:
		push_error("No stadium body selected")
		return
	stadium_body.set_collision_mask_value(2, true)
	stadium_body.add_to_group("stadium", true)
	
	stadium_body.notify_property_list_changed()
