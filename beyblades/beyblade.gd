extends RigidBody3D
class_name BeyBlade

@export var data : BeyData = preload("uid://bgrd4ujdloxwy")

var current_spin : float
var stored_engine_spin : float

func _ready() -> void:
	if !contact_monitor: contact_monitor = true
	max_contacts_reported = 4
	
	body_entered.connect(_on_collision)
	
	current_spin = -data.spin_speed if data.right_spin else data.spin_speed
	current_spin *= randf_range(0.8, 1.2)
	mass = data.weight
	stored_engine_spin = angular_velocity.y

func _physics_process(_delta: float) -> void:
	var engine_spin := angular_velocity.y
	var e_spin_diff = engine_spin - stored_engine_spin
	
	current_spin = lerpf(current_spin, 0.0, get_spin_loss(e_spin_diff))
	angular_velocity.y = current_spin

	%Label3D.text = str(int(abs(current_spin)), ", ", int(linear_velocity.length()))
	
	if stored_engine_spin != engine_spin: 
		stored_engine_spin = engine_spin
	
	$CenterTether.look_at(Vector3.ZERO)
	apply_central_force(get_orbital_force())
	apply_central_force(get_center_pull_force())

func get_spin_loss(spin_diff : float) -> float:
	var spin_loss := 0.0004
	if spin_diff < -1.0: 
		spin_loss = clampf(-spin_diff/2000.0, 0.0004, 0.01)
	return (spin_loss / data.stamina) * randf_range(0.9, 1.2)

func get_orbital_force() -> Vector3:
	var dir = $CenterTether.global_basis.x
	var force = dir*0.001 * current_spin/global_position.distance_to(Vector3.ZERO)
	return force * Vector3(1,0,1)
func get_center_pull_force() -> Vector3:
	var dir = $CenterTether.global_basis.z
	var force = dir*-0.0004 * data.spin_speed * global_position.distance_to(Vector3.ZERO) * (data.stamina+1)
	return force * Vector3(1,0,1)

func _on_collision(body : Node):
	if body is BeyBlade:
		var body_speed = body.linear_velocity.length()
		if linear_velocity.length() < body_speed:
			current_spin -= -body_speed if current_spin < 0 else body_speed
