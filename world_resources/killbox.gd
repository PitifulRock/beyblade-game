extends Area3D
class_name KillBox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_enter)

func _on_body_enter(body : Node3D):
	if body is BeyBlade:
		if !body.dead:
			body.die(GameWorld.POINT_TYPE.KNOCKOUT)
