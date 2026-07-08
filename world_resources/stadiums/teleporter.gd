extends Area3D

@onready var exit : Marker3D = $Exit
var self_index : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self_index = get_parent().get_children().find(self)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body : Node3D):
	if !Master.is_host: return
	if body is BeyBlade:
		var exit_index := randi_range(0, get_parent().get_child_count()-1)
		exit_index -= 1 if exit_index == self_index else 0
		var exit_tele = get_parent().get_child(exit_index)
		body.global_position = exit_tele.exit.global_position
		
		var new_velocity = body.global_position.direction_to(exit.global_position) * body.linear_velocity.length()
		body.linear_velocity = new_velocity
		teleport_fx.rpc()

@rpc("any_peer", "call_local")
func teleport_fx():
	$"AudioStreamPlayer3D".play()
