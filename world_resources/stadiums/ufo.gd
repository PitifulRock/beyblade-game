extends Node3D

var move_tween : Tween
var move_speed := 4.0
var next_pos := Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	travel_to_rand()

func travel_to_rand():
	var calculated_pos := get_travel_point(%TravelArea)
	if Master.is_host: set_next_pos.rpc(calculated_pos)
	
	var tween_speed := global_position.distance_to(next_pos)/move_speed
	
	move_tween = get_tree().create_tween()
	move_tween.tween_property(self, "global_position", next_pos, tween_speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await move_tween.finished
	travel_to_rand()

func get_travel_point(collision_shape: CollisionShape3D) -> Vector3:
	if randf() < 0.3: return Vector3.ZERO
	
	var radius :float = collision_shape.shape.radius
	var angle := randf_range(10, TAU)
	
	var random_radius := radius * sqrt(randf())

	var offset := Vector3(cos(angle), 0, sin(angle)) * random_radius
	return collision_shape.global_position + offset

@rpc("any_peer", "call_local", "reliable")
func set_next_pos(new : Vector3):
	next_pos = new
