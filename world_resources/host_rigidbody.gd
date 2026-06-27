extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Master.is_host:
		freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
		freeze = true
