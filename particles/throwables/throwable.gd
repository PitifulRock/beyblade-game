extends RigidBody3D

@export var death_time = 3.0

func _ready() -> void:
	await get_tree().create_timer(death_time).timeout
	queue_free()
