extends Node

var delta_t : float

func _physics_process(delta: float) -> void:
	delta_t = delta

func lerp_rate(rate : float) -> float:
	return 1 - exp(-rate * delta_t)
func lerp_weight(weight : float) -> float:
	return 1 - pow(1 - weight, delta_t * 60)
