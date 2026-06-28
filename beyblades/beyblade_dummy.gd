extends BeyBlade
class_name BeyBladeDummy

@export var stadium : Node3D

func _ready() -> void:
	_physics_setup()

func _spawned(_as_npc := false):
	_bey_setup()
	_launch()

#region setup
func _physics_setup():
	if !contact_monitor: contact_monitor = true
	continuous_cd = true
	max_contacts_reported = 4
	body_entered.connect(_on_collision)

func _bey_setup():
	physics_material_override = disc.physics_material
	mass = (disc.part_weight + core.part_weight + tip.part_weight) * core.weight_mult
	spin_speed *= tip.spin_mult
	stamina *= tip.stamina_mult
	burst_resistance = disc.burst_resitance
	burst_damage = disc.burst_damage

func _launch():
	current_spin = -spin_speed if disc.right_spin else spin_speed
	current_spin *= randf_range(0.9, 1.0)
	stored_engine_spin = angular_velocity.y
#endregion

func _physics_process(_delta: float) -> void:
	var engine_spin := angular_velocity.y
	
	angular_velocity.y = current_spin
	
	if stored_engine_spin != engine_spin: 
		stored_engine_spin = engine_spin
	
	var wobble_decrease = Manager.lerp_weight(remap(abs(current_spin),0.0, 1100, -0.001, 1.0))
	angular_velocity.z = lerpf(angular_velocity.z, 0, wobble_decrease)
	angular_velocity.x = lerpf(angular_velocity.x, 0, wobble_decrease)
	rotation.x = lerpf(rotation.x, 0, wobble_decrease)
	rotation.z = lerpf(rotation.z, 0, wobble_decrease)
	recoil = lerpf(recoil, 1.0, Manager.lerp_weight(0.05))
	
	$CenterTether.look_at(stadium.global_position)
	apply_central_force(get_orbital_force())
	apply_central_force(get_center_pull_force() * (center_tether/recoil))
	if !%FloorCheck.is_colliding(): linear_velocity.y -= get_added_gravity()
func get_orbital_force() -> Vector3:
	var dir = $CenterTether.global_basis.x
	var distance = global_position.distance_to(stadium.global_position)
	var force = dir*0.0038 * current_spin/(distance)
	return force * Vector3(1,0,1)
func get_center_pull_force() -> Vector3:
	var dir = $CenterTether.global_basis.z
	var distance = global_position.distance_to(stadium.global_position)
	var force = (dir*-0.0018) * spin_speed * (distance/1.2) * ((stamina+1)/1.8)
	return force * Vector3(1,0,1)
func get_added_gravity() -> float:
	var distance = global_position.distance_to(stadium.global_position)
	var force = distance/10.0
	return abs(force)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() > 0:
		collision_point = state.get_contact_collider_position(0)
func _on_collision(body : Node):
	if body is BeyBlade or body is BeyBladeDummy:
		var body_speed = body.linear_velocity.length()
		last_collided_bey = body if !body.is_npc else null
		recoil += 0.5
		if linear_velocity.length() > body_speed/1.5:
			_clash_fx(collision_point, body_speed)

func _clash_fx(fx_position : Vector3, _body_speed : float):
	var spark = SPARK_PARTICLE.instantiate()
	add_sibling(spark)
	spark.global_position = fx_position
