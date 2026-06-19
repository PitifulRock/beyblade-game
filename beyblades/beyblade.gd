extends RigidBody3D
class_name BeyBlade

const SPARK_PARTICLE = preload("uid://fbwq5alfemyv")

enum TYPE{ATTACK, STAMINA, DEFENSE, BALANCE}

@onready var burst_holder: Node = $BurstHolder
@export var disc : BeyDisc
@export var core : BeyCore
@export var tip : BeyTip

@export_group("Public Variables")
@export var spin_speed : float = 500.0
@export var stamina : float = 0.6
@export var burst_resistance := 1.0
@export var burst_percentage := 0.0
@export var burst_damage := 1.0
@export var can_take_damage := true
@export var dead := false

@export var current_spin : float
var stored_engine_spin : float

var collision_point : Vector3
var last_collided_bey : BeyBlade
var game_world : World

func _ready() -> void:
	game_world = Master.game_manager.current_scene
	_physics_setup()

func _spawned():
	if !Master.is_host: return
	_bey_setup()
	_launch()

#region setup
func _physics_setup():
	if Master.is_host:
		if !contact_monitor: contact_monitor = true
		continuous_cd = true
		max_contacts_reported = 4
		body_entered.connect(_on_collision)
	else:
		freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
		freeze = true

func _bey_setup():
	physics_material_override = disc.physics_material
	mass = (disc.part_weight + core.part_weight + tip.part_weight) * core.weight_mult
	spin_speed *= tip.spin_mult
	stamina *= tip.stamina_mult
	burst_resistance = disc.burst_resitance
	burst_damage = disc.burst_damage

func _launch():
	current_spin = -spin_speed if disc.right_spin else spin_speed
	current_spin *= randf_range(0.8, 1.2)
	stored_engine_spin = angular_velocity.y
#endregion

func _physics_process(_delta: float) -> void:
	if Master.is_host:
		var engine_spin := angular_velocity.y
		var e_spin_diff = engine_spin - stored_engine_spin
		
		if abs(current_spin) > 10.0:
			current_spin = lerpf(current_spin, 0.0, get_spin_loss(e_spin_diff))
			%SpinSound.pitch_scale = clampf(abs(current_spin)/100, 0.7, 1.5) * Engine.time_scale
			%SpinSound.volume_db = remap(abs(current_spin), 0, 900, -14, -4)
		else:
			current_spin = lerpf(current_spin, 0.0, Manager.lerp_weight(0.08))
			%SpinSound.volume_db = lerpf(%SpinSound.volume_db, -80, Manager.lerp_weight(0.08))
			if !dead: 
				die(World.POINT_TYPE.STAMINA)
		angular_velocity.y = current_spin

		%Label3D.text = str(int(abs(current_spin)), ", ", int(burst_percentage))
		
		if !dead:
			if stored_engine_spin != engine_spin: 
				stored_engine_spin = engine_spin
			
			var wobble_decrease = Manager.lerp_weight(remap(abs(current_spin),0.0, 1100, -0.001, 1.0))
			angular_velocity.z = lerpf(angular_velocity.z, 0, wobble_decrease)
			angular_velocity.x = lerpf(angular_velocity.x, 0, wobble_decrease)
			rotation.x = lerpf(rotation.x, 0, wobble_decrease)
			rotation.z = lerpf(rotation.z, 0, wobble_decrease)
			
			$CenterTether.look_at(Vector3.ZERO)
			apply_central_force(get_orbital_force())
			apply_central_force(get_center_pull_force())
		
	if burst_percentage >= 100 and !dead: 
		die(World.POINT_TYPE.DESTRUCTION)
		burst()

func die(point_type : World.POINT_TYPE):
	if !Master.is_host: return
	var point_winner = last_collided_bey if point_type != World.POINT_TYPE.STAMINA else null
	var winner_id = point_winner.name.to_int() if point_winner else -1
	dead = true
	game_world._bey_death(point_type, winner_id)
	
	if point_type == World.POINT_TYPE.DESTRUCTION:
		burst.rpc()

@rpc("any_peer", "call_local", "reliable")
func burst():
	burst_holder.reparent(Master.game_manager.current_scene.particle_path)
	burst_holder.show()
	burst_holder.process_mode = Node.PROCESS_MODE_INHERIT
	for i in burst_holder.get_children():
		if i is RigidBody3D:
			i.apply_central_impulse(Vector3(randf_range(-10, 10),randf_range(5, 10),randf_range(-10, 10)))
	
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED

func get_spin_loss(spin_diff : float) -> float:
	var spin_loss := 0.0004
	if spin_diff < -1.0: 
		spin_loss = clampf(-spin_diff/2000.0, 0.0004, 0.01)
	var adjusted := (spin_loss / stamina) * randf_range(0.9, 1.2)
	return Manager.lerp_weight(adjusted)
func get_orbital_force() -> Vector3:
	var dir = $CenterTether.global_basis.x
	var force = dir*0.0025 * current_spin/global_position.distance_to(Vector3.ZERO)
	return force * Vector3(1,0,1)
func get_center_pull_force() -> Vector3:
	var dir = $CenterTether.global_basis.z
	var force = dir*-0.0015 * spin_speed * global_position.distance_to(Vector3.ZERO) * (stamina+1)
	return force * Vector3(1,0,1)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() > 0:
		collision_point = state.get_contact_collider_position(0)
func _on_collision(body : Node):
	if body is BeyBlade and !dead:
		var body_speed = body.linear_velocity.length()
		last_collided_bey = body
		if linear_velocity.length() > body_speed/1.5:
			#spin reduction from hitting fast
			var reduction = body_speed/1.5
			current_spin -= -reduction if current_spin < 0 else reduction
			
			_clash_fx.rpc(collision_point, body_speed)
			
		if linear_velocity.length() < body_speed/1.5 and can_take_damage:
			var incoming_damage = (body_speed*body.burst_damage) * abs(body.current_spin)/550
			var recieved_damage = incoming_damage/burst_resistance/1.2
			burst_percentage += clampf(recieved_damage, 0.0, 50.0)
			can_take_damage = false
			await get_tree().create_timer(0.3).timeout
			can_take_damage = true

@rpc("any_peer", "call_local", "reliable")
func _clash_fx(fx_position : Vector3, body_speed : float):
	var spark = SPARK_PARTICLE.instantiate()
	game_world.particle_path.add_child(spark)
	spark.global_position = fx_position
	
	%ClashSound.volume_db = remap(body_speed, 0, 20, -6, 0)
	%ClashSound.play()
